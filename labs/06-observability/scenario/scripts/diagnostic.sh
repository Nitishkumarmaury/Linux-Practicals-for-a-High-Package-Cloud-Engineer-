#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to check service health
check_service_health() {
    local service=$1
    local port=$2
    echo -e "${YELLOW}Checking $service health...${NC}"
    
    # Check if service is running
    if curl -s http://localhost:$port/health > /dev/null; then
        echo -e "${GREEN}✓ $service is healthy${NC}"
        return 0
    else
        echo -e "${RED}✗ $service is not responding${NC}"
        return 1
    fi
}

# Function to check metrics
check_metrics() {
    local service=$1
    local port=$2
    echo -e "${YELLOW}Checking $service metrics...${NC}"
    
    # Get metrics
    local metrics=$(curl -s http://localhost:$port/metrics)
    
    # Check error rate
    local error_rate=$(echo "$metrics" | grep "${service}_total.*error" | awk '{print $2}')
    if [[ $(echo "$error_rate > 0.1" | bc -l) -eq 1 ]]; then
        echo -e "${RED}✗ High error rate detected: $error_rate${NC}"
        return 1
    else
        echo -e "${GREEN}✓ Error rate normal: $error_rate${NC}"
    fi
    
    # Check latency
    local latency=$(echo "$metrics" | grep "${service}_processing_seconds" | awk '{print $2}')
    if [[ $(echo "$latency > 2" | bc -l) -eq 1 ]]; then
        echo -e "${RED}✗ High latency detected: ${latency}s${NC}"
        return 1
    else
        echo -e "${GREEN}✓ Latency normal: ${latency}s${NC}"
    fi
}

# Function to check logs
check_logs() {
    local service=$1
    echo -e "${YELLOW}Checking $service logs...${NC}"
    
    # Get recent error logs
    local error_count=$(docker logs --since 5m ${service} 2>&1 | grep -i error | wc -l)
    if [ $error_count -gt 0 ]; then
        echo -e "${RED}✗ Found $error_count errors in logs${NC}"
        docker logs --since 5m ${service} 2>&1 | grep -i error
        return 1
    else
        echo -e "${GREEN}✓ No recent errors in logs${NC}"
        return 0
    fi
}

# Function to check resource usage
check_resources() {
    local service=$1
    echo -e "${YELLOW}Checking $service resource usage...${NC}"
    
    # Get CPU and memory usage
    local stats=$(docker stats ${service} --no-stream --format "{{.CPUPerc}}\t{{.MemPerc}}")
    local cpu=$(echo $stats | cut -f1)
    local memory=$(echo $stats | cut -f2)
    
    if [[ $(echo "$cpu > 80.0" | bc -l) -eq 1 ]]; then
        echo -e "${RED}✗ High CPU usage: $cpu%${NC}"
        return 1
    else
        echo -e "${GREEN}✓ CPU usage normal: $cpu%${NC}"
    fi
    
    if [[ $(echo "$memory > 80.0" | bc -l) -eq 1 ]]; then
        echo -e "${RED}✗ High memory usage: $memory%${NC}"
        return 1
    else
        echo -e "${GREEN}✓ Memory usage normal: $memory%${NC}"
    fi
}

# Main diagnostic flow
echo "=== Starting System Diagnostics ==="

# Check core services
for service in "order-service:8080" "payment-service:8081" "inventory-service:8082"; do
    IFS=':' read -r name port <<< "$service"
    echo -e "\n=== Checking $name ==="
    
    check_service_health $name $port
    check_metrics $name $port
    check_logs $name
    check_resources $name
done

# Check monitoring stack
echo -e "\n=== Checking Monitoring Stack ==="
for service in "prometheus:9090" "grafana:3000" "jaeger:16686"; do
    IFS=':' read -r name port <<< "$service"
    check_service_health $name $port
done

# Final summary
echo -e "\n=== Diagnostic Summary ==="
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ All systems operational${NC}"
else
    echo -e "${RED}✗ Issues detected - check details above${NC}"
fi