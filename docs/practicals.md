# 10 Practicals for a High-Package Cloud Engineer

This document provides step-by-step guidance for each practical, the commands to run, reasoning, and brief interview talking points.

Note: replace example usernames, instance names, IP addresses and project IDs before running commands.

## Practical 1 — Day 1 Server Setup & Hardening
Objective: Secure a brand-new Ubuntu VM and limit access to SSH keys and a non-root sudo user.

GCP quick commands (replace PROJECT and ZONE and INSTANCE):

1. Create a VM (example):

gcloud compute instances create my-vm --machine-type=e2-micro --image-family=ubuntu-2204 --image-project=ubuntu-os-cloud --zone=us-central1-a

2. SSH using the gcloud helper:

gcloud compute ssh <INSTANCE_NAME> --zone=<ZONE>

On the VM:

- Create a non-root user and add to sudo:
  sudo adduser nitish
  sudo usermod -aG sudo nitish

- Generate SSH key on local machine (if not present):
  ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -C "nitish@local"

- Copy the public key to VM for `nitish` (local machine):
  gcloud compute ssh <INSTANCE_NAME> --zone=<ZONE> --command="mkdir -p /home/nitish/.ssh && echo '$(cat ~/.ssh/id_rsa.pub)' | sudo tee -a /home/nitish/.ssh/authorized_keys && sudo chown -R nitish:nitish /home/nitish/.ssh && sudo chmod 700 /home/nitish/.ssh && sudo chmod 600 /home/nitish/.ssh/authorized_keys"

- SSH as nitish:
  ssh -i ~/.ssh/id_rsa nitish@<EXTERNAL_IP>

- Harden SSH (`/etc/ssh/sshd_config`) using `vi`:
  sudo vi /etc/ssh/sshd_config
  Set:
    PasswordAuthentication no
    PermitRootLogin no
  Restart sshd:
    sudo systemctl restart sshd

Why this matters: Disabling password auth and root login reduces brute-force and credential-based compromise.

Interview tip: Explain defense-in-depth: cloud IAM controls who can create VMs, and OS-level hardening limits what an attacker can do even if they create a user.

---

## Practical 2 — Deploying a Static Website with Nginx
Commands (on hardened VM):

sudo apt update
sudo apt install nginx -y
sudo systemctl enable --now nginx
sudo systemctl status nginx

Webroot: `/var/www/html`
Remove default and create a page:
  cd /var/www/html
  sudo rm index.nginx-debian.html
  echo "<h1>Hello from my VM!</h1>" | sudo tee index.html

Open port 80 in cloud firewall (GCP Console or gcloud compute firewall-rules create ...)

Check by visiting http://EXTERNAL_IP/

Why: Shows packaging, service management, and cloud networking.

---

## Practical 3 — Managing Project Teams with Users & Groups
Commands:

sudo groupadd developers
sudo groupadd testers
sudo adduser dev_user --gecos "Dev User" --disabled-password
sudo usermod -aG developers dev_user
sudo adduser test_user --gecos "Test User" --disabled-password
sudo usermod -aG testers test_user

Create directory and set permissions:

sudo mkdir -p /opt/my_project
sudo chown root:developers /opt/my_project
sudo chmod 2775 /opt/my_project

Notes: Setting the setgid bit (chmod 2775) makes new files inherit the group. Test with `su - dev_user` and `su - test_user`.

Interview tip: Talk about least privilege and group-based access for team collaboration.

---

## Practical 4 — Automating Backups with Bash & Cron
Script: `/usr/local/bin/backup_web.sh` (see `scripts/backup_web.sh`)

Make executable and run:
  sudo chmod +x /usr/local/bin/backup_web.sh
  sudo /usr/local/bin/backup_web.sh

Automate with root crontab:
  sudo crontab -e
  Add: 0 3 * * * /usr/local/bin/backup_web.sh

Why: Automation reduces human error and ensures recoverability.

---

## Practical 5 — Real-Time Log Monitoring & Analysis
Commands:

sudo tail -f /var/log/nginx/access.log
sudo grep " 404 " /var/log/nginx/access.log
sudo awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -nr | head -n 10

Why: Quickly find errors and abusive clients.

---

## Practical 6 — Troubleshooting a "Crashed" Service
Commands:

sudo systemctl stop nginx
sudo systemctl status nginx
sudo systemctl start nginx
sudo journalctl -u nginx.service -n 50 --no-pager

Interview tip: Describe runbook steps and monitoring alerts that would trigger these actions.

---

## Practical 7 — Identifying a High-CPU Process
Install stress and reproduce:

sudo apt install stress -y
stress --cpu 1 --timeout 300 &
top   # press P to sort by CPU
sudo kill <PID>

Why: Shows you can use system tools to identify and mitigate resource issues.

---

## Practical 8 — Configuring a Basic Firewall (ufw)
Commands:

sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw enable
sudo ufw status verbose

Why: Defense-in-depth; host-based firewall complements cloud firewalls.

---

## Practical 9 — Installing Docker and Running Your First Container
Install Docker (recommended: follow Docker official instructions). Quick install example for Ubuntu:

sudo apt update
sudo apt install ca-certificates curl gnupg lsb-release -y
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

Add user to docker group (log out/in):
  sudo usermod -aG docker $USER

Run hello-world and nginx container:
  docker run hello-world
  docker run --name my-web -d -p 8080:80 nginx

Why: Demonstrates container basics and portability.

---

## Practical 10 — The Multi-VM Web Application
Overview:
- VM1: web server (Nginx)
- VM2: database server (MySQL)

Key network rule: only allow MySQL (3306) from VM1's internal IP. Never expose MySQL publicly.

On VM2 (database):
  sudo apt install mysql-server -y
  sudo mysql_secure_installation

On VM1 (client):
  sudo apt install mysql-client -y
  mysql -u <dbuser> -p -h <VM2_PRIVATE_IP>

Why: Tests networking, firewall rules, and principle of least exposure.

---

## Scripts
See `scripts/` for helper scripts referenced above. Inspect and run with `sudo` where appropriate.

## Interview checklist (what to explain for each practical)
- What problem does this solve? (security, availability, troubleshooting)
- Key commands and why you used them.
- Safety considerations and alternatives (e.g., managed DB vs self-hosted).
