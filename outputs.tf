# ─── App Service ─────────────────────────────────────────────────────────────

output "app_service_url" {
  description = "Default HTTPS URL of the App Service."
  value       = "https://${module.app_service.app_service_default_hostname}"
}

output "app_service_id" {
  description = "Resource ID of the App Service."
  value       = module.app_service.app_service_id
}

output "app_service_principal_id" {
  description = "Principal ID of the App Service system-assigned managed identity."
  value       = module.app_service.app_service_principal_id
}

# ─── Networking ───────────────────────────────────────────────────────────────

output "vnet_id" {
  description = "Resource ID of the Virtual Network."
  value       = module.networking.vnet_id
}

output "app_service_subnet_id" {
  description = "Resource ID of the App Service integration subnet."
  value       = module.networking.subnet_ids["snet-app"]
}

output "mysql_subnet_id" {
  description = "Resource ID of the MySQL delegated subnet."
  value       = module.networking.subnet_ids["snet-data"]
}

# ─── Data ─────────────────────────────────────────────────────────────────────

output "mysql_fqdn" {
  description = "Fully qualified domain name of the MySQL Flexible Server."
  value       = module.data.mysql_fqdn
}

output "storage_account_name" {
  description = "Name of the Storage Account."
  value       = module.data.storage_account_name
}

output "storage_account_primary_blob_endpoint" {
  description = "Primary blob endpoint URL of the Storage Account."
  value       = module.data.storage_account_primary_blob_endpoint
}
