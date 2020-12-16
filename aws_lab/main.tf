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
resource "aws_subnet" "lz" {
    count = 3
    cidr_block = cidrsubnet(var.lz_vpc,3,count.index)
    vpc_id = aws_vpc.lz_vpc.id
    map_public_ip_on_launch = "true"
    availability_zone = data.aws_availability_zones.available.names[count.index]
    tags = {
      "Name" = "LZ-${count.index + 1}"
    }
}

// AZ
resource "aws_subnet" "az" {
    count = 3
    cidr_block = cidrsubnet(var.az_vpc,3,count.index)
    vpc_id = aws_vpc.az_vpc.id
    map_public_ip_on_launch = "true"
    availability_zone = data.aws_availability_zones.available.names[count.index]
    tags = {
      "Name" = "AZ-${count.index + 1}"
    }
}

// BZ
resource "aws_subnet" "bz" {
    count = 3
    cidr_block = cidrsubnet(var.bz_vpc,3,count.index)
    vpc_id = aws_vpc.bz_vpc.id
    map_public_ip_on_launch = "false"
    assign_ipv6_address_on_creation = "true"
    ipv6_cidr_block = cidrsubnet(aws_vpc.bz_vpc.ipv6_cidr_block, 8, count.index)
    availability_zone = data.aws_availability_zones.available.names[count.index]
    tags = {
      "Name" = "BZ-${count.index + 1}"
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

resource "aws_route_table_association" "bz_routes" {
    count = 3
    subnet_id = aws_subnet.bz[count.index].id
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

resource "aws_route_table_association" "az_routes" {
    count = 3
    subnet_id = aws_subnet.az[count.index].id
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
    count = 3
    subnet_id = aws_subnet.lz[count.index].id
    route_table_id = aws_route_table.lz_routes.id
}
