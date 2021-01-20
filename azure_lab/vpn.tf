
resource "azurerm_public_ip" "vpn-ip" {
  name                = "VPN-IP"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
  #sku                 = "Standard"
}

resource "azurerm_subnet" "lz_gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.lz_vpc.name
  address_prefixes     = [cidrsubnet(var.lz_vpc, 3, 4)]
}

resource "azurerm_local_network_gateway" "aws" {
  name                = "aws"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  gateway_address     = "168.62.225.23"
  address_space       = ["10.100.0.0/16"]
}

resource "azurerm_virtual_network_gateway" "aws" {
  name                = "aws-gateway"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"
  // https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpngateways

  ip_configuration {
    public_ip_address_id          = azurerm_public_ip.vpn-ip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.lz_gateway.id
  }
}

resource "azurerm_virtual_network_gateway_connection" "aws" {
  name                = "aws-connection"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.aws.id
  local_network_gateway_id   = azurerm_local_network_gateway.aws.id

  shared_key = "4-v3ry-53cr37-1p53c-5h4r3d-k3y"
}