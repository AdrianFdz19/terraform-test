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

#Nuevo comentario

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = "eastus"

  tags = {
    environment = "dev"
    project     = "mi-catalogo"
    managed_by  = "terraform"
  }
}

# 2. Azure Container Registry (ACR) - To store your Docker images
resource "azurerm_container_registry" "acr" {
  name                = "farfacrmicatalogodev" # Must be globally unique (alphanumeric only)
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

# 3. Azure Container Apps Environment - The managed serverless boundary
resource "azurerm_container_app_environment" "cae" {
  name                = "cae-mi-catalogo-dev"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# 4. Azure Container App - The actual running instance of your Next.js app
resource "azurerm_container_app" "api" {
  name                         = "ca-mi-catalogo-app"
  container_app_environment_id = azurerm_container_app_environment.cae.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  # Authentication config to pull from your private ACR
  registry {
    server               = azurerm_container_registry.acr.login_server
    username             = azurerm_container_registry.acr.admin_username
    password_secret_name = "acr-password"
  }

  secret {
    name  = "acr-password"
    value = azurerm_container_registry.acr.admin_password
  }

  template {
    container {
      name   = "mi-catalogo-ui"
      image  = "${azurerm_container_registry.acr.login_server}/mi-catalogo:v1"
      cpu    = "0.25"
      memory = "0.5Gi"

      # Environment variables for your app (e.g., Google Sheets integration later)
      env {
        name  = "NODE_ENV"
        value = "production"
      }

      env {
        name  = "GOOGLE_SHEET_CSV_URL"
        value = var.google_sheet_csv_url
      }
    }
  }

  # Ingress configuration to expose your Next.js app to the internet
  ingress {
    external_enabled = true
    target_port      = 3000 # Matches the port your Next.js standalone container exposes
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

# Output the public URL of your application automatically
output "container_app_url" {
  value = "https://${azurerm_container_app.api.ingress[0].fqdn}"
}
