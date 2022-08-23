######################
##        VPC       ##
######################
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

######################
##     NODES        ##
######################
resource "aws_instance" "dev-node" {

  count = var.num_nodes # create similar EC2 instances

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet-public.id
  vpc_security_group_ids = [aws_security_group.sg-nodes.id]
  key_name               = "dev_nodes_key"

  tags = {
    Name = "np-node-dev${count.index}"
    # Tags to work properly with np-AWSs
    Key   = "kubernetes.io/cluster/np"
    Value = "owned"
  }
}

#########################
##   SECURITY GROUPS   ##
#########################
# Security group for the nodes
resource "aws_security_group" "sg-nodes" {

  # VPC to attach the sg
  vpc_id = aws_vpc.vpc.id

  description = "Fernando Silva"

  name = "np-sg-nodes"

  # HTTP access from the VPC
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress controller (HTTP)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Accepts all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Tags needed to create the np-AWS cluster
  tags = {
    Key   = "kubernetes.io/cluster/np"
    Value = "owned"
  }
}


#########################
##      AMIS           ##
#########################
# AMI for the nodes
# NOTE: The cluster needs instances with ubuntu 16+
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


#########################
##   LOAD BALANCER     ##
#########################
# LOAD BALANCER
resource "aws_lb" "npLB" {
  name               = "npLB"
  internal           = false
  load_balancer_type = "network"

  subnet_mapping {
    subnet_id = aws_instance.dev-node.0.subnet_id
  }

  enable_deletion_protection = false

  tags = {
    Environment = "dev"
  }
}

# TARGET GROUP FOR HTTPS
resource "aws_lb_target_group" "dev-tcp-443" {
  name     = "AWSnp-tcp-443"
  port     = 443
  protocol = "TCP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    protocol            = "HTTP"
    path                = "/healthz"
    port                = 80
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 6
    interval            = 10
    matcher             = "200-399"
  }

}

# TARGET GROUP FOR HTTP
resource "aws_lb_target_group" "dev-tcp-80" {
  name     = "AWSnp-tcp-80"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    protocol            = "HTTP"
    path                = "/healthz"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 6
    interval            = 10
    matcher             = "200-399"
  }
}

# TARGET GROUP FOR HTTP
resource "aws_lb_target_group" "dev-tcp-22" {
  name     = "AWSnp-tcp-80"
  port     = 22
  protocol = "TCP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    protocol            = "HTTP"
    path                = "/healthz"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 6
    interval            = 10
    matcher             = "200-399"
  }
}

# GROUP ATTACHEMENT TO LOAD BALANCER
# Attach the nodes to the created groups and attach them to the LB
resource "aws_lb_target_group_attachment" "tg-attach-tcp-443-1" {
  count            = length(aws_instance.dev-node.*.id)
  target_group_arn = aws_lb_target_group.dev-tcp-443.arn
  target_id        = element(aws_instance.dev-node.*.id, count.index)
  port             = 443
}

resource "aws_lb_target_group_attachment" "tg-attach-tcp-80-1" {
  count            = length(aws_instance.dev-node.*.id)
  target_group_arn = aws_lb_target_group.dev-tcp-80.arn
  target_id        = element(aws_instance.dev-node.*.id, count.index)
  port             = 80
}

resource "aws_lb_listener" "npLB-listerner-80" {
  load_balancer_arn = aws_lb.npLB.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev-tcp-80.arn
  }
}

resource "aws_lb_listener" "npLB-listerner-443" {
  load_balancer_arn = aws_lb.npLB.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev-tcp-443.arn
  }
}
