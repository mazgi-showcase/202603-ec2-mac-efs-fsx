resource "azurerm_virtual_network" "main" {
  name                = "${var.project_unique_id}-main"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = {}
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet0" {
  name                 = "${var.project_unique_id}-main-subnet0"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "subnet0" {
  subnet_id                 = azurerm_subnet.subnet0.id
  network_security_group_id = azurerm_network_security_group.main.id
}
