# Output values
output "nodes_public_ips" {
  value       = aws_instance.dev-node.*.public_ip
  description = "The public IP addresses of the desired nodes"
}
