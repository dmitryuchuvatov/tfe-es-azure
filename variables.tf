variable "environment_name" {
  type        = string
  description = "Name used to create and tag resources"
  default     = "dmitry-tfe"
}

variable "region" {
  type        = string
  description = "Azure region to deploy in"
  default     = "West Europe"
}

variable "vnet_cidr" {
  type        = string
  description = "The IP range for the VNet in CIDR format"
  default     = "10.200.0.0/16"
}

variable "postgresql_user" {
  description = "PostgreSQL user"
  type        = string
  default     = "postgres"
}

variable "postgresql_password" {
  description = "PostgreSQL password"
  type        = string
  default     = "Password1#"
}

variable "storage_name" {
  type        = string
  description = "Name used to create storage account. Can contain ONLY lowercase letters and numbers; must be unique across all existing storage account names in Azure"
  default     = "tfestorageaccount"
}

variable "admin_username" {
  type        = string
  description = "Admin username to access the TFE instance via SSH"
  default     = "adminuser"
}