/************  PROVIDER  ***********/
provider "aws" {
    regio  = ""
    access_key  = ""
}
/************  VPC  ***********/
resource "aws_vpc" "vpc"{
    cidr_block = "10.1.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        Name = "Dev"
    }
}
/************  SUBNET PUBLIC ***********/
resource "aws_subnet" "subnet_public"{
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.1.0.0/24"
    map_public_ip_on_launch = true
    availability_zone = "us-west-2c"
    tags = {
        Name = "Dev_subnet_public"
    }
}
/************  SUBNET PRIVATE ***********/
resource "aws_subnet" "subnet_private"{
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.1.1.0/24"
    map_public_ip_on_launch = true
    availability_zone = "us-west-2b"
    tags = {
        Name = "Dev_subnet_private"
    }
}
/************  INTERNET GATEWAY ***********/

resource "aws_internet_gateway" "gateway"{
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = "gateway"
    }
}
resource "aws_route_table" "public"{
    vpc_id = aws_vpc.vpc.id

    route = {
        cidr_block = "0.0.0.0/"
        gateway_id=aws_internet_gateway
        }
    }

/************  ROUTE TABLE ***********/

resource "aws_route_table" ""{
    vpc_id = aws_vpc.vpc.id

    route = {
        cidr_block = "0.0.0.0/"
        gateway_id=aws_internet_gateway.gateway.id
        }

         tags = {
        Name = "private_rt"
    }
  }

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = {
    Name = "public-rt"
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
resource "aws_route" "public" {
    route_table_id = aws_routee_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id =  aws_internet_gateway.gateway.id
}

      

