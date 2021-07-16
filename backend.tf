terraform {
  backend "remote" {
    hostname              = "app.terraform.io"
    organization          = "CloudNinja-Sample"

    workspaces {
      prefix              = "aspnet_sample-"
    }
  }

  # We strongly recommend using the required_providers block to set the
  # Azure Provider source and version being used
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }

  required_version = ">= 0.13.0"
}
