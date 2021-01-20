


# resource "azurerm_virtual_network_peering" "bz_az" {
#   name                      = "bz_to_az"
#   resource_group_name       = azurerm_resource_group.rg.name
#   virtual_network_name      = azurerm_virtual_network.bz_vpc.name
#   remote_virtual_network_id = azurerm_virtual_network.az_vpc.id
#   allow_virtual_network_access = "true"
#   allow_forwarded_traffic = "true"
#   allow_gateway_transit = "true"
#   #use_remote_gateways  = "true"
# }

resource "azurerm_virtual_network_peering" "az_lz" {
  name                      = "az_to_lz"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.az_vpc.name
  remote_virtual_network_id = azurerm_virtual_network.lz_vpc.id
  allow_virtual_network_access = "true"
  allow_forwarded_traffic = "false"
  allow_gateway_transit = "false"
  #use_remote_gateways  = "true"
}

resource "azurerm_virtual_network_peering" "lz_az" {
  name                      = "lz_to_az"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.lz_vpc.name
  remote_virtual_network_id = azurerm_virtual_network.az_vpc.id
  allow_virtual_network_access = "true"
  allow_forwarded_traffic = "false"
  allow_gateway_transit = "false"
  #use_remote_gateways  = "true"
}