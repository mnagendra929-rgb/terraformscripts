resource_group_name = "newprojectrg"
location            = "canadacentral"

hub_vnet_prefix  = "10.0.77.0/24"
test_vnet_prefix = "10.0.55.0/24"

application_gateway_name = "hub-app-gateway"

# Must be single SKU string like B1, P1v2, S1, etc.
app_service_plan_sku = {
  tier = "B"
  size = "1"
}


sql_admin_user     = "sqladminuser"
sql_admin_password = "StrongPassword@123!"
