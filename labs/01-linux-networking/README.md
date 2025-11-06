# Practical 1: Linux & Networking Fundamentals

This practical covers essential Linux administration and networking skills needed for cloud engineering.

## Learning Objectives
- Master Linux command line operations
- Configure networking and security
- Implement system hardening
- Troubleshoot network issues

## Lab Environment Setup
1. Install VirtualBox or VMware Workstation
2. Download Ubuntu Server 22.04 LTS ISO
3. Create two VMs:
   - admin-vm (2GB RAM, 20GB disk)
   - target-vm (1GB RAM, 20GB disk)

## Part 1: Basic Linux Administration
### Exercise 1.1: User Management
```bash
# Create new user with sudo privileges
sudo adduser cloudadmin
sudo usermod -aG sudo cloudadmin

# Set up SSH key authentication
ssh-keygen -t ed25519 -C "cloudadmin@admin-vm"
ssh-copy-id cloudadmin@target-vm
```

### Exercise 1.2: File System Operations
```bash
# Create directory structure
mkdir -p /opt/cloud/{scripts,logs,backup}
chmod 755 /opt/cloud
chown -R cloudadmin:cloudadmin /opt/cloud

# Set up log rotation
cat << EOF > /etc/logrotate.d/cloudlogs
/opt/cloud/logs/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
}
EOF
```

## Part 2: Networking Configuration
### Exercise 2.1: Static IP Configuration
```bash
# Edit netplan configuration
sudo nano /etc/netplan/00-installer-config.yaml

# Example configuration:
network:
  version: 2
  ethernets:
    ens33:
      dhcp4: no
      addresses: [192.168.1.10/24]
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]

# Apply configuration
sudo netplan apply
```

### Exercise 2.2: Basic Firewall Rules
```bash
# Enable UFW and set basic rules
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable

# Verify rules
sudo ufw status verbose
```

## Part 3: Network Diagnostics
### Exercise 3.1: Traffic Analysis
```bash
# Install tools
sudo apt install -y tcpdump wireshark-cli net-tools

# Capture HTTP traffic
sudo tcpdump -i any port 80 -w /opt/cloud/logs/http_traffic.pcap

# Analyze captured traffic
tcpdump -r /opt/cloud/logs/http_traffic.pcap -n
```

### Exercise 3.2: Network Troubleshooting
Create a troubleshooting script:
```bash
#!/bin/bash
# network_diagnosis.sh

echo "=== Network Interface Status ==="
ip addr show

echo "=== Routing Table ==="
ip route show

echo "=== DNS Resolution Test ==="
dig google.com

echo "=== Connection Tests ==="
ping -c 4 8.8.8.8
traceroute 8.8.8.8
```

## Part 4: System Hardening
### Exercise 4.1: SSH Hardening
```bash
# Backup original config
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Create hardened config
sudo tee /etc/ssh/sshd_config.d/hardening.conf << EOF
# SSH Security Configuration
PermitRootLogin no
PasswordAuthentication no
X11Forwarding no
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
AllowUsers cloudadmin
Protocol 2
EOF

# Restart SSH service
sudo systemctl restart sshd
```

### Exercise 4.2: System Auditing
```bash
# Install audit system
sudo apt install -y auditd

# Configure basic audit rules
cat << EOF | sudo tee /etc/audit/rules.d/audit.rules
# Delete all existing rules
-D

# Buffer Size
-b 8192

# Failure Mode
-f 1

# Date Format
-i

# Monitor File Access
-w /etc/passwd -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/sudoers -p wa -k sudo_actions

# Monitor Command Execution
-a exit,always -F arch=b64 -S execve -k command_execution

# Monitor Network Configuration
-w /etc/sysctl.conf -p wa -k sysctl
-w /etc/networks -p wa -k network_modifications
EOF

# Restart audit daemon
sudo service auditd restart
```

## Part 5: Advanced Tasks

### Exercise 5.1: Network Performance Testing
```bash
# Install iperf3
sudo apt install -y iperf3

# On server
iperf3 -s

# On client
iperf3 -c server_ip -t 30 -P 4
```

### Exercise 5.2: Automated Backup
Create a backup script:
```bash
#!/bin/bash
# backup_script.sh

BACKUP_DIR="/opt/cloud/backup"
DATE=$(date +%Y%m%d)
BACKUP_FILE="system_backup_${DATE}.tar.gz"

# Create backup of important directories
tar -czf "${BACKUP_DIR}/${BACKUP_FILE}" \
    /etc/ssh \
    /etc/nginx \
    /etc/audit \
    /opt/cloud/scripts \
    /var/log/audit

# Rotate old backups (keep last 7 days)
find ${BACKUP_DIR} -name "system_backup_*.tar.gz" -mtime +7 -delete
```

## Deliverables
1. Complete VM setup with hardened configuration
2. Network configuration documentation
3. Working backup and monitoring scripts
4. Security audit report

## Validation Checklist
- [ ] SSH key authentication working
- [ ] Static IP configured and stable
- [ ] Firewall rules properly set
- [ ] Network monitoring tools installed
- [ ] Backup system operational
- [ ] Audit logging configured
- [ ] Security hardening applied

## Additional Resources
- [Linux Journey](https://linuxjourney.com/)
- [Networking Fundamentals](https://www.netacad.com/)
- [Linux Security Best Practices](https://www.cyberciti.biz/tips/linux-security.html)

## Troubleshooting Tips
1. Check system logs: `journalctl -xe`
2. Monitor resource usage: `top`, `htop`
3. Network connectivity: `ping`, `traceroute`, `netstat`
4. Firewall status: `sudo ufw status`, `sudo iptables -L`
5. SSH issues: `sudo systemctl status sshd`