output "nginx_fqdn" {
  description = "Public FQDN of the nginx Container App."
  value       = module.container_app.container_app_fqdns["nginx"]
}

output "environment_id" {
  description = "Resource ID of the Container App Environment."
  value       = module.container_app.environment_id
}

output "environment_static_ip" {
  description = "Static IP of the Container App Environment (VNet-integrated)."
  value       = module.container_app.environment_static_ip
}

output "vnet_id" {
  description = "Resource ID of the Virtual Network."
  value       = module.networking.vnet_id
}

output "container_apps_subnet_id" {
  description = "Resource ID of the Container Apps subnet."
  value       = module.networking.subnet_ids["snet-container-apps"]
}
