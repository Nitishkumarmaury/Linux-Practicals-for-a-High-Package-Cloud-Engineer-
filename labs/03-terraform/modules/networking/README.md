# VPC and Network Infrastructure Module

This module creates the networking infrastructure for the application including VPC, subnets, and security groups.

## Features
- Multi-AZ VPC setup
- Public and private subnets
- NAT Gateway for private subnet access
- Security group configuration
- VPC endpoints for AWS services

## Usage
```hcl
module "networking" {
  source = "./modules/networking"

  environment     = "dev"
  vpc_cidr        = "10.0.0.0/16"
  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_cidr | The CIDR block for the VPC | string | n/a | yes |
| environment | Environment name | string | n/a | yes |
| azs | Availability zones | list(string) | n/a | yes |
| private_subnets | Private subnet CIDR blocks | list(string) | n/a | yes |
| public_subnets | Public subnet CIDR blocks | list(string) | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| private_subnet_ids | List of private subnet IDs |
| public_subnet_ids | List of public subnet IDs |
| web_security_group_id | ID of the web security group |