# VPC of the project
resource "aws_vpc" "vpc" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.prefix}-k3s-cluster"
  }
}

# Public subnet for the vpc
resource "aws_subnet" "subnet-public" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.1.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2c"
  tags = {
    Name = "${var.prefix}-subnet-public-dev"

    # Tags needed to create the np-AWS cluster
    Key   = "kubernetes.io/cluster/np"
    Value = "owned"
  }
}

# Private subnet for the nodes
resource "aws_subnet" "subnet-private" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2b"
  tags = {
    Name = "${var.prefix}-subnet-private-dev"

    # Tags needed to create the np-AWS cluster
    Key   = "kubernetes.io/cluster/np"
    Value = "owned"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = {
    Name = "${var.prefix}-rt-public-dev"
  }
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = {
    Name = "${var.prefix}-rt-private-dev"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}-ig-dev"
  }
}

# Route Table and public subnet association
resource "aws_route_table_association" "public-association" {
  subnet_id      = aws_subnet.subnet-public.id
  route_table_id = aws_route_table.public.id
}

# Route Table and private subnet association
resource "aws_route_table_association" "private-association" {
  subnet_id      = aws_subnet.subnet-private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}
