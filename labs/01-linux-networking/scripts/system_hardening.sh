#!/bin/bash
# system_hardening.sh
# This script implements basic system hardening configurations

# Exit on any error
set -e

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Backup original configurations
backup_configs() {
    log "Creating configuration backups..."
    
    # Backup SSH config
    if [ -f /etc/ssh/sshd_config ]; then
        cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%Y%m%d)
    fi
    
    # Backup sudoers
    cp /etc/sudoers /etc/sudoers.bak.$(date +%Y%m%d)
}

# Configure SSH hardening
harden_ssh() {
    log "Configuring SSH security settings..."
    
    cat << EOF > /etc/ssh/sshd_config.d/security.conf
# Security hardening for SSH
Protocol 2
PermitRootLogin no
PasswordAuthentication no
X11Forwarding no
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
AllowUsers cloudadmin
EOF

    systemctl restart sshd
}

# Configure system security limits
set_security_limits() {
    log "Setting security limits..."
    
    cat << EOF > /etc/security/limits.d/security.conf
# Security limits configuration
* hard core 0
* soft nproc 1000
* hard nproc 2000
EOF
}

# Configure system security parameters
set_sysctl_security() {
    log "Configuring kernel security parameters..."
    
    cat << EOF > /etc/sysctl.d/99-security.conf
# Kernel security settings
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.default.log_martians = 1
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
EOF

    sysctl -p /etc/sysctl.d/99-security.conf
}

# Set up basic firewall rules
configure_firewall() {
    log "Configuring firewall rules..."
    
    # Ensure UFW is installed
    apt-get update
    apt-get install -y ufw
    
    # Configure UFW
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    
    # Enable firewall
    echo "y" | ufw enable
}

# Main execution
main() {
    # Check if running as root
    if [ "$(id -u)" != "0" ]; then
        echo "This script must be run as root" 1>&2
        exit 1
    }

    log "Starting system hardening process..."
    
    backup_configs
    harden_ssh
    set_security_limits
    set_sysctl_security
    configure_firewall
    
    log "System hardening completed successfully"
}

# Run main function
main