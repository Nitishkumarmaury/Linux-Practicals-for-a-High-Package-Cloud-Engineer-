# Practical 7: Identifying a High-CPU Process

## Objective
Learn to identify, monitor, and manage resource-intensive processes using system tools.

## Steps Overview
1. Install Monitoring Tools
2. Generate Test Load
3. Monitor System Resources
4. Identify Problem Processes
5. Take Corrective Action

## Detailed Steps

### 1. Install Tools
```bash
# Install stress tool
sudo apt update
sudo apt install stress -y

# Install additional monitoring tools
sudo apt install htop sysstat atop -y
```

### 2. Generate Test Load
```bash
# Create CPU load
stress --cpu 1 --timeout 300 &

# Create memory load
stress --vm 1 --vm-bytes 512M --timeout 300 &
```

### 3. Monitor Resources
```bash
# Using top
top

# Using htop (more user-friendly)
htop

# Using vmstat
vmstat 1
```

## Monitoring Tools Explained

### top Command
```bash
# Sort by CPU (P)
top
# Then press P

# Sort by memory (M)
top
# Then press M

# Show specific user's processes
top -u username
```

### htop Features
- Color-coded output
- Mouse support
- Visual process tree
- Scroll support
- Built-in kill command

### System Statistics
```bash
# CPU statistics
mpstat 1

# Memory statistics
free -m

# I/O statistics
iostat 1
```

## Process Management Commands

### Identify Processes
```bash
# List all processes
ps aux

# Tree view of processes
pstree

# Process by user
ps -u username
```

### Process Control
```bash
# Kill process by PID
kill <PID>

# Force kill
kill -9 <PID>

# Kill by process name
pkill process_name
```

## Common Issues and Solutions

1. **High CPU Usage**
   - Identify process with top
   - Check process details
   - Monitor trends
   - Take appropriate action

2. **Memory Issues**
   - Monitor with free
   - Check swap usage
   - Identify memory leaks
   - Adjust system settings

3. **I/O Problems**
   - Use iostat
   - Monitor disk usage
   - Check I/O wait times
   - Optimize access patterns

## Resource Monitoring Script
```bash
#!/bin/bash

# Configuration
THRESHOLD_CPU=80
THRESHOLD_MEM=90
LOG_FILE="/var/log/resource_monitor.log"

# Log function
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a ${LOG_FILE}
}

# Check CPU usage
check_cpu() {
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
    if [ ${CPU_USAGE} -gt ${THRESHOLD_CPU} ]; then
        log_message "High CPU usage: ${CPU_USAGE}%"
        top -bn1 | head -20 >> ${LOG_FILE}
    fi
}

# Check memory usage
check_memory() {
    MEM_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}' | cut -d. -f1)
    if [ ${MEM_USAGE} -gt ${THRESHOLD_MEM} ]; then
        log_message "High memory usage: ${MEM_USAGE}%"
        free -h >> ${LOG_FILE}
    fi
}

# Main monitoring loop
while true; do
    check_cpu
    check_memory
    sleep 60
done
```

## Best Practices
1. Regular monitoring
2. Set resource limits
3. Configure alerts
4. Document baselines
5. Plan for scaling

## Performance Optimization

### System Tuning
```bash
# Adjust process priorities
renice -n 10 -p <PID>

# Set resource limits
ulimit -u 100  # max user processes

# Configure swap usage
sysctl vm.swappiness=60
```

### Resource Allocation
1. CPU affinity
2. Memory limits
3. I/O scheduling
4. Process priorities
5. Container resources

## Verification Checklist
- [ ] Monitoring tools installed
- [ ] Baseline established
- [ ] Alerts configured
- [ ] Documentation updated
- [ ] Recovery procedures tested

## Additional Recommendations
1. Implement trending
2. Set up dashboards
3. Configure notifications
4. Regular reviews
5. Capacity planning

## Troubleshooting Steps
1. Identify symptoms
2. Gather metrics
3. Analyze patterns
4. Take action
5. Monitor results

## Prevention Strategies
1. Regular maintenance
2. Performance monitoring
3. Capacity planning
4. Update procedures
5. Staff training