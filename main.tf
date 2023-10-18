# Providers
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource group
resource "azurerm_resource_group" "tfe" {
  name     = "${var.environment_name}-resources"
  location = var.region
}

# Network Security group and rules
resource "azurerm_network_security_group" "tfe" {
  name                = "${var.environment_name}-security-group"
  location            = azurerm_resource_group.tfe.location
  resource_group_name = azurerm_resource_group.tfe.name
}

resource "azurerm_network_security_rule" "https" {
  name                        = "AllowAnyHTTPSInbound"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 443
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tfe.name
  network_security_group_name = azurerm_network_security_group.tfe.name
}

resource "azurerm_network_security_rule" "http" {
  name                        = "AllowAnyHTTPInbound"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 80
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tfe.name
  network_security_group_name = azurerm_network_security_group.tfe.name
}

resource "azurerm_network_security_rule" "ssh" {
  name                        = "AllowAnySSHInbound"
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 22
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tfe.name
  network_security_group_name = azurerm_network_security_group.tfe.name
}

resource "azurerm_network_security_rule" "replicated" {
  name                        = "AllowAnyReplicatedInbound"
  priority                    = 140
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 8800
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tfe.name
  network_security_group_name = azurerm_network_security_group.tfe.name
}

resource "azurerm_network_security_rule" "postgres" {
  name                        = "AllowAnyPostgresInbound"
  priority                    = 150
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 5432
  source_address_prefix       = var.vnet_cidr
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tfe.name
  network_security_group_name = azurerm_network_security_group.tfe.name
}

# VNet
resource "azurerm_virtual_network" "tfe" {
  name                = "${var.environment_name}-network"
  location            = azurerm_resource_group.tfe.location
  resource_group_name = azurerm_resource_group.tfe.name
  address_space       = [var.vnet_cidr]
}

# Subnets
resource "azurerm_subnet" "public" {
  name                 = "${var.environment_name}-public-subnet"
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 8, 1)]
  resource_group_name  = azurerm_resource_group.tfe.name
  virtual_network_name = azurerm_virtual_network.tfe.name
}

resource "azurerm_subnet" "private" {
  name                 = "${var.environment_name}-private-subnet"
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 8, 11)]
  resource_group_name  = azurerm_resource_group.tfe.name
  virtual_network_name = azurerm_virtual_network.tfe.name
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage"]

  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

# NAT gateway with Public IP address
resource "azurerm_nat_gateway" "tfe" {
  name                    = "${var.environment_name}-NAT-gateway"
  location                = azurerm_resource_group.tfe.location
  resource_group_name     = azurerm_resource_group.tfe.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 4
}

resource "azurerm_public_ip" "tfe" {
  name                = "${var.environment_name}-NAT-gateway-PublicIP"
  location            = azurerm_resource_group.tfe.location
  resource_group_name = azurerm_resource_group.tfe.name
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_nat_gateway_public_ip_association" "tfe" {
  nat_gateway_id       = azurerm_nat_gateway.tfe.id
  public_ip_address_id = azurerm_public_ip.tfe.id
}

# Assosiate NSG and NAT gateway with Subnets
resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.tfe.id
}

resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.tfe.id
}

resource "azurerm_subnet_nat_gateway_association" "tfe" {
  subnet_id      = azurerm_subnet.private.id
  nat_gateway_id = azurerm_nat_gateway.tfe.id
}

# Blob storage
resource "azurerm_storage_account" "tfe" {
  name                          = var.storage_name
  resource_group_name           = azurerm_resource_group.tfe.name
  location                      = var.region
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = true
}

resource "azurerm_storage_container" "tfe" {
  name                  = "${var.environment_name}-container"
  storage_account_name  = azurerm_storage_account.tfe.name
  container_access_type = "container"
}

/*
resource "azurerm_storage_blob" "tfe" {
  name                   = "license.rli"
  storage_account_name   = azurerm_storage_account.tfe.name
  storage_container_name = azurerm_storage_container.tfe.name
  type                   = "Block"
  source                 = "files/license.rli"
}
*/

# Database
resource "azurerm_private_dns_zone" "tfe" {
  name                = "${var.environment_name}.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.tfe.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "tfe" {
  name                  = "exampleVnetZone.com"
  private_dns_zone_name = azurerm_private_dns_zone.tfe.name
  virtual_network_id    = azurerm_virtual_network.tfe.id
  resource_group_name   = azurerm_resource_group.tfe.name
}

resource "azurerm_postgresql_flexible_server" "tfe" {
  name                   = "${var.environment_name}-postgres"
  resource_group_name    = azurerm_resource_group.tfe.name
  location               = var.region
  version                = "15"
  sku_name               = "B_Standard_B1ms"
  storage_mb             = 32768
  administrator_login    = var.postgresql_user
  administrator_password = var.postgresql_password
  delegated_subnet_id    = azurerm_subnet.private.id
  private_dns_zone_id    = azurerm_private_dns_zone.tfe.id
  zone                   = "2"
}

# To address a known issue - https://support.hashicorp.com/hc/en-us/articles/4548903433235-Terraform-Enterprise-External-Services-mode-with-Azure-Database-for-PostgreSQL-Flexible-Server-Failed-to-Initialize-**Plugins
resource "azurerm_postgresql_flexible_server_configuration" "tfe" {
  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.tfe.id
  value     = "CITEXT,HSTORE,UUID-OSSP"
}

# Virtual Machine
resource "azurerm_network_interface" "tfe" {
  name                = "${var.environment_name}-nic"
  location            = var.region
  resource_group_name = azurerm_resource_group.tfe.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

resource "azurerm_public_ip" "example" {
  name                = "${var.environment_name}-TFE-PublicIP"
  location            = azurerm_resource_group.tfe.location
  resource_group_name = azurerm_resource_group.tfe.name
  sku                 = "Standard"
  allocation_method   = "Static"
  domain_name_label   = var.environment_name
}

resource "azurerm_linux_virtual_machine" "tfe" {
  name                = "${var.environment_name}-vm"
  resource_group_name = azurerm_resource_group.tfe.name
  location            = var.region
  size                = "Standard_D4s_v3"
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.tfe.id,
  ]

  custom_data = filebase64("./files/cloud-init.tpl")
  
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = "50"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}