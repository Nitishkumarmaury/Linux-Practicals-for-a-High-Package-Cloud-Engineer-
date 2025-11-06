# Practical 10: Multi-VM Web Application

## Objective
Deploy and configure a multi-tier web application using separate VMs for web server and database.

## Steps Overview
1. Set Up Web Server VM
2. Configure Database VM
3. Implement Security
4. Configure Network Access
5. Test Application

## Detailed Steps

### 1. Web Server Setup (VM1)
```bash
# Update system
sudo apt update

# Install Nginx
sudo apt install nginx -y

# Install MySQL client
sudo apt install mysql-client -y

# Start and enable Nginx
sudo systemctl enable --now nginx
```

### 2. Database Server Setup (VM2)
```bash
# Update system
sudo apt update

# Install MySQL Server
sudo apt install mysql-server -y

# Secure MySQL installation
sudo mysql_secure_installation

# Configure MySQL remote access
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
# Change bind-address to VM2's private IP
```

### 3. Database Configuration
```bash
# Create database and user
sudo mysql -u root -p
CREATE DATABASE webapp;
CREATE USER 'webuser'@'VM1_PRIVATE_IP' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON webapp.* TO 'webuser'@'VM1_PRIVATE_IP';
FLUSH PRIVILEGES;
```

### 4. Network Security
```bash
# On VM2 (Database Server)
# Allow MySQL from web server only
sudo ufw allow from VM1_PRIVATE_IP to any port 3306

# On VM1 (Web Server)
# Allow HTTP/HTTPS
sudo ufw allow http
sudo ufw allow https
```

## Network Configuration

### Web Server (VM1)
```bash
# Test database connection
mysql -u webuser -p -h VM2_PRIVATE_IP

# Configure web server
sudo nano /etc/nginx/sites-available/default

# Test configuration
sudo nginx -t

# Reload configuration
sudo systemctl reload nginx
```

### Database Server (VM2)
```bash
# Configure MySQL binding
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
bind-address = VM2_PRIVATE_IP

# Restart MySQL
sudo systemctl restart mysql
```

## Security Measures

### Firewall Configuration
```bash
# VM1 (Web Server)
sudo ufw default deny incoming
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https

# VM2 (Database Server)
sudo ufw default deny incoming
sudo ufw allow ssh
sudo ufw allow from VM1_PRIVATE_IP to any port 3306
```

### SSL/TLS Setup
```bash
# Generate SSL certificate
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/ssl/private/nginx-selfsigned.key \
-out /etc/ssl/certs/nginx-selfsigned.crt

# Configure Nginx SSL
sudo nano /etc/nginx/sites-available/default
```

## Common Issues and Solutions

1. **Connection Refused**
   - Check MySQL binding
   - Verify firewall rules
   - Test network connectivity
   - Validate credentials

2. **Performance Issues**
   - Monitor resources
   - Check query performance
   - Optimize configurations
   - Review connection pools

3. **Security Concerns**
   - Regular updates
   - Security audits
   - Log monitoring
   - Access control review

## Monitoring Setup

### Web Server Monitoring
```bash
# Check Nginx status
sudo systemctl status nginx

# Monitor access logs
tail -f /var/log/nginx/access.log

# Monitor error logs
tail -f /var/log/nginx/error.log
```

### Database Monitoring
```bash
# Check MySQL status
sudo systemctl status mysql

# Monitor slow queries
tail -f /var/log/mysql/mysql-slow.log

# Check connections
mysql -e "SHOW PROCESSLIST;"
```

## Best Practices
1. Regular backups
2. Security updates
3. Performance monitoring
4. Access control
5. Documentation

## Backup Procedures

### Database Backup
```bash
# Create backup
mysqldump -u root -p --all-databases > backup.sql

# Restore backup
mysql -u root -p < backup.sql

# Automate backup
# Add to crontab:
0 3 * * * mysqldump -u root -p --all-databases > /backup/db_$(date +\%Y\%m\%d).sql
```

### Web Server Backup
```bash
# Backup configuration
sudo cp -r /etc/nginx/sites-available /backup/nginx/
sudo cp -r /var/www/html /backup/www/
```

## Verification Checklist
- [ ] Web server running
- [ ] Database accessible
- [ ] Firewall configured
- [ ] SSL working
- [ ] Backups configured
- [ ] Monitoring active

## Recovery Procedures
1. Document current state
2. Stop services
3. Restore backups
4. Verify configuration
5. Test functionality
6. Update documentation

## Additional Recommendations
1. Load balancing
2. Database replication
3. Monitoring tools
4. Automated backups
5. Documentation

## Maintenance Schedule
1. Daily backups
2. Weekly updates
3. Monthly security audit
4. Quarterly review
5. Annual testing