# Create ElastiCache Cluster
resource "aws_elasticache_cluster" "main" {
  cluster_id           = "${var.environment}-cache"
  engine              = "redis"
  node_type           = var.node_type
  num_cache_nodes     = var.num_cache_nodes
  parameter_group_name = aws_elasticache_parameter_group.main.name
  port                = 6379
  security_group_ids  = [aws_security_group.cache.id]
  subnet_group_name   = aws_elasticache_subnet_group.main.name

  maintenance_window = var.maintenance_window
  snapshot_window   = var.snapshot_window

  auto_minor_version_upgrade = true
  snapshot_retention_limit  = var.snapshot_retention_limit

  tags = {
    Environment = var.environment
  }
}

# Create Parameter Group
resource "aws_elasticache_parameter_group" "main" {
  family = "redis6.x"
  name   = "${var.environment}-cache-params"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }

  tags = {
    Environment = var.environment
  }
}

# Create Subnet Group
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.environment}-cache-subnet"
  subnet_ids = var.subnet_ids

  tags = {
    Environment = var.environment
  }
}

# Create Security Group
resource "aws_security_group" "cache" {
  name_prefix = "${var.environment}-cache-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  tags = {
    Environment = var.environment
  }
}

# Create CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "cache_cpu" {
  alarm_name          = "${var.environment}-cache-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/ElastiCache"
  period             = "300"
  statistic          = "Average"
  threshold          = var.cpu_threshold
  alarm_description  = "Redis cluster CPU utilization"
  alarm_actions      = [var.sns_topic_arn]

  dimensions = {
    CacheClusterId = aws_elasticache_cluster.main.id
  }
}

resource "aws_cloudwatch_metric_alarm" "cache_memory" {
  alarm_name          = "${var.environment}-cache-memory"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "FreeableMemory"
  namespace          = "AWS/ElastiCache"
  period             = "300"
  statistic          = "Average"
  threshold          = var.memory_threshold
  alarm_description  = "Redis cluster freeable memory"
  alarm_actions      = [var.sns_topic_arn]

  dimensions = {
    CacheClusterId = aws_elasticache_cluster.main.id
  }
}