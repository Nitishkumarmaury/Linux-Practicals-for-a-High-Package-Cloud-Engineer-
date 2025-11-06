# High Availability and Disaster Recovery Implementation
provider "aws" {
  region = var.primary_region
  alias  = "primary"
}

provider "aws" {
  region = var.secondary_region
  alias  = "secondary"
}

# VPC in Primary Region
module "vpc_primary" {
  source = "terraform-aws-modules/vpc/aws"
  providers = {
    aws = aws.primary
  }

  name = "ha-primary-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.primary_region}a", "${var.primary_region}b", "${var.primary_region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false
}

# VPC in Secondary Region
module "vpc_secondary" {
  source = "terraform-aws-modules/vpc/aws"
  providers = {
    aws = aws.secondary
  }

  name = "ha-secondary-vpc"
  cidr = "172.16.0.0/16"

  azs             = ["${var.secondary_region}a", "${var.secondary_region}b", "${var.secondary_region}c"]
  private_subnets = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
  public_subnets  = ["172.16.101.0/24", "172.16.102.0/24", "172.16.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false
}

# Aurora Global Database
resource "aws_rds_global_cluster" "global" {
  global_cluster_identifier = "ha-global-db"
  engine                   = "aurora-postgresql"
  engine_version           = "13.7"
  database_name            = "hadb"
}

resource "aws_rds_cluster" "primary" {
  provider                  = aws.primary
  cluster_identifier        = "ha-primary-cluster"
  engine                   = "aurora-postgresql"
  engine_version           = "13.7"
  global_cluster_identifier = aws_rds_global_cluster.global.id
  database_name            = "hadb"
  master_username          = var.db_username
  master_password          = var.db_password
  skip_final_snapshot      = true
  vpc_security_group_ids   = [aws_security_group.db_primary.id]
  db_subnet_group_name     = aws_db_subnet_group.primary.name
}

resource "aws_rds_cluster" "secondary" {
  provider                  = aws.secondary
  cluster_identifier        = "ha-secondary-cluster"
  engine                   = "aurora-postgresql"
  engine_version           = "13.7"
  global_cluster_identifier = aws_rds_global_cluster.global.id
  skip_final_snapshot      = true
  vpc_security_group_ids   = [aws_security_group.db_secondary.id]
  db_subnet_group_name     = aws_db_subnet_group.secondary.name
}

# Route53 Global DNS
resource "aws_route53_zone" "primary" {
  name = var.domain_name
}

resource "aws_route53_health_check" "primary" {
  fqdn              = "primary.${var.domain_name}"
  port              = 80
  type              = "HTTP"
  resource_path     = "/health"
  failure_threshold = "3"
  request_interval  = "30"

  tags = {
    Name = "primary-health-check"
  }
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.domain_name
  type    = "A"

  failover_routing_policy {
    type = "PRIMARY"
  }

  set_identifier = "primary"
  health_check_id = aws_route53_health_check.primary.id

  alias {
    name                   = aws_lb.primary.dns_name
    zone_id                = aws_lb.primary.zone_id
    evaluate_target_health = true
  }
}

# S3 Cross-Region Replication
resource "aws_s3_bucket" "primary" {
  provider = aws.primary
  bucket   = "ha-primary-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket" "secondary" {
  provider = aws.secondary
  bucket   = "ha-secondary-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_versioning" "primary" {
  provider = aws.primary
  bucket   = aws_s3_bucket.primary.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "secondary" {
  provider = aws.secondary
  bucket   = aws_s3_bucket.secondary.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  provider = aws.primary
  bucket   = aws_s3_bucket.primary.id
  role     = aws_iam_role.replication.arn

  rule {
    id     = "everything"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.secondary.arn
      storage_class = "STANDARD"
    }
  }
}

# DynamoDB Global Tables
resource "aws_dynamodb_table" "primary" {
  provider       = aws.primary
  name           = "ha-table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  stream_enabled = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "id"
    type = "S"
  }

  replica {
    region_name = var.secondary_region
  }
}

# Application Load Balancer - Primary
resource "aws_lb" "primary" {
  provider           = aws.primary
  name               = "ha-primary-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_primary.id]
  subnets           = module.vpc_primary.public_subnets
}

# Auto Scaling Group - Primary
resource "aws_autoscaling_group" "primary" {
  provider           = aws.primary
  name               = "ha-primary-asg"
  desired_capacity   = var.asg_desired_capacity
  max_size           = var.asg_max_size
  min_size           = var.asg_min_size
  target_group_arns  = [aws_lb_target_group.primary.arn]
  vpc_zone_identifier = module.vpc_primary.private_subnets

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
}

# Backup Plans
resource "aws_backup_plan" "main" {
  provider = aws.primary
  name     = "ha-backup-plan"

  rule {
    rule_name         = "daily_backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 5 ? * * *)"

    lifecycle {
      delete_after = 30
    }
  }

  rule {
    rule_name         = "weekly_backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 5 ? * 1 *)"

    lifecycle {
      delete_after = 90
    }
  }
}

# CloudWatch Alarms for Failover
resource "aws_cloudwatch_metric_alarm" "failover" {
  provider            = aws.primary
  alarm_name          = "ha-failover-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period             = "60"
  statistic          = "Average"
  threshold          = "0"
  alarm_description  = "This metric monitors healthy hosts"
  alarm_actions      = [aws_sns_topic.failover.arn]

  dimensions = {
    LoadBalancer = aws_lb.primary.arn_suffix
  }
}