# ----------------------------------------------------------------------------
# Resource Group
# ----------------------------------------------------------------------------
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ----------------------------------------------------------------------------
# Log Analytics Workspace
# Required by the Container App Environment for diagnostic telemetry.
# ----------------------------------------------------------------------------
resource "azurerm_log_analytics_workspace" "this" {
  name                = "law-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# ----------------------------------------------------------------------------
# Networking Module
# Creates the VNet and the Container Apps subnet with the required delegation.
# ----------------------------------------------------------------------------
module "networking" {
  source = "git::https://github.com/Terraform-Modules-Internal/terraform-azurerm-networking.git?ref=v1.0.0"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags                = var.tags

  vnet_name          = "vnet-${var.project_name}-${var.environment}"
  vnet_address_space = var.vnet_address_space

  subnets = {
    "snet-container-apps" = {
      address_prefixes = [var.container_apps_subnet_prefix]
      # Container App Environments require a dedicated subnet delegated to
      # Microsoft.App/environments with a minimum prefix length of /23.
      delegation = {
        name = "container-apps-delegation"
        service_delegation = {
          name    = "Microsoft.App/environments"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      }
    }
  }
}

# ----------------------------------------------------------------------------
# Container App Module
# Deploys a Container App Environment (VNet-integrated) and an nginx container.
# ----------------------------------------------------------------------------
module "container_app" {
  source = "git::https://github.com/Terraform-Modules-Internal/terraform-azurerm-container-app.git?ref=v1.0.1"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags                = var.tags

  environment_name           = "cae-${var.project_name}-${var.environment}"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  # VNet integration: pins the environment inside the Container Apps subnet.
  infrastructure_subnet_id       = module.networking.subnet_ids["snet-container-apps"]
  internal_load_balancer_enabled = false # public-facing load balancer

  container_apps = {
    "nginx" = {
      revision_mode = "Single"

      ingress = {
        external_enabled = true
        target_port      = 80
        transport        = "auto"
        traffic_weights = [
          {
            latest_revision = true
            percentage      = 100
          }
        ]
      }

      containers = [
        {
          name   = "nginx"
          image  = "nginx:latest"
          cpu    = 0.5
          memory = "1Gi"
        }
      ]

      min_replicas = 1
      max_replicas = 3
    }
  }
}
