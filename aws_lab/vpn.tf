


resource "aws_customer_gateway" "azure" {
  bgp_asn    = 65000
  ip_address = "51.140.108.64"
  type       = "ipsec.1"
}

resource "aws_vpn_connection" "azure" {
  transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
  customer_gateway_id = aws_customer_gateway.azure.id
  type                = aws_customer_gateway.azure.type
  static_routes_only = true
  //tunnel1_preshared_key = "4-v3ry-53cr37-1p53c-5h4r3d-k3y"
  //tunnel1_ike_versions = "ikev2"
}