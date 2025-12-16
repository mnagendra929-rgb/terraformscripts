variable "resource_group_name" {
  type =  string
 }
variable "location" {
  type = string
 }

variable "hub_vnet_prefix" { }
variable "test_vnet_prefix" { }

variable "application_gateway_name" { }

variable "app_service_plan_sku" {
  type = object({
    tier = string
    size = string
  })
}

variable "sql_admin_user" { }
variable "sql_admin_password" {
  sensitive = true
}
