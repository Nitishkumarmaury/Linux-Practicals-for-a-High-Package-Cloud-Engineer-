# Practical 2: Core Cloud Services

This practical covers fundamental cloud services implementation across major cloud providers (AWS/Azure/GCP).

## Learning Objectives
- Design and implement secure VPC/VNet architecture
- Configure compute instances with proper security
- Implement storage solutions
- Set up IAM and security controls

## Prerequisites
- AWS/Azure/GCP free tier account
- AWS CLI/Azure CLI/gcloud CLI installed
- Basic understanding of networking concepts from Practical 1

## Part 1: Network Setup
### Exercise 1.1: VPC Configuration (AWS Example)
```bash
# Create VPC
aws ec2 create-vpc --cidr-block 10.0.0.0/16 --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=prod-vpc}]'

# Create subnets
aws ec2 create-subnet \
    --vpc-id vpc-XXXXX \
    --cidr-block 10.0.1.0/24 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=prod-private-1a}]'

aws ec2 create-subnet \
    --vpc-id vpc-XXXXX \
    --cidr-block 10.0.2.0/24 \
    --availability-zone us-east-1b \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=prod-private-1b}]'
```

### Exercise 1.2: Security Groups
```bash
# Create security group
aws ec2 create-security-group \
    --group-name web-sg \
    --description "Web server security group" \
    --vpc-id vpc-XXXXX

# Add rules
aws ec2 authorize-security-group-ingress \
    --group-id sg-XXXXX \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-id sg-XXXXX \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0
```

## Part 2: Compute Resources
### Exercise 2.1: Launch EC2 Instance
```bash
# Create key pair
aws ec2 create-key-pair \
    --key-name prod-key \
    --query 'KeyMaterial' \
    --output text > prod-key.pem

# Launch instance
aws ec2 run-instances \
    --image-id ami-XXXXX \
    --count 1 \
    --instance-type t2.micro \
    --key-name prod-key \
    --security-group-ids sg-XXXXX \
    --subnet-id subnet-XXXXX \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=web-server}]'
```

### Exercise 2.2: User Data Script
```bash
#!/bin/bash
# user_data.sh
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Hello from Cloud Engineering Lab!</h1>" > /var/www/html/index.html
```

## Part 3: Storage Configuration
### Exercise 3.1: S3 Bucket Setup
```bash
# Create bucket
aws s3api create-bucket \
    --bucket my-secure-bucket-XXXXX \
    --region us-east-1

# Enable encryption
aws s3api put-bucket-encryption \
    --bucket my-secure-bucket-XXXXX \
    --server-side-encryption-configuration '{
    "Rules": [
        {
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "AES256"
            }
        }
    ]
}'

# Block public access
aws s3api put-public-access-block \
    --bucket my-secure-bucket-XXXXX \
    --public-access-block-configuration '{
    "BlockPublicAcls": true,
    "IgnorePublicAcls": true,
    "BlockPublicPolicy": true,
    "RestrictPublicBuckets": true
}'
```

### Exercise 3.2: EBS Volume Management
```bash
# Create volume
aws ec2 create-volume \
    --volume-type gp2 \
    --size 20 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=volume,Tags=[{Key=Name,Value=web-data}]'

# Attach volume
aws ec2 attach-volume \
    --volume-id vol-XXXXX \
    --instance-id i-XXXXX \
    --device /dev/xvdf
```

## Part 4: IAM Configuration
### Exercise 4.1: Create IAM Policy
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::my-secure-bucket-XXXXX/*"
            ]
        }
    ]
}
```

### Exercise 4.2: Create IAM Role
```bash
# Create role
aws iam create-role \
    --role-name EC2WebRole \
    --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}'

# Attach policy
aws iam attach-role-policy \
    --role-name EC2WebRole \
    --policy-arn arn:aws:iam::ACCOUNT-ID:policy/WebS3Access
```

## Part 5: Advanced Tasks
### Exercise 5.1: Load Balancer Setup
```bash
# Create target group
aws elbv2 create-target-group \
    --name web-targets \
    --protocol HTTP \
    --port 80 \
    --vpc-id vpc-XXXXX \
    --health-check-path /index.html

# Create load balancer
aws elbv2 create-load-balancer \
    --name web-lb \
    --subnets subnet-XXXXX subnet-YYYYY \
    --security-groups sg-XXXXX

# Create listener
aws elbv2 create-listener \
    --load-balancer-arn arn:aws:elasticloadbalancing:REGION:ACCOUNT-ID:loadbalancer/app/web-lb/XXXXX \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:REGION:ACCOUNT-ID:targetgroup/web-targets/XXXXX
```

### Exercise 5.2: Auto Scaling Configuration
```bash
# Create launch template
aws ec2 create-launch-template \
    --launch-template-name web-template \
    --version-description WebServerV1 \
    --launch-template-data '{
        "ImageId": "ami-XXXXX",
        "InstanceType": "t2.micro",
        "SecurityGroupIds": ["sg-XXXXX"],
        "UserData": "BASE64_ENCODED_USER_DATA"
    }'

# Create Auto Scaling group
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name web-asg \
    --launch-template LaunchTemplateName=web-template,Version='$Latest' \
    --min-size 2 \
    --max-size 4 \
    --desired-capacity 2 \
    --target-group-arns arn:aws:elasticloadbalancing:REGION:ACCOUNT-ID:targetgroup/web-targets/XXXXX \
    --vpc-zone-identifier "subnet-XXXXX,subnet-YYYYY"
```

## Deliverables
1. Working VPC architecture diagram
2. Secure EC2 instances with web server
3. S3 bucket with proper security
4. IAM roles and policies documentation
5. Load balancer and auto scaling setup

## Validation Checklist
- [ ] VPC and subnets created with proper CIDR ranges
- [ ] Security groups configured with minimum required access
- [ ] EC2 instances launched and accessible
- [ ] S3 bucket created with encryption and access controls
- [ ] IAM roles and policies properly configured
- [ ] Load balancer functioning with health checks
- [ ] Auto scaling responding to load changes

## Additional Resources
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Azure Architecture Center](https://docs.microsoft.com/en-us/azure/architecture/)
- [Google Cloud Architecture Framework](https://cloud.google.com/architecture/framework)

## Troubleshooting Tips
1. VPC Flow Logs for network issues
2. CloudWatch/Azure Monitor for metrics
3. IAM Policy Simulator for permissions
4. Security Group and NACL analysis
5. Load Balancer access logs