// Public IP's

// 3 IP's for use in the landing zones

resource "azurerm_public_ip" "lz-ip" {
  count               = 3
  name                = "lz-ip-${count.index + 1}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [count.index + 1]
}

// 1 for the NAT gateway

# resource "azurerm_public_ip" "nat-ip" {
#   name                = "nat-ip-1"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   allocation_method   = "Static"
#   sku                 = "Standard"
#   #zones = [count.index + 1]
# }

# // Setup the NAT Gateway

# resource "azurerm_nat_gateway" "app-gateway" {
#   name                = "nat-Gateway"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   #sku_name                = "Standard"
#   #zones                   = ["1"]
# }

# resource "azurerm_nat_gateway_public_ip_association" "gateway-ip" {
#   nat_gateway_id       = azurerm_nat_gateway.app-gateway.id
#   public_ip_address_id = azurerm_public_ip.nat-ip.id
# }


// App VM's

resource "azurerm_network_interface" "app-nic" {
  count               = 3
  name                = "app-nic-${count.index + 1}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.az[count.index].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "app" {
  count               = 3
  name                = "App-${count.index + 1}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"

  zone = count.index + 1

  network_interface_ids = [
    azurerm_network_interface.app-nic[count.index].id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = var.public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

// LZ VM's

# resource "azurerm_bastion_host" "lz_bastion" {
#   name                = "LZBastion"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name

#   ip_configuration {
#     name                 = "configuration"
#     subnet_id            = azurerm_subnet.lz_bastion.id
#     public_ip_address_id = azurerm_public_ip.lz-ip[0].id
#   }
# }


resource "azurerm_network_interface" "lz-nic" {
  name                = "lz-pub-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.lz_pub[0].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.lz-ip[0].id
  }
}

resource "azurerm_linux_virtual_machine" "lz" {
  name                = "LZBastion"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"

  #zone = count.index + 1

  network_interface_ids = [
    azurerm_network_interface.lz-nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = var.public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}



# // BZ VM's

# resource "azurerm_network_interface" "bz-nic" {
#   count               = 3
#   name                = "backend-nic-${count.index + 1}"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name

#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = azurerm_subnet.bz[count.index].id
#     private_ip_address_allocation = "Dynamic"
#     #public_ip_address_id          = azurerm_public_ip.lz-ip[count.index].id
#   }
# }

# resource "azurerm_linux_virtual_machine" "bz" {
#   count               = 3
#   name                = "backend-${count.index + 1}"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   size                = "Standard_B1s"
#   admin_username      = "adminuser"

#   zone = count.index + 1

#   network_interface_ids = [
#     azurerm_network_interface.bz-nic[count.index].id,
#   ]

#   admin_ssh_key {
#     username   = "adminuser"
#     public_key = var.public_key
#   }

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "UbuntuServer"
#     sku       = "18.04-LTS"
#     version   = "latest"
#   }
# }