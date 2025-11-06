# Troubleshooting Guide: E-commerce Order Processing System

## Scenario: High Order Failure Rate Alert

### 1. Initial Alert
```yaml
Alert: HighErrorRate
Severity: Critical
Description: More than 10% of orders are failing
Duration: Triggered for last 5 minutes
Time: 2025-11-07 15:30 UTC
```

### 2. Initial Investigation Steps

#### Step 1: Check Service Health Dashboard
```promql
# Check service uptime
up{job=~"order-service|payment-service|inventory-service"}

# Check error rates
rate(orders_total{status="error"}[5m])
rate(payments_total{status="error"}[5m])
rate(inventory_checks_total{status="error"}[5m])
```

#### Step 2: Analyze Latency Patterns
```promql
# Check 95th percentile latency for each service
histogram_quantile(0.95, rate(order_processing_seconds_bucket[5m]))
histogram_quantile(0.95, rate(payment_processing_seconds_bucket[5m]))
```

#### Step 3: Examine Recent Traces
- Open Jaeger UI (http://localhost:16686)
- Filter for failed transactions
- Look for error tags and long durations

### 3. Root Cause Analysis

#### Payment Service Issues
```promql
# Check payment service error distribution
sum(rate(payments_total{status="error"}[5m])) by (error_type)

# Check payment service latency spikes
max_over_time(payment_processing_seconds_sum[1h])
```

#### Database Health
```promql
# Check DB connection pool
rate(db_connections_total{status="failed"}[5m])

# Check DB query latency
histogram_quantile(0.95, rate(db_query_duration_seconds_bucket[5m]))
```

### 4. Log Analysis in Kibana

#### Search Query for Error Investigation
```json
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "level": "ERROR"
          }
        }
      ],
      "filter": {
        "range": {
          "@timestamp": {
            "gte": "now-1h"
          }
        }
      }
    }
  }
}
```

### 5. Resolution Steps

1. **Immediate Actions**:
   - Scale payment service instances
   - Increase connection pool size
   - Enable circuit breaker

2. **Code Fixes**:
```python
# Add circuit breaker
@circuit_breaker(failure_threshold=5, recovery_timeout=30)
async def process_payment():
    # Existing payment processing logic

# Implement retry mechanism
@retry(max_attempts=3, backoff=exponential_backoff)
async def create_order():
    # Existing order creation logic
```

3. **Infrastructure Updates**:
```yaml
# Update resource limits
resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 512Mi
```

### 6. Verification Queries

```promql
# Verify error rate reduction
rate(orders_total{status="error"}[5m]) / rate(orders_total[5m]) < 0.01

# Check latency improvement
histogram_quantile(0.95, rate(order_processing_seconds_bucket[5m])) < 1

# Monitor resource usage
container_memory_usage_bytes{container="payment-service"}
container_cpu_usage_seconds_total{container="payment-service"}
```

### 7. Prevention Measures

1. **New Monitoring Rules**:
```yaml
- alert: ConnectionPoolNearLimit
  expr: db_connections_used / db_connections_total > 0.8
  for: 5m
  labels:
    severity: warning

- alert: HighCPUUsage
  expr: container_cpu_usage_seconds_total > 0.8
  for: 5m
  labels:
    severity: warning
```

2. **Automated Recovery**:
```python
# Implement health checks
@app.get("/health")
async def health_check():
    checks = await run_health_checks()
    return {
        "status": "healthy" if all(checks.values()) else "unhealthy",
        "checks": checks
    }

# Add automatic scaling rules
autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
```

### 8. Documentation Updates

1. **Runbook Additions**:
   - New section on payment processing failures
   - Updated troubleshooting steps
   - Added performance tuning guidelines

2. **Monitoring Dashboard Updates**:
   - Added connection pool metrics
   - Created latency breakdown views
   - Set up resource utilization trends

### 9. Long-term Improvements

1. **Architecture Changes**:
```yaml
# Implement message queue for order processing
services:
  rabbitmq:
    image: rabbitmq:3.9-management
    ports:
      - "5672:5672"
      - "15672:15672"

# Add caching layer
  redis:
    image: redis:6.2
    ports:
      - "6379:6379"
```

2. **Performance Optimizations**:
```python
# Implement caching
@cached(ttl=300)  # 5 minutes
async def get_inventory_level(product_id: str):
    return await db.get_inventory(product_id)

# Add request batching
@batch_processor(max_size=100, max_wait=0.5)
async def process_orders(orders: List[Order]):
    return await bulk_process(orders)
```