output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "nat_gateway_ids" {
  description = "List of IDs of NAT gateways"
  value       = aws_nat_gateway.main[*].id
}

output "default_security_group_id" {
  description = "The ID of the default security group"
  value       = aws_security_group.default.id
}

output "web_security_group_id" {
  description = "The ID of the web security group"
  value       = aws_security_group.web.id
}