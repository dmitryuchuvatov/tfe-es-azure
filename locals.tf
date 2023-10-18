locals {
  user = var.admin_username
  ip   = azurerm_public_ip.example.ip_address
  fqdn = azurerm_public_ip.example.domain_name_label
}