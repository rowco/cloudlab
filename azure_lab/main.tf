
provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "cloudlab"
  location = var.region
}

resource "azurerm_virtual_network" "lz_vpc" {
  name                = "LandingZone"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.lz_vpc]
}
resource "azurerm_virtual_network" "az_vpc" {
  name                = "ApplicationZone"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.az_vpc]
}
resource "azurerm_virtual_network" "bz_vpc" {
  name                = "BackendZone"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.bz_vpc]
}


resource "azurerm_subnet" "lz_pub" {
  count                = 2
  name                 = "LZ-PUB-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.lz_vpc.name
  address_prefixes     = [cidrsubnet(var.lz_vpc, 3, count.index)]
}

resource "azurerm_subnet" "lz_priv" {
  count                = 2
  name                 = "LZ-PRIV-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.lz_vpc.name
  address_prefixes     = [cidrsubnet(var.lz_vpc, 3, count.index + 2)]
}

resource "azurerm_subnet" "az" {
  count                = 3
  name                 = "AZ-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.az_vpc.name
  address_prefixes     = [cidrsubnet(var.az_vpc, 3, count.index)]
}
