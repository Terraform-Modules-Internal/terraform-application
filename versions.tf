terraform {
  required_version = ">= 1.5.0"

  # HCP Terraform (Terraform Cloud) — state, run history, and locking.
  # Organization is injected via TF_CLOUD_ORGANIZATION env var.
  # Workspace is fixed to "bdt-mvp-dev" for this root module.
  cloud {
    workspaces {
      name = "bdt-mvp-dev"
    }
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}
