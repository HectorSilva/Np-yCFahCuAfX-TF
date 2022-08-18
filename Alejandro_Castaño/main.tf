# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
provider "aws" {
  region     = "us-east-1"
  access_key = ""
}

# Create a VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    name = "poc"
  }
}
# Create a subnet public
resource "aws_subnet" "snetpublic" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.1.0.0/24"
  availability_zone = "us-west-2c"
  tags = {
    name = "subnet_public"
  }
}

# Create a subnet private
resource "aws_subnet" "snetprivate" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "us-west-2b"
  tags = {
    name = "subnet_private"
  }
}
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    name = "internet_gateway"
  }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/"
    gateway_id = ""
  }
}
