# Practical 4: Automating Backups with Bash & Cron

## Objective
Create an automated backup system for web server content using bash scripting and cron scheduling.

## Steps Overview
1. Create Backup Script
2. Configure Script Permissions
3. Test Manual Execution
4. Set Up Cron Job
5. Verify Backup Process

## Detailed Steps

### 1. Create Backup Script
```bash
# Create script directory if it doesn't exist
sudo mkdir -p /usr/local/bin

# Create backup script
sudo nano /usr/local/bin/backup_web.sh
```

### 2. Script Content
```bash
#!/bin/bash

# Configuration
BACKUP_DIR="/var/backups/website"
SOURCE_DIR="/var/www/html"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="website_backup_${TIMESTAMP}.tar.gz"
LOG_FILE="/var/log/website_backup.log"

# Ensure backup directory exists
mkdir -p ${BACKUP_DIR}

# Log function
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a ${LOG_FILE}
}

# Start backup
log_message "Starting website backup"

# Create backup
tar -czf ${BACKUP_DIR}/${BACKUP_FILE} ${SOURCE_DIR} 2>/dev/null

# Check if backup was successful
if [ $? -eq 0 ]; then
    log_message "Backup successful: ${BACKUP_FILE}"
    
    # Cleanup old backups (keep last 7 days)
    find ${BACKUP_DIR} -type f -name "website_backup_*" -mtime +7 -exec rm {} \;
    log_message "Cleaned up old backups"
else
    log_message "Backup failed!"
fi
```

### 3. Configure Permissions
```bash
# Make script executable
sudo chmod +x /usr/local/bin/backup_web.sh

# Set proper ownership
sudo chown root:root /usr/local/bin/backup_web.sh
```

### 4. Test Manual Execution
```bash
# Run backup script
sudo /usr/local/bin/backup_web.sh

# Check backup directory
ls -l /var/backups/website/

# View logs
tail -f /var/log/website_backup.log
```

### 5. Set Up Cron Job
```bash
# Edit root's crontab
sudo crontab -e

# Add backup schedule (runs at 3 AM daily)
0 3 * * * /usr/local/bin/backup_web.sh
```

## Script Components Explained

### Configuration Variables
- BACKUP_DIR: Backup storage location
- SOURCE_DIR: Directory to backup
- TIMESTAMP: Unique backup identifier
- BACKUP_FILE: Backup archive name
- LOG_FILE: Log file location

### Functions
- log_message: Unified logging function
- Backup creation with tar
- Automatic cleanup of old backups
- Error checking and reporting

## Backup Verification

### Check Backup Integrity
```bash
# List backup contents
tar -tvf /var/backups/website/backup_file.tar.gz

# Test restoration
sudo tar -xzf /var/backups/website/backup_file.tar.gz -C /tmp/restore_test
```

## Common Issues and Solutions

1. **Permission Denied**
   - Check script permissions
   - Verify cron user permissions
   - Check directory permissions

2. **Disk Space Issues**
   - Monitor backup size
   - Implement rotation policy
   - Check available space

3. **Cron Job Problems**
   - Verify cron syntax
   - Check script path
   - Review cron logs

## Best Practices
1. Regular backup testing
2. Implement rotation policy
3. Monitor backup logs
4. Verify backup integrity
5. Document recovery procedures

## Monitoring and Maintenance

### Log Analysis
```bash
# Check backup logs
grep "Backup successful" /var/log/website_backup.log

# Monitor backup size
du -sh /var/backups/website/

# Check disk space
df -h
```

### Backup Testing Schedule
1. Daily: Check log files
2. Weekly: Verify backup integrity
3. Monthly: Test restoration
4. Quarterly: Full recovery test

## Security Considerations
1. Secure backup storage
2. Encrypted backups
3. Limited access to scripts
4. Proper log rotation
5. Monitoring alerts

## Verification Checklist
- [ ] Script created and executable
- [ ] Permissions set correctly
- [ ] Manual backup test successful
- [ ] Cron job configured
- [ ] Logging working properly
- [ ] Cleanup functioning

## Recovery Procedures
1. Identify backup file
2. Verify integrity
3. Stop web service
4. Extract backup
5. Verify restoration
6. Start web service

## Additional Recommendations
1. Remote backup copy
2. Compression monitoring
3. Email notifications
4. Backup size trending
5. Performance optimization