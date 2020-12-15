// Providers

provider "aws" {
    access_key = var.access_key
    secret_key = var.secret_key
    region     = var.region
}

data "aws_availability_zones" "available" {}

data "aws_ami" "aws-linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

// VPC Provisioning

resource "aws_vpc" "lz_vpc" {
    cidr_block = var.lz_vpc
    enable_dns_hostnames = "true"
    assign_generated_ipv6_cidr_block = true
    tags = {
      "Name" = "Landing Zone"
    }
}
resource "aws_vpc" "az_vpc" {
    cidr_block = var.az_vpc
    enable_dns_hostnames = "true"
    assign_generated_ipv6_cidr_block = true
    tags = {
      "Name" = "Application Zone"
    }
}
resource "aws_vpc" "bz_vpc" {
    cidr_block = var.bz_vpc
    enable_dns_hostnames = "true"
    assign_generated_ipv6_cidr_block = true
    tags = {
      "Name" = "Backend Zone"
    }
}

// Subnet Provisioning
// LZ
resource "aws_subnet" "lz_1" {
    cidr_block = cidrsubnet(var.lz_vpc,3,0)
    vpc_id = aws_vpc.lz_vpc.id
    map_public_ip_on_launch = "true"
    availability_zone = data.aws_availability_zones.available.names[0]
    tags = {
      "Name" = "LZ-1"
    }
}
resource "aws_subnet" "lz_2" {
    cidr_block = cidrsubnet(var.lz_vpc,3,1)
    vpc_id = aws_vpc.lz_vpc.id
    map_public_ip_on_launch = "true"
    availability_zone = data.aws_availability_zones.available.names[1]
    tags = {
      "Name" = "LZ-2"
    }
}
resource "aws_subnet" "lz_3" {
    cidr_block = cidrsubnet(var.lz_vpc,3,2)
    vpc_id = aws_vpc.lz_vpc.id
    map_public_ip_on_launch = "true"
    availability_zone = data.aws_availability_zones.available.names[2]
    tags = {
      "Name" = "LZ-3"
    }
}
// AZ
resource "aws_subnet" "az_1" {
    cidr_block = cidrsubnet(var.az_vpc,3,0)
    vpc_id = aws_vpc.az_vpc.id
    map_public_ip_on_launch = "true"
    availability_zone = data.aws_availability_zones.available.names[0]
    tags = {
      "Name" = "AZ-1"
    }
}
resource "aws_subnet" "az_2" {
    cidr_block = cidrsubnet(var.az_vpc,3,1)
    vpc_id = aws_vpc.az_vpc.id
    map_public_ip_on_launch = "true"
    availability_zone = data.aws_availability_zones.available.names[1]
    tags = {
      "Name" = "AZ-2"
    }
}
resource "aws_subnet" "az_3" {
    cidr_block = cidrsubnet(var.az_vpc,3,2)
    vpc_id = aws_vpc.az_vpc.id
    map_public_ip_on_launch = "true"
    availability_zone = data.aws_availability_zones.available.names[2]
    tags = {
      "Name" = "AZ-3"
    }
}
// BZ
resource "aws_subnet" "bz_1" {
    cidr_block = cidrsubnet(var.bz_vpc,3,0)
    vpc_id = aws_vpc.bz_vpc.id
    map_public_ip_on_launch = "false"
    assign_ipv6_address_on_creation = "true"
    ipv6_cidr_block = cidrsubnet(aws_vpc.bz_vpc.ipv6_cidr_block, 8, 0)
    availability_zone = data.aws_availability_zones.available.names[0]
    tags = {
      "Name" = "BZ-1"
    }
}
resource "aws_subnet" "bz_2" {
    cidr_block = cidrsubnet(var.bz_vpc,3,1)
    vpc_id = aws_vpc.bz_vpc.id
    map_public_ip_on_launch = "false"
    assign_ipv6_address_on_creation = "true"
    ipv6_cidr_block = cidrsubnet(aws_vpc.bz_vpc.ipv6_cidr_block, 8, 1)
    availability_zone = data.aws_availability_zones.available.names[1]
    tags = {
      "Name" = "BZ-2"
    }
}
resource "aws_subnet" "bz_3" {
    cidr_block = cidrsubnet(var.bz_vpc,3,2)
    vpc_id = aws_vpc.bz_vpc.id
    map_public_ip_on_launch = "false"
    assign_ipv6_address_on_creation = "true"
    ipv6_cidr_block = cidrsubnet(aws_vpc.bz_vpc.ipv6_cidr_block, 8, 2)
    availability_zone = data.aws_availability_zones.available.names[2]
    tags = {
      "Name" = "BZ-3"
    }
}


