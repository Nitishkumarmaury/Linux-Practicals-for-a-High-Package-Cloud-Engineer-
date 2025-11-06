# Practical 6: Troubleshooting a "Crashed" Service

## Objective
Learn systematic approaches to diagnose and fix service issues using system tools and logs.

## Steps Overview
1. Check Service Status
2. Analyze System Logs
3. Monitor Resource Usage
4. Identify Root Cause
5. Implement Fix

## Detailed Steps

### 1. Initial Service Check
```bash
# Check service status
sudo systemctl status nginx

# Check if process is running
ps aux | grep nginx

# Check listening ports
sudo netstat -tulpn | grep nginx
```

### 2. Log Analysis
```bash
# View recent service logs
sudo journalctl -u nginx.service -n 50 --no-pager

# Check error logs
sudo tail -f /var/log/nginx/error.log

# View system messages
sudo tail -f /var/log/syslog
```

### 3. Service Control
```bash
# Stop service
sudo systemctl stop nginx

# Start service
sudo systemctl start nginx

# Restart service
sudo systemctl restart nginx

# Reload configuration
sudo systemctl reload nginx
```

### 4. Configuration Check
```bash
# Test Nginx configuration
sudo nginx -t

# Check configuration files
ls -l /etc/nginx/conf.d/
ls -l /etc/nginx/sites-enabled/
```

## Systematic Troubleshooting Approach

### 1. Gather Information
- Service status
- Error messages
- Resource usage
- Recent changes
- Configuration state

### 2. Analyze Symptoms
- Error patterns
- Timing of issues
- Related services
- System state

### 3. Test Hypotheses
- Reproduce issue
- Isolate components
- Test solutions
- Verify fixes

## Common Issues and Solutions

1. **Service Won't Start**
   - Check configuration syntax
   - Verify port availability
   - Check file permissions
   - Review error logs

2. **High Resource Usage**
   - Monitor CPU/Memory
   - Check connection limits
   - Review worker settings
   - Analyze access patterns

3. **Connection Issues**
   - Verify network config
   - Check firewall rules
   - Test port binding
   - Review SSL settings

## Diagnostic Commands

### System Resource Monitoring
```bash
# CPU and Memory usage
top -c

# Disk usage
df -h

# I/O stats
iostat
```

### Network Diagnostics
```bash
# Check ports
netstat -tulpn

# Test connectivity
curl -v localhost

# DNS resolution
dig example.com
```

### Process Management
```bash
# List processes
ps aux | grep nginx

# Check open files
lsof -p <PID>

# Monitor process
strace -p <PID>
```

## Best Practices
1. Document configuration changes
2. Maintain backup configs
3. Use version control
4. Regular log review
5. Monitor resource usage

## Creating a Runbook

### 1. Initial Response
- Check service status
- Review recent logs
- Note error messages
- Document symptoms

### 2. Investigation
- Analyze logs
- Check resources
- Review configuration
- Test connectivity

### 3. Resolution
- Apply fixes
- Test service
- Document solution
- Update procedures

## Monitoring and Prevention

### Setup Monitoring
```bash
# CPU Alert
if [ $(top -bn1 | grep "Cpu(s)" | awk '{print $2}') -gt 80 ]; then
    echo "High CPU usage detected"
fi

# Memory Check
free -m | awk '/Mem:/ {print $3/$2 * 100}'
```

### Regular Maintenance
1. Log rotation
2. Configuration backups
3. Performance monitoring
4. Security updates
5. Resource trending

## Verification Checklist
- [ ] Service running
- [ ] Logs clean
- [ ] Resources normal
- [ ] Configuration valid
- [ ] Connectivity good
- [ ] Performance acceptable

## Recovery Procedures
1. Stop service
2. Backup configuration
3. Fix issues
4. Test configuration
5. Start service
6. Verify operation

## Additional Recommendations
1. Implement monitoring
2. Set up alerts
3. Document procedures
4. Regular backups
5. Performance baselines

## Troubleshooting Tools
1. systemctl
2. journalctl
3. top/htop
4. netstat
5. nginx -t