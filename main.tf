terraform {
  backend "remote" {
    organization = "example-org-dbf168"

    workspaces {
      name = "aspnet_sample-test"
    }
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }

  required_version = ">= 0.13.0"
}

provider "azurerm" {
  features {}
}

# Get data
data "azurerm_container_registry" "acr" {
  name                = "mbbacr"
  resource_group_name = "rg_witcs_common"
}

# Create a resource group
resource "azurerm_resource_group" "aspnet_sample" {
  name     = "rg_aspnet-sample"
  location = "West US"

  tags = var.tags
}

# Create an App Service Plan with Linux
resource "azurerm_app_service_plan" "asp" {
  name                = "aspnet-sample-asp"
  location            = azurerm_resource_group.aspnet_sample.location
  resource_group_name = azurerm_resource_group.aspnet_sample.name

  is_xenon = true

  # Choose size
  sku {
    tier = "PremiumV3"
    size = "P1v3"
  }

  tags = var.tags
}

# Create an Azure Web App for Containers in that App Service Plan
resource "azurerm_app_service" "app" {
  name                = "aspnet-sample-app"
  location            = azurerm_resource_group.aspnet_sample.location
  resource_group_name = azurerm_resource_group.aspnet_sample.name
  app_service_plan_id = azurerm_app_service_plan.asp.id

  https_only = true

  # Do not attach Storage by default
  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false

    # Settings for private Container Registires
    DOCKER_REGISTRY_SERVER_URL      = data.azurerm_container_registry.acr.login_server
    DOCKER_REGISTRY_SERVER_USERNAME = data.azurerm_container_registry.acr.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD = data.azurerm_container_registry.acr.admin_password
  }

  # Configure Docker Image to load on start
  site_config {
    windows_fx_version = "DOCKER|mcr.microsoft.com/azure-app-service/windows/parkingpage:latest"
    always_on          = "true"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags

  # Ignore ssl_state and thumbprint as they are managed using
  # azurerm_app_service_certificate_binding.example
  lifecycle {
    ignore_changes = [
      site_config["default_documents"],
      site_config["use_32_bit_worker_process"],
    ]
  }
}
