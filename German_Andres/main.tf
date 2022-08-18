###################
# PROVIDER
###################
provider "aws" {
  region     = ""
  access_key = ""
}

####################
#  VPC
####################

resource "aws_vpc" "vpc" {
  cidr_block          = "10.7.0.0/16"
  enable_dns_support  = true
  enable_dns_hostname = true

  tags = {
    name = "dev"

  }
}

resource "aws_subnet" "subnet-public" {
    vpc_id = vpc.vpc.id
    cidr_block          = "10.7.0.0/24"
    map_public_ip_on_launch = true
    availability_zone_id = 