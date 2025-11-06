# Practical 1: Server Setup & Hardening

## Objective
Secure a brand-new Ubuntu VM by implementing SSH key-based authentication and configuring a non-root sudo user.

## Steps Overview
1. Create VM
2. Configure Non-Root User
3. Set Up SSH Keys
4. Harden SSH Configuration
5. Test Access

## Detailed Steps

### 1. Create a VM
```bash
# Example using Google Cloud Platform
gcloud compute instances create my-vm \
    --machine-type=e2-micro \
    --image-family=ubuntu-2204 \
    --image-project=ubuntu-os-cloud \
    --zone=us-central1-a
```

### 2. Configure Non-Root User
```bash
# Create new user
sudo adduser nitish

# Add to sudo group
sudo usermod -aG sudo nitish
```

### 3. Set Up SSH Keys
```bash
# Generate SSH key on your local machine
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -C "nitish@local"

# Copy public key to VM
gcloud compute ssh <INSTANCE_NAME> --zone=<ZONE> --command="mkdir -p /home/nitish/.ssh && echo '$(cat ~/.ssh/id_rsa.pub)' | sudo tee -a /home/nitish/.ssh/authorized_keys && sudo chown -R nitish:nitish /home/nitish/.ssh && sudo chmod 700 /home/nitish/.ssh && sudo chmod 600 /home/nitish/.ssh/authorized_keys"
```

### 4. Harden SSH Configuration
```bash
# Edit SSH config
sudo vi /etc/ssh/sshd_config

# Set these parameters
PasswordAuthentication no
PermitRootLogin no

# Restart SSH service
sudo systemctl restart sshd
```

### 5. Test Access
```bash
# Try SSH access with key
ssh -i ~/.ssh/id_rsa nitish@<EXTERNAL_IP>
```

## Security Measures Implemented
- SSH key-based authentication only (no passwords)
- Root login disabled
- Non-root user with sudo privileges
- Proper SSH directory permissions

## Why These Steps Matter
1. **SSH Keys**: More secure than passwords, resistant to brute-force attacks
2. **Non-root User**: Follows principle of least privilege
3. **Sudo Access**: Maintains audit trail of privileged commands
4. **SSH Hardening**: Reduces attack surface

## Common Issues and Solutions

1. **Permission Denied**
   - Check SSH key permissions (should be 600)
   - Verify public key in authorized_keys
   - Confirm SSH service is running

2. **SSH Directory Permissions**
   - ~/.ssh should be 700
   - ~/.ssh/authorized_keys should be 600

3. **Sudo Access Issues**
   - Verify user is in sudo group
   - Check sudo configuration

## Best Practices
- Keep private keys secure and never share them
- Use strong key encryption (minimum 4096 bits)
- Regularly rotate SSH keys
- Monitor SSH login attempts
- Keep system and SSH updated

## Verification Checklist
- [ ] Non-root user created
- [ ] User has sudo privileges
- [ ] SSH key pair generated
- [ ] Public key installed on server
- [ ] Password authentication disabled
- [ ] Root login disabled
- [ ] SSH access works with key
- [ ] Sudo commands work

## Additional Security Recommendations
1. Configure fail2ban for SSH
2. Use SSH config for easier access
3. Implement SSH key passphrase
4. Consider TCP wrappers
5. Enable SSH logging