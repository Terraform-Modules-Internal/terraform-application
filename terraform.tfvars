resource_group_name = "rg-bdt-mvp-dev-eus-001"
location            = "eastus"
project_name        = "bdt"
environment         = "dev"

# Networking
vnet_address_space        = ["10.0.0.0/16"]
app_service_subnet_prefix = "10.0.1.0/24"
mysql_subnet_prefix       = "10.0.2.0/24"

# App Service
app_service_sku = "S1"

# MySQL
mysql_admin_username  = "mysqladmin"
# mysql_admin_password — set via TF_VAR_mysql_admin_password or Azure Key Vault; never commit
mysql_sku             = "B_Standard_B1ms"
mysql_storage_size_gb = 20
mysql_database_name   = "appdb"

tags = {
  Application         = "BDT-MVP"
  CreationDate        = "04/20/2026"
  DevOwner            = "raghavendirann@presidio.com"
  BusinessOwner       = "smanohar@presidio.com"
  Environment         = "dev"
  CostCenter          = "BDT-001"
  DataClassification  = "Sensitive"
  BusinessCriticality = "Medium"
  Compliance          = "CIS"
}
