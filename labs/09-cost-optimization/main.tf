# Cost Optimization Implementation
provider "aws" {
  region = var.region
}

# Auto Scaling Group with mixed instance types
resource "aws_autoscaling_group" "cost_optimized" {
  name                = "cost-optimized-asg"
  desired_capacity    = var.desired_capacity
  max_size           = var.max_size
  min_size           = var.min_size
  vpc_zone_identifier = var.subnet_ids

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 1
      on_demand_percentage_above_base_capacity = 25
      spot_allocation_strategy                 = "capacity-optimized"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.app.id
        version           = "$Latest"
      }

      override {
        instance_type = "t3.medium"
      }
      override {
        instance_type = "t3a.medium"
      }
      override {
        instance_type = "t2.medium"
      }
    }
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }
}

# S3 Lifecycle Rules
resource "aws_s3_bucket" "data" {
  bucket = "cost-optimized-data-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_lifecycle_configuration" "data" {
  bucket = aws_s3_bucket.data.id

  rule {
    id     = "transition-to-ia"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "INTELLIGENT_TIERING"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

# EBS Volume Optimization
resource "aws_ebs_volume" "gp3_optimized" {
  availability_zone = var.availability_zone
  size             = 100
  type             = "gp3"
  iops             = 3000
  throughput       = 125

  tags = {
    Name = "cost-optimized-volume"
  }
}

# RDS with Aurora Serverless
resource "aws_rds_cluster" "serverless" {
  cluster_identifier     = "cost-optimized-aurora"
  engine                = "aurora-postgresql"
  engine_mode           = "serverless"
  database_name         = "appdb"
  master_username       = var.db_username
  master_password       = var.db_password
  skip_final_snapshot   = true

  scaling_configuration {
    auto_pause               = true
    min_capacity            = 2
    max_capacity            = 8
    seconds_until_auto_pause = 300
  }
}

# DynamoDB On-Demand
resource "aws_dynamodb_table" "on_demand" {
  name           = "cost-optimized-table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  stream_enabled = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "id"
    type = "S"
  }
}

# CloudWatch Cost Monitoring
resource "aws_cloudwatch_metric_alarm" "billing" {
  alarm_name          = "billing-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period             = "28800" # 8 hours
  statistic          = "Maximum"
  threshold          = var.billing_threshold
  alarm_description  = "Billing alarm when charges exceed threshold"
  alarm_actions      = [aws_sns_topic.billing_alert.arn]

  dimensions = {
    Currency = "USD"
  }
}

resource "aws_sns_topic" "billing_alert" {
  name = "billing-alert-topic"
}

# Budget
resource "aws_budgets_budget" "monthly" {
  name              = "monthly-budget"
  budget_type       = "COST"
  limit_amount      = var.monthly_budget_limit
  limit_unit        = "USD"
  time_period_start = "2025-01-01_00:00"
  time_unit         = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                 = 80
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_email_addresses = var.alert_emails
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                 = 100
    threshold_type            = "PERCENTAGE"
    notification_type         = "FORECASTED"
    subscriber_email_addresses = var.alert_emails
  }
}