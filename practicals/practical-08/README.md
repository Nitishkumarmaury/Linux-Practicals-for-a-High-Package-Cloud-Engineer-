# Practical 8: Configuring a Basic Firewall (UFW)

## Objective
Implement and configure a basic firewall using UFW (Uncomplicated Firewall) to secure system services.

## Steps Overview
1. Install UFW
2. Configure Default Policies
3. Allow Required Services
4. Enable Firewall
5. Verify Configuration

## Detailed Steps

### 1. Install UFW
```bash
# Update package list
sudo apt update

# Install UFW
sudo apt install ufw -y
```

### 2. Configure Default Policies
```bash
# Set default deny incoming
sudo ufw default deny incoming

# Set default allow outgoing
sudo ufw default allow outgoing
```

### 3. Allow Required Services
```bash
# Allow SSH
sudo ufw allow ssh

# Allow HTTP
sudo ufw allow http

# Allow HTTPS
sudo ufw allow https

# Allow specific port
sudo ufw allow 8080/tcp
```

### 4. Enable Firewall
```bash
# Enable UFW
sudo ufw enable

# Check status
sudo ufw status verbose
```

## Advanced UFW Configuration

### Service Definitions
```bash
# Allow from specific IP
sudo ufw allow from 192.168.1.0/24

# Allow to specific port
sudo ufw allow from 192.168.1.0/24 to any port 3306

# Rate limiting
sudo ufw limit ssh
```

### Managing Rules
```bash
# List rules with numbers
sudo ufw status numbered

# Delete rule by number
sudo ufw delete 2

# Reset all rules
sudo ufw reset
```

## Common Configurations

### Web Server
```bash
# Basic web server
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# With SSL/TLS
sudo ufw allow https
```

### Database Server
```bash
# MySQL/MariaDB
sudo ufw allow from 192.168.1.0/24 to any port 3306

# PostgreSQL
sudo ufw allow from 192.168.1.0/24 to any port 5432
```

### Application Server
```bash
# Node.js
sudo ufw allow 3000/tcp

# Python
sudo ufw allow 8000/tcp
```

## Common Issues and Solutions

1. **Locked Out of SSH**
   - Always allow SSH before enabling
   - Test from another session
   - Have console access ready

2. **Service Access Issues**
   - Verify rule syntax
   - Check port numbers
   - Confirm IP ranges

3. **Rule Conflicts**
   - Review rule order
   - Check rule specificity
   - Consider rule priority

## Security Best Practices
1. Default deny stance
2. Minimal open ports
3. Regular rule review
4. Log monitoring
5. Service isolation

## UFW Logging

### Enable Logging
```bash
# Medium logging
sudo ufw logging on

# High logging
sudo ufw logging high
```

### Monitor Logs
```bash
# View UFW logs
sudo tail -f /var/log/ufw.log

# Filter blocked packets
grep "UFW BLOCK" /var/log/ufw.log
```

## Verification Checklist
- [ ] Default policies set
- [ ] Required services allowed
- [ ] Firewall enabled
- [ ] Rules verified
- [ ] Logging configured
- [ ] Remote access tested

## Maintenance Procedures

### Regular Tasks
1. Review active rules
2. Update service rules
3. Check logs
4. Verify effectiveness
5. Document changes

### Rule Management
```bash
# Backup rules
sudo ufw show raw > ufw_backup.txt

# Review numbered rules
sudo ufw status numbered

# Delete unused rules
sudo ufw delete [rule number]
```

## Additional Recommendations
1. Use rate limiting
2. Implement logging
3. Regular audits
4. Document changes
5. Test configurations

## Troubleshooting Guide

### Common Commands
```bash
# Check rule syntax
sudo ufw show added

# Test connectivity
nc -zv host port

# Monitor connections
sudo netstat -tupln
```

### Problem Resolution
1. Check rule order
2. Verify syntax
3. Test connectivity
4. Review logs
5. Update rules

## Security Considerations
1. Principle of least privilege
2. Regular updates
3. Log monitoring
4. Access control
5. Change management

## Best Practices Checklist
- [ ] Minimal open ports
- [ ] Specific source IPs
- [ ] Rate limiting enabled
- [ ] Logging configured
- [ ] Regular audits
- [ ] Documentation updated