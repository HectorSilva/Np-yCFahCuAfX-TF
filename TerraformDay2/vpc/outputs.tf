output "vpc_subnet" {
  value = aws_subnet.subnet-private.id
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_subnets" {
  value = [aws_subnet.subnet-public.id]
}
