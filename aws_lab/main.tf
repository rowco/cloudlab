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
    cidr_block = cidrsubnet(var.lz_vpc,3,0)
    vpc_id = aws_vpc.lz_vpc.id
    map_public_ip_on_launch = "true"
    availability_zone = data.aws_availability_zones.available.names[0]
    tags = {
      "Name" = "LZ"
    }
}
// LZ PRIV
resource "aws_subnet" "lz_priv" {
    count = 2
    cidr_block = cidrsubnet(var.lz_vpc,3,count.index + 1)
    vpc_id = aws_vpc.lz_vpc.id
    availability_zone = data.aws_availability_zones.available.names[count.index + 1]
    tags = {
      "Name" = "LZ-PRIV-${count.index + 1}"
    }
}
// LZ PUB
resource "aws_subnet" "lz_pub" {
    count = 2
    cidr_block = cidrsubnet(var.lz_vpc,3,count.index + 3)
    vpc_id = aws_vpc.lz_vpc.id
    map_public_ip_on_launch = "true"
    availability_zone = data.aws_availability_zones.available.names[count.index + 1]
    tags = {
      "Name" = "LZ-PUB-${count.index + 1}"
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

# resource "aws_internet_gateway" "az_gateway" {
#   vpc_id = aws_vpc.az_vpc.id
# }

# resource "aws_egress_only_internet_gateway" "bz_gateway" {
#   vpc_id = aws_vpc.bz_vpc.id
# }

// Transit Gateways

resource "aws_ec2_transit_gateway" "tgw" {
  description = "Transit gateway for ${var.region}"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
}

# // Attach the transit gateway to the lz subnet
# resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_lz_admin" {

#   subnet_ids         = [ aws_subnet.lz.id ]
#   transit_gateway_id = aws_ec2_transit_gateway.tgw.id
#   vpc_id             = aws_vpc.lz_vpc.id
#   transit_gateway_default_route_table_association = "false"
#   transit_gateway_default_route_table_propagation = "false"  

# }


// Attach the transit gateway to the lz_priv subnets
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_lz" {

  subnet_ids         = aws_subnet.lz_priv.*.id
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.lz_vpc.id
  transit_gateway_default_route_table_association = "false"
  transit_gateway_default_route_table_propagation = "false"  

}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_az" {

  subnet_ids         = aws_subnet.az.*.id
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.az_vpc.id
  transit_gateway_default_route_table_association = "false"
  transit_gateway_default_route_table_propagation = "false"  
}

resource "aws_ec2_transit_gateway_route_table" "tgw_rt_main" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw_rt_main_lz" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_lz.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rt_main.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_rt_main_lz_prp" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_lz.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rt_main.id
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw_rt_main_az" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_az.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rt_main.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_rt_main_az_prp" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_az.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rt_main.id
}

resource "aws_ec2_transit_gateway_route" "tgw_rt_main_dfr" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_lz.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rt_main.id
}

resource "aws_ec2_transit_gateway_route" "tgw_rt_main_prv" {
  destination_cidr_block         = "10.0.0.0/8"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_az.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rt_main.id
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

# resource "aws_vpc_peering_connection" "lz_az" {
#     peer_vpc_id = aws_vpc.lz_vpc.id
#     vpc_id      = aws_vpc.az_vpc.id
#     auto_accept = true

#     accepter {
#         allow_remote_vpc_dns_resolution = true
#     }
#     requester {
#         allow_remote_vpc_dns_resolution = true
#     }

#     tags = {
#         Name = "Landing Zone to App Zone Peering"
#     }
# }
