#========= Usage
#module "nodes" {
#  source       = "../modules/nodes"
#  num_nodes    = 3
#}

#========= Modules

module "ami" {
  source = "./ami"
}

module "vpc" {
  source = "../vpc"
  prefix = "dev_VPC"
}

module "security_group" {
  source = "./security_group"
  vpc_id = module.vpc.vpc_id
}

resource "aws_key_pair" "nodes_key" {
  key_name   = var.nodes_key_name
  public_key = var.nodes_key
}



#========= End Modules
resource "aws_instance" "dev-node" {

  count = var.num_nodes # create similar EC2 instances

  ami                    = module.ami.ami_id
  instance_type          = "t2.micro"
  subnet_id              = module.vpc.vpc_subnets[0]
  vpc_security_group_ids = [module.security_group.sg_id]
  key_name               = aws_key_pair.nodes_key.key_name

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("${path.module}/dev_nodes_key.pem")
  }

  provisioner "file" {
    source      = "${path.module}/files/docker-compose.yaml"
    destination = "docker-compose.yaml"
  }

  user_data = templatefile("${path.module}/files/cloud-config.sh", {})

  tags = {
    Name = "np-node-dev${count.index}"
    # Tags to work properly with np-AWSs
    Key   = "kubernetes.io/cluster/np"
    Value = "owned"
  }
}

