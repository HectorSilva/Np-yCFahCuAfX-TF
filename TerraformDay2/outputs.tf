# Output values
output "nodes_public_ips" {
  value       = module.nodes.instance_ip4p
  description = "The public IP addresses of the desired nodes"
}
