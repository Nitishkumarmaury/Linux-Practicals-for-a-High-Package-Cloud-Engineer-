# Practical 9: Installing Docker and Running Your First Container

## Objective
Set up Docker environment and learn basic container operations through practical examples.

## Steps Overview
1. Install Docker
2. Configure User Access
3. Test Installation
4. Run Basic Containers
5. Manage Container Lifecycle

## Detailed Steps

### 1. Install Docker
```bash
# Update system
sudo apt update

# Install prerequisites
sudo apt install ca-certificates curl gnupg lsb-release -y

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
```

### 2. Configure User Access
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Apply changes (log out and back in)
newgrp docker
```

### 3. Test Installation
```bash
# Verify Docker installation
docker --version

# Check Docker service
sudo systemctl status docker

# Run hello-world
docker run hello-world
```

### 4. Basic Container Operations
```bash
# Run nginx container
docker run --name my-web -d -p 8080:80 nginx

# List running containers
docker ps

# Stop container
docker stop my-web

# Remove container
docker rm my-web
```

## Docker Commands Reference

### Image Management
```bash
# List images
docker images

# Pull image
docker pull ubuntu:latest

# Remove image
docker rmi nginx

# Build image
docker build -t myapp:1.0 .
```

### Container Lifecycle
```bash
# Start container
docker start container_name

# Stop container
docker stop container_name

# Restart container
docker restart container_name

# Remove container
docker rm container_name
```

### Container Information
```bash
# Container logs
docker logs container_name

# Container details
docker inspect container_name

# Container stats
docker stats container_name

# Process list
docker top container_name
```

## Common Issues and Solutions

1. **Permission Denied**
   - Add user to docker group
   - Verify group membership
   - Restart session

2. **Container Won't Start**
   - Check port conflicts
   - Verify resource availability
   - Review container logs

3. **Network Issues**
   - Check port mappings
   - Verify network settings
   - Test container connectivity

## Docker Compose Example

```yaml
# docker-compose.yml
version: '3'
services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html
  
  db:
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: example
      MYSQL_DATABASE: myapp
    volumes:
      - db_data:/var/lib/mysql

volumes:
  db_data:
```

### Using Docker Compose
```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs
```

## Best Practices
1. Use official images
2. Implement health checks
3. Proper resource limits
4. Regular updates
5. Security scanning

## Container Security

### Basic Security Measures
```bash
# Run as non-root
docker run -u 1000 nginx

# Read-only filesystem
docker run --read-only nginx

# Limited resources
docker run --memory=512m --cpus=1 nginx
```

### Security Best Practices
1. Regular image updates
2. Minimal base images
3. No sensitive data
4. Resource limitations
5. Network segmentation

## Verification Checklist
- [ ] Docker installed
- [ ] Service running
- [ ] User permissions set
- [ ] Test container works
- [ ] Network accessible
- [ ] Volumes working

## Monitoring and Maintenance

### Health Monitoring
```bash
# Check container health
docker inspect --format '{{.State.Health.Status}}' container_name

# View container stats
docker stats
```

### Maintenance Tasks
1. Regular updates
2. Image cleanup
3. Volume management
4. Network review
5. Security scans

## Additional Recommendations
1. Use Docker Compose
2. Implement monitoring
3. Regular backups
4. Documentation
5. Testing procedures

## Troubleshooting Steps
1. Check logs
2. Verify configuration
3. Test connectivity
4. Review resources
5. Validate permissions