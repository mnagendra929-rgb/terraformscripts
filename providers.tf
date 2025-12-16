terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id =  "18e529dd-c6c4-4a75-8808-53ced99b4efc"
}

data "azurerm_subscription" "current" {}
