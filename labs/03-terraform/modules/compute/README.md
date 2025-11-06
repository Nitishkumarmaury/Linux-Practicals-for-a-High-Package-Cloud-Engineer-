# ECS Compute Module

This module sets up ECS infrastructure for running containerized applications.

## Features
- ECS Cluster
- ECS Services
- Application Load Balancer
- Auto Scaling Groups
- CloudWatch Logs
- Container Registry

## Usage
```hcl
module "compute" {
  source = "./modules/compute"

  environment     = "dev"
  vpc_id         = module.networking.vpc_id
  subnet_ids     = module.networking.private_subnet_ids
  alb_subnet_ids = module.networking.public_subnet_ids
}
```