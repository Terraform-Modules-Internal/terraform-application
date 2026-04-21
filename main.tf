# ─── Provider Data ────────────────────────────────────────────────────────────
data "azurerm_client_config" "current" {}

# ─── Computed Locals ──────────────────────────────────────────────────────────
# Azure resource IDs are constructed from known inputs so they are available at
# plan time. count/for_each in child modules cannot use values that are only
# known after apply (e.g. module.networking.vnet_id, subnet_ids) — using
# pre-computed IDs avoids the "Invalid count argument" error.
locals {
  vnet_name      = "vnet-${var.project_name}-${var.environment}-eus-001"
  vnet_id        = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${local.vnet_name}"
  data_subnet_id = "${local.vnet_id}/subnets/snet-data"
}

# ─── Resource Group ───────────────────────────────────────────────────────────
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ─── Networking Module ────────────────────────────────────────────────────────
# Provisions the VNet with two delegated subnets:
#   snet-app   → App Service VNet integration (Microsoft.Web/serverFarms)
#   snet-data  → MySQL VNet delegation      (Microsoft.DBforMySQL/flexibleServers)
# NSGs restrict inbound traffic to HTTPS/HTTP on the app tier and MySQL (3306)
# from the app subnet on the data tier.
module "networking" {
  source = "git::https://github.com/Terraform-Modules-Internal/terraform-azurerm-networking.git?ref=v1.0.1"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags                = var.tags

  vnet_name          = "vnet-${var.project_name}-${var.environment}-eus-001"
  vnet_address_space = var.vnet_address_space

  subnets = {
    "snet-app" = {
      address_prefixes = [var.app_service_subnet_prefix]
      delegation = {
        name = "app-service-delegation"
        service_delegation = {
          name    = "Microsoft.Web/serverFarms"
          actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
    }
    "snet-data" = {
      address_prefixes = [var.mysql_subnet_prefix]
      delegation = {
        name = "mysql-delegation"
        service_delegation = {
          name    = "Microsoft.DBforMySQL/flexibleServers"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      }
    }
  }

  nsgs = {
    "nsg-app" = {
      security_rules = [
        {
          name                   = "allow-https-inbound"
          priority               = 100
          direction              = "Inbound"
          access                 = "Allow"
          protocol               = "Tcp"
          destination_port_range = "443"
        },
        {
          name                   = "allow-http-inbound"
          priority               = 110
          direction              = "Inbound"
          access                 = "Allow"
          protocol               = "Tcp"
          destination_port_range = "80"
        }
      ]
    }
    "nsg-data" = {
      security_rules = [
        {
          name                   = "allow-mysql-from-app"
          priority               = 100
          direction              = "Inbound"
          access                 = "Allow"
          protocol               = "Tcp"
          source_address_prefix  = var.app_service_subnet_prefix
          destination_port_range = "3306"
        }
      ]
    }
  }

  subnet_nsg_associations = {
    "snet-app"  = "nsg-app"
    "snet-data" = "nsg-data"
  }
}

# ─── App Service Module ───────────────────────────────────────────────────────
# Linux Web App (Python 3.11) with VNet integration to snet-app.
# App settings are pre-wired to the MySQL FQDN and database name.
module "app_service" {
  source = "git::https://github.com/Terraform-Modules-Internal/terraform-azurerm-app-service.git?ref=v1.0.0"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags                = var.tags

  service_plan_name = "asp-${var.project_name}-${var.environment}-eus-001"
  app_service_name  = "app-${var.project_name}-${var.environment}-eus-001"
  sku_name          = var.app_service_sku
  https_only        = true
  always_on         = false

  application_stack = {
    python_version = "3.11"
  }

  # subnet_id omitted — F1 (Free) SKU does not support VNet integration.

  app_settings = merge(
    var.app_settings,
    {
      "WEBSITE_RUN_FROM_PACKAGE"       = "1"
      "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    },
    # Only inject MySQL settings when a Flexible Server is actually deployed.
    module.data.mysql_fqdn != null ? {
      "MYSQL_HOST"     = module.data.mysql_fqdn
      "MYSQL_DATABASE" = var.mysql_database_name
      "MYSQL_USER"     = var.mysql_admin_username
    } : {}
  )
}

# ─── Data Module ─────────────────────────────────────────────────────────────
# MySQL Flexible Server (private, delegated to snet-data) + Storage Account.
module "data" {
  source = "git::https://github.com/Terraform-Modules-Internal/terraform-azurerm-data.git?ref=v1.0.1"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags                = var.tags

  # mysql = null — MySQL Flexible Server is not available in this subscription/region.
  # Re-enable by restoring the mysql block once quota is approved at:
  # https://aka.ms/mysqlcapacity
  mysql = null

  storage = {
    name                     = "${replace(var.project_name, "-", "")}${var.environment}eus001"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    containers = [
      { name = "uploads" }
    ]
  }
}
