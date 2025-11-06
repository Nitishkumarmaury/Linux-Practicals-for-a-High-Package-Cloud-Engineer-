# Terraform Infrastructure as Code - Advanced Lab

This practical covers advanced Infrastructure as Code concepts using Terraform to deploy our sample application.

## Learning Objectives
- Create reusable Terraform modules
- Manage multiple environments
- Handle state management
- Implement infrastructure testing
- Use Terraform workspaces

## Lab Structure
```
03-terraform/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   └── prod/
│       ├── main.tf
│       ├── variables.tf
│       └── terraform.tfvars
├── modules/
│   ├── networking/
│   ├── compute/
│   ├── database/
│   ├── cache/
│   └── monitoring/
└── test/
    └── integration/
```

## Prerequisites
1. AWS CLI configured
2. Terraform 1.0+ installed
3. S3 bucket for remote state
4. DynamoDB table for state locking

## Part 1: Module Development

### Exercise 1.1: Create Base Network Module
The network module creates the base infrastructure:
- VPC
- Public/Private Subnets
- NAT Gateway
- Route Tables
- Security Groups

### Exercise 1.2: Create Application Module
The compute module manages application components:
- ECS Cluster
- ECS Services
- Application Load Balancer
- Auto Scaling

### Exercise 1.3: Create Database Module
The database module handles data persistence:
- RDS Instance
- Subnet Groups
- Parameter Groups
- Backup Configuration

## Part 2: Environment Configuration

### Exercise 2.1: Development Environment
Set up development environment with:
- Smaller instance types
- Minimal redundancy
- Debug logging enabled

### Exercise 2.2: Production Environment
Configure production with:
- High availability setup
- Multi-AZ deployment
- Enhanced monitoring
- Backup policies

## Part 3: State Management

### Exercise 3.1: Remote State Configuration
```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "env/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

### Exercise 3.2: State Operations
Learn state management:
```bash
# List state resources
terraform state list

# Move resources
terraform state mv

# Import existing resources
terraform import

# Remove resources from state
terraform state rm
```

## Part 4: Advanced Features

### Exercise 4.1: Terraform Workspaces
```bash
# Create workspace
terraform workspace new dev

# List workspaces
terraform workspace list

# Select workspace
terraform workspace select prod
```

### Exercise 4.2: Data Sources
```hcl
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "app_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
```

## Part 5: Infrastructure Testing

### Exercise 5.1: Unit Testing
Create test files for modules:
```hcl
provider "aws" {
  region = "us-east-1"
}

module "test_vpc" {
  source = "../../modules/networking"
  # Test configurations
}
```

### Exercise 5.2: Integration Testing
Test full environment deployments:
```bash
#!/bin/bash
# test_environment.sh

# Initialize Terraform
terraform init

# Plan and save
terraform plan -out=tfplan

# Apply and verify
terraform apply tfplan

# Run validation tests
./validate_infrastructure.sh

# Clean up
terraform destroy -auto-approve
```

## Deliverables
1. Complete module documentation
2. Working dev and prod environments
3. State management strategy
4. Test suite
5. Deployment guides

## Validation Checklist
- [ ] All modules have README files
- [ ] Variables are properly documented
- [ ] Outputs are defined
- [ ] State backend configured
- [ ] Tests are passing
- [ ] Environments are isolated
- [ ] Security best practices implemented

## Additional Resources
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Module Registry](https://registry.terraform.io/)