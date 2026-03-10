# See https://www.terraform.io/language/settings/backends/azurerm
terraform {
  backend "azurerm" {
    container_name = "provisioning"
    key            = "default/terraform"
  }
}
