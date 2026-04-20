# Root Module — BDT MVP

Deploys the full BDT MVP infrastructure stack using three child modules:

```
Resource Group  (rg-bdt-mvp-dev-eus2-001)
├── module: networking
│   └── VNet  (10.0.0.0/16)
│       ├── snet-app   (10.0.1.0/24) — App Service VNet integration  + nsg-app
│       └── snet-data  (10.0.2.0/24) — MySQL delegation              + nsg-data
├── module: app_service
│   ├── App Service Plan  (asp-bdt-dev-eus2-001, B1 Linux)
│   └── App Service       (app-bdt-dev-eus2-001, Python 3.11)
│       └── VNet integration → snet-app
└── module: data
    ├── MySQL Flexible Server  (mysql-bdt-dev-eus2-001, private, delegated to snet-data)
    │   └── Database: appdb
    └── Storage Account  (bdtdeveus2001)
        └── Container: uploads
```

---

## Usage

```bash
# Provide the MySQL password — never commit this value
export TF_VAR_mysql_admin_password="<strong-password>"

terraform init
terraform plan
terraform apply
```

---

## Module Sources

| Module | Repository | Version |
|--------|------------|---------|
| networking | `git::https://github.com/Terraform-Modules-Internal/terraform-azurerm-networking.git` | `v1.0.0` |
| app_service | `git::https://github.com/Terraform-Modules-Internal/terraform-azurerm-app-service.git` | `v1.0.0` |
| data | `git::https://github.com/Terraform-Modules-Internal/terraform-azurerm-data.git` | `v1.0.0` |

---

## Requirements

| Name | Version |
|------|---------|
| Terraform | `>= 1.5.0` |
| azurerm | `>= 3.85.0` |

---

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `resource_group_name` | `string` | — | Name of the resource group |
| `location` | `string` | `"eastus2"` | Azure region |
| `project_name` | `string` | `"bdt"` | Short project identifier for resource names |
| `environment` | `string` | `"dev"` | Environment enum (dev/test/prod etc.) |
| `tags` | `map(string)` | `{}` | Tags applied to all resources |
| `vnet_address_space` | `list(string)` | `["10.0.0.0/16"]` | VNet address space |
| `app_service_subnet_prefix` | `string` | `"10.0.1.0/24"` | App Service subnet CIDR (min /28) |
| `mysql_subnet_prefix` | `string` | `"10.0.2.0/24"` | MySQL subnet CIDR (min /29) |
| `app_service_sku` | `string` | `"B1"` | App Service Plan SKU |
| `app_settings` | `map(string)` | `{}` | Additional App Service settings |
| `mysql_admin_username` | `string` | `"mysqladmin"` | MySQL admin username |
| `mysql_admin_password` | `string` | — | MySQL admin password (**sensitive** — use secrets manager) |
| `mysql_sku` | `string` | `"B_Standard_B1ms"` | MySQL Flexible Server SKU |
| `mysql_storage_size_gb` | `number` | `20` | MySQL storage size in GB |
| `mysql_database_name` | `string` | `"appdb"` | Default MySQL database name |

---

## Outputs

| Name | Description |
|------|-------------|
| `app_service_url` | Default HTTPS URL of the App Service |
| `app_service_id` | Resource ID of the App Service |
| `app_service_principal_id` | Principal ID of the App Service managed identity |
| `vnet_id` | Resource ID of the Virtual Network |
| `app_service_subnet_id` | Resource ID of the App Service integration subnet |
| `mysql_subnet_id` | Resource ID of the MySQL delegated subnet |
| `mysql_fqdn` | FQDN of the MySQL Flexible Server |
| `storage_account_name` | Name of the Storage Account |
| `storage_account_primary_blob_endpoint` | Primary blob endpoint URL |

---

## Maintained By

| Name | Email |
|------|-------|
| Raghavendiran N | raghavendirann@presidio.com |
| Sakthivel Manohar | smanohar@presidio.com |
