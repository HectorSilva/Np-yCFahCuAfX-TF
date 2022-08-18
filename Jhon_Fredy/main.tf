# Configure Provider

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.26.0"
    }
  }
}

provider "aws" {
  access_key = ""
  region     = ""
}
# Create VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    name = "Dev-vpc"
  }
}

# Create Subnet Pulic

resource "aws_subnet" "subnet-public" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.1.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us_west-2c"
  tags = {
    name = "Dev-subnet-public"
  }
}

# Create Subnet Private

resource "aws_subnet" "subnet-private" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us_west-2b"
  tags = {
    name = "Dev-subnet-private"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    name = "gateway"
  }
}

# create route tables

recosrce "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = {
    Name = "private-rt"
  }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = {
    name = "public-rt"
  }
}

resource "aws_route_table_association" "public-association" {
  subnet_id      = aws_subnet.subnet-public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private-association" {
  subnet_id      = aws_subnet.subnet-private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route" "public" {
  route_table_id         = aws_routee_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}
