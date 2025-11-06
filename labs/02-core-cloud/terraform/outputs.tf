output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "web_security_group_id" {
  description = "ID of web server security group"
  value       = aws_security_group.web.id
}

output "web_instance_public_ip" {
  description = "Public IP of web server"
  value       = aws_instance.web.public_ip
}

output "s3_bucket_name" {
  description = "Name of created S3 bucket"
  value       = aws_s3_bucket.storage.id
}