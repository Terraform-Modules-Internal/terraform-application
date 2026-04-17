variable "resource_group_name" {
  type        = string
  description = "Name of the resource group where all resources will be created."
}

variable "location" {
  type        = string
  description = "Azure region for all resources."
  default     = "eastus"
}

variable "project_name" {
  type        = string
  description = "Short project identifier used to name resources."
  default     = "bdt"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g. dev, staging, prod)."
  default     = "dev"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources."
  default     = {}
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the Virtual Network."
  default     = ["10.0.0.0/16"]
}

variable "container_apps_subnet_prefix" {
  type        = string
  description = "CIDR prefix for the Container Apps subnet. Must be /23 or larger (Azure requirement)."
  default     = "10.0.0.0/23"
}
