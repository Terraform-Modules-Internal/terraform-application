# Changelog

All notable changes to this root module will be documented here.

## [2.0.0] — 2026-04-20

### Changed
- **Breaking**: replaced Container App stack with full MVP stack (App Service + MySQL + Storage).
- `module "networking"` updated: Container Apps subnet removed; `snet-app` (App Service integration) and `snet-data` (MySQL delegation) added with NSGs.
- `module "app_service"` added: Linux App Service Plan (B1) + Python 3.11 Web App with VNet integration.
- `module "data"` added: MySQL 8.0 Flexible Server (private, VNet-delegated) + Storage Account.
- Outputs updated to reflect new MVP resources.
- All tfvars updated: location → `eastus2`, naming convention applied, all 9 required tags added.

## [1.0.0] — 2026-04-08

### Added
- Initial root module configuration.
- `azurerm_resource_group` for all resources.
- `azurerm_log_analytics_workspace` for Container App Environment diagnostics.
- `module "networking"` — VNet (`10.0.0.0/16`) with a Container Apps subnet delegated to `Microsoft.App/environments`.
- `module "container_app"` — VNet-integrated Container App Environment hosting nginx on port 80 with external ingress.
- Outputs: `nginx_fqdn`, `vnet_id`, `environment_id`, `environment_static_ip`, `container_apps_subnet_id`.
