//********************************************
# Configure the AWS Provider
//********************************************
provider "aws" {
  access_key = ""
  region     = ""
}

//**********************************************
# Create a VPC
//*********************************************
resource "aws_vpc" "vpctask1" {
  cidr_block           = "10.4.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name       = "vpc_task1"
    enviroment = "dev"
  }
}
//********************************************
#  Create subnets
//*******************************************
resource "aws_subnet" "subtask1-public" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.4.1.0/24"
  map_public_ip_on_launch = true
  availiability_zone      = "us-west-2c"

  tags = {
    Name        = "subnet_task1-public"
    environment = "dev"
  }
}
  resource "aws_subnet" "subtask1-privada" {
    vpc_id             = aws_vpc.vpc.id
    cidr_block         = "10.4.2.0/24"
    availiability_zone = "us-west-2b"

    tags = {
      Name        = "subnet_task1-privada"
      environment = "dev"
    }
  }

/***************************************
# Create gateway
/***************************************
resource "aws_gateway" "gateway_task " {
  vpc_id                  = aws_vpc.vpc.id
   availiability_zone      = "us-west-2c"

  tags = {
    Name        = "subnet_task1-public"
    environment = "dev"
  }

  /***************************************
  #create route table
  /***************************************
 
resource "aws_route_table" "route_private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/"
    gateway_id = aws_internet_gateway.gateway.id
  }
  tags = {
    Name        = "route_task1-private"
    environment = "dev"
  }
 }

resource "aws_route_table" "route_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = {
    Name = "route_task1_public"
  }
}

resource "aws_route_table_association" "public-association" {
    subnet_id = aws_subnet.subnet-public.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private-association" {
    subnet_id = aws_subnet.subnet-private.id
    route_table_id = aws_route_table.private.id
}
