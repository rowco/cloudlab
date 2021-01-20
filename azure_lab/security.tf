resource "azurerm_network_security_group" "allow-ssh" {
  name                = "app-default"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}


resource "azurerm_network_security_rule" "ssh_rule" {
  name                        = "allowSSH"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  description                 = "Allow any to SSH"
  source_address_prefix       = "0.0.0.0/0"
  destination_address_prefix  = "0.0.0.0/0"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.allow-ssh.name
  priority                    = 100
}

# resource "azurerm_network_interface_security_group_association" "app-default" {
#     count = 3
#     network_interface_id          = azurerm_network_interface.app-nic[count.index].id
#     network_security_group_id = azurerm_network_security_group.app-default.id
# }

resource "azurerm_subnet_network_security_group_association" "app-default" {
  count                     = 3
  subnet_id                 = azurerm_subnet.az[count.index].id
  network_security_group_id = azurerm_network_security_group.allow-ssh.id
}

resource "azurerm_subnet_network_security_group_association" "lz-default" {
  subnet_id                 = azurerm_subnet.lz_pub[0].id
  network_security_group_id = azurerm_network_security_group.allow-ssh.id
}