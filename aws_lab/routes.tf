
// Routing

// Backend Zone routes via the App Zone peering
resource "aws_route_table" "bz_routes" {
  vpc_id = aws_vpc.bz_vpc.id
  // default route towards the az_bz peering
  route {
    cidr_block                = "0.0.0.0/0"
    vpc_peering_connection_id = aws_vpc_peering_connection.az_bz.id
  }
}

resource "aws_route_table_association" "bz_routes" {
  count          = 3
  subnet_id      = aws_subnet.bz[count.index].id
  route_table_id = aws_route_table.bz_routes.id
}

// App Zone sits between Landing zone and Backend zone
resource "aws_route_table" "az_routes" {
  vpc_id = aws_vpc.az_vpc.id
  // default route towards transit gateway
  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
  // lz block towards transit gateway
  route {
    cidr_block         = var.lz_vpc
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
  // bz block towards the az_bz peering
  route {
    cidr_block                = var.bz_vpc
    vpc_peering_connection_id = aws_vpc_peering_connection.az_bz.id
  }
}

resource "aws_route_table_association" "az_routes" {
  count          = 3
  subnet_id      = aws_subnet.az[count.index].id
  route_table_id = aws_route_table.az_routes.id
}



// Specific routing table for the LZ subnet
resource "aws_route_table" "lz_routes" {
  vpc_id = aws_vpc.lz_vpc.id
  // default route towards the internet gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lz_gateway.id
  }
  // internal routes towards the transit gateway
  route {
    cidr_block         = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
}

resource "aws_route_table_association" "lz_routes" {
  subnet_id      = aws_subnet.lz.id
  route_table_id = aws_route_table.lz_routes.id
}


// LZ PRIV routing tables
resource "aws_route_table" "lz_priv_routes" {
  count  = 2
  vpc_id = aws_vpc.lz_vpc.id
  // default route towards the nat instance
  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = aws_instance.nat[count.index].id
  }
  // internal routes towards the transit gateway
  route {
    cidr_block         = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
}

resource "aws_route_table_association" "lz_priv_routes" {
  count          = 2
  subnet_id      = aws_subnet.lz_priv[count.index].id
  route_table_id = aws_route_table.lz_priv_routes[count.index].id
}

// LZ PUB routing tables
resource "aws_route_table" "lz_pub_routes" {
  count  = 2
  vpc_id = aws_vpc.lz_vpc.id
  // default route towards the nat instance
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lz_gateway.id
  }
  // internal routes towards the transit gateway
  route {
    cidr_block         = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
}

resource "aws_route_table_association" "lz_pub_routes" {
  count          = 2
  subnet_id      = aws_subnet.lz_pub[count.index].id
  route_table_id = aws_route_table.lz_pub_routes[count.index].id
}
