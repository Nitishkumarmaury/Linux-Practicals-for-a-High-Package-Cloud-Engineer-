# Practical 2: Deploying a Static Website with Nginx

## Objective
Deploy and configure a basic web server using Nginx to serve static content.

## Steps Overview
1. Install Nginx
2. Configure Basic Website
3. Set Up System Service
4. Configure Firewall
5. Test Deployment

## Detailed Steps

### 1. Install Nginx
```bash
# Update package list
sudo apt update

# Install Nginx
sudo apt install nginx -y

# Start and enable Nginx
sudo systemctl enable --now nginx

# Verify status
sudo systemctl status nginx
```

### 2. Configure Basic Website
```bash
# Navigate to web root
cd /var/www/html

# Remove default page
sudo rm index.nginx-debian.html

# Create custom index page
echo "<h1>Hello from my VM!</h1>" | sudo tee index.html
```

### 3. Configure Firewall (UFW)
```bash
# Allow HTTP traffic
sudo ufw allow http

# Allow HTTPS traffic (if needed)
sudo ufw allow https
```

### 4. Configure Cloud Firewall (GCP Example)
```bash
# Create firewall rule for HTTP
gcloud compute firewall-rules create allow-http \
    --allow tcp:80 \
    --target-tags=http-server \
    --description="Allow HTTP traffic"
```

### 5. Test Deployment
```bash
# Test Nginx configuration
sudo nginx -t

# Get your external IP
curl ifconfig.me

# Test locally
curl http://localhost

# Test from external (replace with your IP)
curl http://<EXTERNAL_IP>
```

## Configuration Files

### Main Nginx Configuration
Location: `/etc/nginx/nginx.conf`
Important settings:
- Worker processes
- Worker connections
- Include paths
- Global settings

### Site Configuration
Location: `/etc/nginx/sites-available/default`
Key configurations:
- Server blocks
- Root directory
- Index files
- Location blocks

## Nginx Directory Structure
```
/etc/nginx/
├── nginx.conf
├── sites-available/
│   └── default
├── sites-enabled/
│   └── default -> ../sites-available/default
└── conf.d/
```

## Common Issues and Solutions

1. **502 Bad Gateway**
   - Check application server status
   - Verify upstream configuration
   - Check logs in /var/log/nginx/error.log

2. **Permission Denied**
   - Check file ownership
   - Verify directory permissions
   - SELinux/AppArmor settings

3. **Connection Refused**
   - Verify Nginx is running
   - Check firewall rules
   - Confirm port availability

## Best Practices
1. Always test configuration before reload
2. Keep backups of configuration files
3. Use SSL/TLS for production
4. Implement proper logging
5. Regular security updates

## Monitoring and Maintenance

### Log Files
- Access Log: `/var/log/nginx/access.log`
- Error Log: `/var/log/nginx/error.log`

### Common Commands
```bash
# Reload configuration
sudo nginx -s reload

# Test configuration
sudo nginx -t

# Check status
sudo systemctl status nginx

# View logs
sudo tail -f /var/log/nginx/access.log
```

## Security Considerations
1. Hide server tokens
2. Configure proper SSL/TLS
3. Set up rate limiting
4. Configure security headers
5. Implement access controls

## Performance Optimization
1. Enable Gzip compression
2. Configure caching
3. Optimize worker processes
4. Use keepalive connections
5. Configure buffer sizes

## Verification Checklist
- [ ] Nginx installed and running
- [ ] Website accessible locally
- [ ] Website accessible externally
- [ ] Firewall configured
- [ ] Logs working properly
- [ ] Basic security measures implemented

## Additional Recommendations
1. Set up monitoring
2. Configure backup solution
3. Implement CDN (if needed)
4. Set up log rotation
5. Configure error pages