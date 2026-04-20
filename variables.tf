# ─── General ──────────────────────────────────────────────────────────────────

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group where all MVP resources will be created."
}

variable "location" {
  type        = string
  description = "Azure region for all resources."
  default     = "eastus2"
}

variable "project_name" {
  type        = string
  description = "Short project identifier used to generate resource names."
  default     = "bdt"
}

variable "environment" {
  type        = string
  description = "Environment enumeration used in resource names and tags."
  default     = "dev"
  validation {
    condition     = contains(["dev", "test", "stage", "qa", "uat", "sit", "prod", "nonprod", "sandbox"], var.environment)
    error_message = "environment must be one of: dev, test, stage, qa, uat, sit, prod, nonprod, sandbox."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to every resource in the deployment."
  default     = {}
}

# ─── Networking ───────────────────────────────────────────────────────────────

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the Virtual Network."
  default     = ["10.0.0.0/16"]
}

variable "app_service_subnet_prefix" {
  type        = string
  description = "CIDR for the App Service VNet-integration subnet (delegated to Microsoft.Web/serverFarms). Minimum /28."
  default     = "10.0.1.0/24"
}

variable "mysql_subnet_prefix" {
  type        = string
  description = "CIDR for the MySQL delegated subnet (delegated to Microsoft.DBforMySQL/flexibleServers). Minimum /29."
  default     = "10.0.2.0/24"
}

# ─── App Service ─────────────────────────────────────────────────────────────

variable "app_service_sku" {
  type        = string
  description = "App Service Plan SKU (e.g. B1, B2, P1v2). B1 is sufficient for dev/test workloads."
  default     = "B1"
}

variable "app_settings" {
  type        = map(string)
  description = "Additional application settings merged into the App Service. MYSQL_HOST, MYSQL_DATABASE, and MYSQL_USER are injected automatically."
  default     = {}
}

# ─── MySQL ────────────────────────────────────────────────────────────────────

variable "mysql_admin_username" {
  type        = string
  description = "MySQL administrator login name."
  default     = "mysqladmin"
}

variable "mysql_admin_password" {
  type        = string
  description = "MySQL administrator password. Pass via TF_VAR_mysql_admin_password or a secrets manager — never commit."
  sensitive   = true
  default     = null
  nullable    = true
}

variable "mysql_sku" {
  type        = string
  description = "MySQL Flexible Server SKU (e.g. B_Standard_B1ms, GP_Standard_D2ds_v4)."
  default     = "B_Standard_B1ms"
}

variable "mysql_storage_size_gb" {
  type        = number
  description = "Storage size in GB for the MySQL Flexible Server."
  default     = 20
}

variable "mysql_database_name" {
  type        = string
  description = "Name of the default database to create within the MySQL server."
  default     = "appdb"
}
