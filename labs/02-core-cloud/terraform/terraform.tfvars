# Environment-specific variables
aws_region = "us-east-1"
environment = "prod"

# Network configuration
vpc_cidr = "10.0.0.0/16"
public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.10.0/24", "10.0.11.0/24"]
availability_zones = ["us-east-1a", "us-east-1b"]

# EC2 configuration
instance_type = "t2.micro"
key_name = "your-key-name"  # Replace with your SSH key pair name
admin_ip = "YOUR_IP/32"     # Replace with your IP address

# S3 configuration
bucket_name = "your-unique-bucket-name"  # Must be globally unique