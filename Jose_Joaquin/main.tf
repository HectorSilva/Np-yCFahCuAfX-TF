/*
*******************************
***         Provider        ***
*******************************
*/

provider "aws" {
  region     = "us-east-1"
  access_key = ""
  secret_key = ""
}

/*
*******************************
***         Networking      ***
*******************************
*/

# Create a VPC

resource "aws_vpc" "example" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    enviroment = "dev"
    cost       = "chepe"
  }
}

# Create Subnet
resource "aws_subnet" "subnet-public" {
  vpc_id                  = aws_vpc.vpc.id # Hace referencia al id del VPC que acabamos de crear
  cidr_block              = "10.1.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2c"
  tags = {
    Name = "Dev-subnet-public"
  }
}

resource "aws_subnet" "subnet-private" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "us-west-2b"
  tags = {
    Name = "Dev-subnet-private"
  }
}