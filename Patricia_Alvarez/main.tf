provider "aws" {
  access_key = "12345poc"
  region     = ""
}
/**** VPC
*/

#create VPC

resource "aws_vpc" "vpc_1" {
  cidr_block = "10.4.0.0/16"
}

tags = {
  Name = "VPC_Dev"
}

resource "aws_subnet" "subnet_private" {
  cidr_block        = "10.4.1.0/24"
  reservation_type  = "prefix"
  subnet_id         = aws_subnet.example.id
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-west-2c"
}

resource "aws_subnet" "subnet_public" {
  cidr_block        = "10.4.2.16/24"
  reservation_type  = "prefix"
  subnet_id         = aws_subnet.example.id
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-west-2c"
}
