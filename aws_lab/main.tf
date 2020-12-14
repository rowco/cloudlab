// Providers

provider "aws" {
    access_key = var.access_key
    secret_key = var.secret_key
    region     = var.region
}

data "aws_availability_zones" "available" {}

// VPC Provisioning

resource "aws_vpc" "lz_vpc" {
    cidr_block = var.lz_vpc
    enable_dns_hostnames = "true"
    tags = {
      "Name" = "Landing Zone"
    }
}
resource "aws_vpc" "az_vpc" {
    cidr_block = var.az_vpc
    enable_dns_hostnames = "true"
    tags = {
      "Name" = "Application Zone"
    }
}
resource "aws_vpc" "bz_vpc" {
    cidr_block = var.bz_vpc
    enable_dns_hostnames = "true"
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
    map_public_ip_on_launch = "true"
    availability_zone = data.aws_availability_zones.available.names[0]
    tags = {
      "Name" = "BZ-1"
    }
}
resource "aws_subnet" "bz_2" {
    cidr_block = cidrsubnet(var.bz_vpc,3,1)
    vpc_id = aws_vpc.bz_vpc.id
    map_public_ip_on_launch = "true"
    availability_zone = data.aws_availability_zones.available.names[1]
    tags = {
      "Name" = "BZ-2"
    }
}
resource "aws_subnet" "bz_3" {
    cidr_block = cidrsubnet(var.bz_vpc,3,2)
    vpc_id = aws_vpc.bz_vpc.id
    map_public_ip_on_launch = "true"
    availability_zone = data.aws_availability_zones.available.names[2]
    tags = {
      "Name" = "BZ-3"
    }
}