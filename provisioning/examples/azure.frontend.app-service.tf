resource "azurerm_app_service_plan" "frontend" {
  name                = "${var.project_unique_id}-frontend"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "Linux"
  # See also https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_plan#argument-reference
  # > When creating a Linux App Service Plan, the reserved field must be set to true,
  reserved = true
  sku {
    # See also https://azure.microsoft.com/en-us/pricing/details/app-service/windows/#pricing
    # > The Basic service plan with Linux runtime environments supports Web App for Containers.
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "frontend" {
  name                = "${var.project_unique_id}-frontend"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_app_service_plan.frontend.id
  # See also https://github.com/hashicorp/terraform-provider-azurerm/blob/d50e6dd1b228363519b9357de8ada98dd3e22a87/internal/services/appservice/linux_function_app_data_source.go#L340
  # app_settings = {}
  site_config {
    # See also https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service#argument-reference
    linux_fx_version = "DOCKER|nginx"
  }
}
