resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_unique_id}-main"
  location = var.azure_default_location
}
