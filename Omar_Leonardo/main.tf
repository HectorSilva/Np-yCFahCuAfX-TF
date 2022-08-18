
/*** Provider ***/

provider "aws" {
  access_key = ""
  region     = ""
}


/*** VPC ***/

resource "aws_vpc" "vpc" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Dev-vpc"
  }
}

resource "aws_subnet" "subnet_public" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.1.0.0/24"
  map_public_ip_on_launch = true
  avalavility_zone        = "us-west-2c"
  tags = {
    Name = "Dev-subnet-public"
  }
}

resource "aws_subnet" "subnet-private" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "us-west-2b"
  tags = {
    Name = "Dev-subnet-private"
  }
}

resource "aws_internet_gateway "gateway"{
  vpc_id = aws_vpc.vpv.id

  tags = {
    Name = 
  }
}

resource "aws_route_table" "public"{
  vcp_id =  aws_vpc.vpc.vpc.id
}