// Internet gateway

resource "aws_internet_gateway" "lz_gateway" {
  vpc_id = aws_vpc.lz_vpc.id
}

resource "aws_internet_gateway" "az_gateway" {
  vpc_id = aws_vpc.az_vpc.id
}

resource "aws_egress_only_internet_gateway" "bz_gateway" {
  vpc_id = aws_vpc.bz_vpc.id
}

// VPC peering

resource "aws_vpc_peering_connection" "az_bz" {
    peer_vpc_id = aws_vpc.az_vpc.id
    vpc_id      = aws_vpc.bz_vpc.id
    auto_accept = true

    accepter {
        allow_remote_vpc_dns_resolution = true
    }
    requester {
        allow_remote_vpc_dns_resolution = true
    }

    tags = {
        Name = "App Zone to Backend Zone Peering"
    }
}

resource "aws_vpc_peering_connection" "lz_az" {
    peer_vpc_id = aws_vpc.lz_vpc.id
    vpc_id      = aws_vpc.az_vpc.id
    auto_accept = true

    accepter {
        allow_remote_vpc_dns_resolution = true
    }
    requester {
        allow_remote_vpc_dns_resolution = true
    }

    tags = {
        Name = "Landing Zone to App Zone Peering"
    }
}

// Routing

// Backend Zone routes via the App Zone peering
resource "aws_route_table" "bz_routes" {
    vpc_id = aws_vpc.bz_vpc.id
    route {
        ipv6_cidr_block = "::/0"
        egress_only_gateway_id = aws_egress_only_internet_gateway.bz_gateway.id
    }
    route {
        cidr_block = var.az_vpc
        vpc_peering_connection_id = aws_vpc_peering_connection.az_bz.id
    }
    route {
        cidr_block = var.lz_vpc
        vpc_peering_connection_id = aws_vpc_peering_connection.az_bz.id
    }
}

resource "aws_route_table_association" "bz_1_routes" {
    subnet_id = aws_subnet.bz_1.id
    route_table_id = aws_route_table.bz_routes.id
}
resource "aws_route_table_association" "bz_2_routes" {
    subnet_id = aws_subnet.bz_2.id
    route_table_id = aws_route_table.bz_routes.id
}
resource "aws_route_table_association" "bz_3_routes" {
    subnet_id = aws_subnet.bz_3.id
    route_table_id = aws_route_table.bz_routes.id
}

// App Zone sits between Landing zone and Backend zone
resource "aws_route_table" "az_routes" {
    vpc_id = aws_vpc.az_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.az_gateway.id
    }
    route {
        cidr_block = var.lz_vpc
        vpc_peering_connection_id = aws_vpc_peering_connection.lz_az.id
    }
    route {
        cidr_block = var.bz_vpc
        vpc_peering_connection_id = aws_vpc_peering_connection.az_bz.id
    }
}

resource "aws_route_table_association" "az_1_routes" {
    subnet_id = aws_subnet.az_1.id
    route_table_id = aws_route_table.az_routes.id
}
resource "aws_route_table_association" "az_2_routes" {
    subnet_id = aws_subnet.az_2.id
    route_table_id = aws_route_table.az_routes.id
}
resource "aws_route_table_association" "az_3_routes" {
    subnet_id = aws_subnet.az_3.id
    route_table_id = aws_route_table.az_routes.id
}


// Backend Zone routes via the App Zone peering
resource "aws_route_table" "lz_routes" {
    vpc_id = aws_vpc.lz_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.lz_gateway.id
    }
    route {
        cidr_block = var.az_vpc
        vpc_peering_connection_id = aws_vpc_peering_connection.lz_az.id
    }
}

resource "aws_route_table_association" "lz_1_routes" {
    subnet_id = aws_subnet.lz_1.id
    route_table_id = aws_route_table.lz_routes.id
}
resource "aws_route_table_association" "lz_2_routes" {
    subnet_id = aws_subnet.lz_2.id
    route_table_id = aws_route_table.lz_routes.id
}
resource "aws_route_table_association" "lz_3_routes" {
    subnet_id = aws_subnet.lz_3.id
    route_table_id = aws_route_table.lz_routes.id
}