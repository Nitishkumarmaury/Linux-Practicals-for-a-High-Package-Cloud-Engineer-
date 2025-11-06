# Practical 5: Real-Time Log Monitoring & Analysis

## Objective
Implement effective log monitoring and analysis techniques for system and application logs.

## Steps Overview
1. Access Log Files
2. Monitor Real-Time Logs
3. Search for Specific Events
4. Analyze Access Patterns
5. Create Analysis Reports

## Detailed Steps

### 1. Basic Log Monitoring
```bash
# Monitor Nginx access logs in real-time
sudo tail -f /var/log/nginx/access.log

# Monitor error logs
sudo tail -f /var/log/nginx/error.log

# Monitor system logs
sudo tail -f /var/log/syslog
```

### 2. Search for Error Codes
```bash
# Find 404 errors
sudo grep " 404 " /var/log/nginx/access.log

# Find 500 errors
sudo grep " 500 " /var/log/nginx/access.log

# Count error occurrences
sudo grep " 404 " /var/log/nginx/access.log | wc -l
```

### 3. Analyze Access Patterns
```bash
# Top 10 IP addresses
sudo awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -nr | head -n 10

# Top requested URLs
sudo awk '{print $7}' /var/log/nginx/access.log | sort | uniq -c | sort -nr | head -n 10

# Requests per hour
sudo awk '{print $4}' /var/log/nginx/access.log | cut -d: -f2 | sort | uniq -c
```

### 4. Create Analysis Script
```bash
#!/bin/bash

LOG_FILE="/var/log/nginx/access.log"
REPORT_FILE="/var/log/nginx/analysis_report.txt"

echo "Log Analysis Report - $(date)" > ${REPORT_FILE}
echo "=========================" >> ${REPORT_FILE}

# Top 10 IPs
echo -e "\nTop 10 IP Addresses:" >> ${REPORT_FILE}
awk '{print $1}' ${LOG_FILE} | sort | uniq -c | sort -nr | head -n 10 >> ${REPORT_FILE}

# HTTP Status Codes
echo -e "\nHTTP Status Code Distribution:" >> ${REPORT_FILE}
awk '{print $9}' ${LOG_FILE} | sort | uniq -c | sort -nr >> ${REPORT_FILE}

# 404 Errors
echo -e "\n404 Errors:" >> ${REPORT_FILE}
grep " 404 " ${LOG_FILE} | awk '{print $7}' | sort | uniq -c | sort -nr | head -n 10 >> ${REPORT_FILE}
```

## Log Analysis Tools

### Common Commands
```bash
# Search with context
grep -C 3 "error" /var/log/nginx/error.log

# Count occurrences
grep -c "404" /var/log/nginx/access.log

# Time-based analysis
sed -n '/2023:10:00/,/2023:11:00/p' /var/log/nginx/access.log
```

### Advanced Analysis
```bash
# Response time analysis
awk '{ sum += $NF } END { print "Average:", sum/NR }' /var/log/nginx/access.log

# Request method distribution
awk '{print $6}' /var/log/nginx/access.log | sort | uniq -c | sort -nr

# User agent analysis
awk -F'"' '{print $6}' /var/log/nginx/access.log | sort | uniq -c | sort -nr
```

## Common Issues and Solutions

1. **Large Log Files**
   - Use tail/head for partial analysis
   - Implement log rotation
   - Consider log aggregation

2. **Performance Impact**
   - Schedule heavy analysis off-peak
   - Use efficient grep patterns
   - Consider log parsing tools

3. **Missing Information**
   - Verify logging configuration
   - Check log levels
   - Monitor disk space

## Best Practices
1. Regular log rotation
2. Structured logging
3. Timestamp consistency
4. Error level proper use
5. Automated analysis

## Monitoring Setup

### Log Rotation Configuration
```bash
# /etc/logrotate.d/nginx
/var/log/nginx/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 www-data adm
    sharedscripts
    prerotate
        if [ -d /etc/logrotate.d/httpd-prerotate ]; then \
            run-parts /etc/logrotate.d/httpd-prerotate; \
        fi \
    endscript
    postrotate
        invoke-rc.d nginx rotate >/dev/null 2>&1
    endscript
}
```

## Security Considerations
1. Log file permissions
2. Access control
3. Log integrity
4. Retention policy
5. Sensitive data handling

## Verification Checklist
- [ ] Log files accessible
- [ ] Rotation configured
- [ ] Analysis tools working
- [ ] Reports generating
- [ ] Alerts configured
- [ ] Storage monitored

## Additional Recommendations
1. Set up log aggregation
2. Implement monitoring dashboard
3. Configure alerts
4. Document patterns
5. Regular review process

## Troubleshooting Tips
1. Check file permissions
2. Verify log configuration
3. Monitor disk space
4. Review rotation settings
5. Test analysis scripts