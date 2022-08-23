# Create the nodes with the required configuration
module "nodes" {
  source         = "./nodes"
  num_nodes      = var.num_nodes
  nodes_key      = file("${path.module}/dev_nodes_key.pub")
  nodes_key_name = "dev_nodes_key"
}

# Create the load balancer and associate it with the nodes
module "load_balancer" {
  source = "./load_balancer"
  vpc_id = module.nodes.vpc_id
  subnet = module.nodes.subnets_id[0]
  nodes  = module.nodes.instance_id
}
