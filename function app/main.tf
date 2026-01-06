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
  subscription_id = "804713df-4f23-407e-b4c4-483ea265aee2"
}

data "azurerm_subscription" "current" {}


resource "azurerm_resource_group" "rgblock" {

  name     = "terraRg"
  location = "canadacentral"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  resource_group_name = azurerm_resource_group.rgblock.name
  location            = azurerm_resource_group.rgblock.location
  address_space       = ["10.0.77.0/24"]

}

resource "azurerm_subnet" "subnetblock" {
  name                 = "pzi-sbu-subnet-001"
  resource_group_name  = azurerm_resource_group.rgblock.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.77.0/27"]
  service_endpoints = [
    "Microsoft.Storage"
  ]

}

resource "azurerm_network_security_group" "nsg1" {

  name                = "nsg1"
  resource_group_name = azurerm_resource_group.rgblock.name
  location            = azurerm_resource_group.rgblock.location
}

resource "azurerm_subnet_network_security_group_association" "network" {

  network_security_group_id = azurerm_network_security_group.nsg1.id
  subnet_id                 = azurerm_subnet.subnetblock.id
}

resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "Allowtraffic"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rgblock.name
  network_security_group_name = azurerm_network_security_group.nsg1.name
}

resource "azurerm_storage_account" "storageblock" {
  name                     = "sgttyoughi005"
  resource_group_name      = azurerm_resource_group.rgblock.name
  location                 = azurerm_resource_group.rgblock.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.subnetblock.id]
    bypass                     = ["AzureServices"]
    ip_rules = local.webapp_outbound_ips

  }
}
resource "azurerm_service_plan" "asp" {
  name                = "asp-webapp-demo"
  resource_group_name = azurerm_resource_group.rgblock.name
  location            = azurerm_resource_group.rgblock.location
  os_type             = "Windows"
  sku_name            = "B1"
}
resource "azurerm_windows_web_app" "webapp" {
  name                = "win-webapp-demo-xyz123"
  resource_group_name = azurerm_resource_group.rgblock.name
  location            = azurerm_resource_group.rgblock.location
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {
    always_on = true

    application_stack {
      current_stack = "dotnet"
      dotnet_version = "v6.0"
    }
  }
}
locals {
  webapp_outbound_ips = distinct(concat(
    split(",", azurerm_windows_web_app.webapp.outbound_ip_addresses),
    split(",", azurerm_windows_web_app.webapp.possible_outbound_ip_addresses)
  ))
}

resource "azurerm_app_service_plan" "sgttyoughi" {
  name                = "azure-functions-test-service-plan"
  location            = azurerm_resource_group.rgblock.location
  resource_group_name = azurerm_resource_group.rgblock.name
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "sgttyoughi005" {
  name                       = "sgttyoughi005"
  location                   = azurerm_resource_group.rgblock.location
  resource_group_name        = azurerm_resource_group.rgblock.name
  app_service_plan_id        = azurerm_app_service_plan.sgttyoughi.id
  storage_account_name       = azurerm_storage_account.storageblock.name
  storage_account_access_key = azurerm_storage_account.storageblock.primary_access_key
}