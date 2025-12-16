module "hub" {
  source                   = "./modules/hub"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  hub_vnet_prefix          = var.hub_vnet_prefix
  application_gateway_name = var.application_gateway_name
}

module "test" {
  source               = "./modules/test"
  resource_group_name  = var.resource_group_name
  location             = var.location
  test_vnet_prefix     = var.test_vnet_prefix
  app_service_plan_sku = var.app_service_plan_sku
}

module "sql" {
  source               = "./modules/sql"
  resource_group_name  = var.resource_group_name
  location             = var.location
  sql_admin_user       = var.sql_admin_user
  sql_admin_password   = var.sql_admin_password
}

# ---------------------------
# Two-way VNet Peering
# ---------------------------

resource "azurerm_virtual_network_peering" "hub_to_test" {
  name                      = "hub-to-test"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = "hub-vnet"
  remote_virtual_network_id = module.test.vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "test_to_hub" {
  name                      = "test-to-hub"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = "test-vnet"
  remote_virtual_network_id = module.hub.vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}
