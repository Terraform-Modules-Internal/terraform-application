resource_group_name = "rg-bdt-dev"
location            = "eastus"
project_name        = "bdt"
environment         = "dev"

vnet_address_space           = ["10.0.0.0/16"]
container_apps_subnet_prefix = "10.0.0.0/23"

tags = {
  environment = "dev"
  project     = "bdt"
  managed_by  = "terraform"
}
