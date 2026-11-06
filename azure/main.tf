terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=5.0.0"
    }
  }
}
  
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = "eastus"

  tags = {
    environment = "dev"
    project     = "mi-catalogo"
    managed_by  = "terraform"
  }
}