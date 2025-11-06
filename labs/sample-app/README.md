# Cloud Engineering Sample Application

This is a microservices-based web application that will be used across all practicals. It consists of:

1. Frontend (React)
2. Backend API (Node.js)
3. Auth Service (Python)
4. Database (PostgreSQL)
5. Cache (Redis)

## Architecture
```
[Frontend] → [API Gateway]
                 ↓
    [Auth] ← [Backend API] → [Cache]
                 ↓
            [Database]
```

## Features
- User authentication
- Product catalog
- Shopping cart
- Order processing
- Real-time inventory updates

## Components
Each component is designed to demonstrate different cloud engineering concepts:

### Frontend
- Static web hosting
- CDN integration
- CI/CD pipelines

### Backend API
- Container orchestration
- Auto-scaling
- Load balancing
- API Gateway integration

### Auth Service
- Serverless functions
- JWT handling
- Security best practices

### Database
- High availability setup
- Backup and recovery
- Data encryption

### Cache
- In-memory caching
- Session management
- Performance optimization

## How This App Is Used in Practicals

### Practical 1: Linux & Networking
- Setting up development environment
- Configuring reverse proxy
- Network security

### Practical 2: Core Cloud
- VPC setup for app components
- Security groups configuration
- Storage for assets

### Practical 3: Infrastructure as Code
- Terraform modules for each component
- Environment management
- State handling

### Practical 4: CI/CD
- Build pipelines for each service
- Automated testing
- Deployment strategies

### Practical 5: Containers & K8s
- Containerizing all services
- Kubernetes deployments
- Service mesh

### Practical 6: Observability
- Metrics collection
- Distributed tracing
- Log aggregation

### Practical 7: Serverless
- Auth service migration
- Event-driven processing
- API Gateway integration

### Practical 8: Security
- SSL/TLS configuration
- Secrets management
- IAM policies

### Practical 9: Cost Optimization
- Resource right-sizing
- Caching strategies
- Auto-scaling policies

### Practical 10: HA & DR
- Multi-region deployment
- Backup strategies
- Failover testing