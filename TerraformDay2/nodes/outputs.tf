# Output values
output "instance_ip4p" {
  value = aws_instance.dev-node.*.public_ip
}

output "instance_id" {
  value = aws_instance.dev-node.*.id
}

output "subnets_id" {
  value = aws_instance.dev-node.*.subnet_id
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "ssh_key" {
  value = var.nodes_key_name
}

output "private_key" {
  value = var.nodes_key
}
