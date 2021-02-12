terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.42.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "1.3.0"
    }
  }
  required_version = "~> 0.14"
}

provider "azurerm" {
  features {}
}

provider "azuread" {}
