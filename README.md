# EKS Infrastructure with Terraform

This repository contains production-ready Terraform modules for deploying a complete EKS infrastructure on AWS.

## 🏗️ Architecture Overview

The infrastructure includes:

- **Networking**: VPC, subnets, NAT gateways, security groups
- **EKS Cluster**: Managed Kubernetes cluster with node groups
- **ECR Repositories**: Container image repositories
- **Ingress Controller**: NGINX ingress for HTTP/HTTPS traffic
- **Load Balancer Controller**: AWS ALB controller for advanced load balancing
- **External Secrets**: Integration with AWS Secrets Manager and Parameter Store
- **Route53**: DNS management (optional)

## 📁 Project Structure

```
.
├── backend.tf                # Terraform backend config
├── envs
│   └── dev
│       └── infra.tfvars      # environment-specific variables
├── main.tf                   # root config calling modules
├── modules
│   ├── ecr-repo              # creates AWS ECR repos
│   ├── eks                   # creates EKS cluster + addons
│   ├── external-secrets      # deploys external-secrets on EKS
│   ├── ingress               # ingress-nginx on EKS
│   ├── lb-controller         # AWS ALB ingress controller
│   ├── networking            # VPC, subnets, IGW, NAT, SGs
│   └── route53               # hosted zones + DNS records
├── outputs.tf                # root outputs
├── provider.tf               # AWS provider + region
└── variables.tf              # root-level variables
```

## 🚀 Quick Start

### Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.0 installed
3. **kubectl** for managing Kubernetes cluster
4. **Helm** for installing Kubernetes applications

### Step 1: Backend Setup

First, create the S3 bucket and DynamoDB table for Terraform state:

```bash
# Create S3 bucket for state storage
aws s3 mb s3://my-terraform-backend-bucket-vk --region ap-south-1

# Enable versioning (recommended for state files)
aws s3api put-bucket-versioning \
  --bucket my-terraform-backend-bucket-vk \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock-vk \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region ap-south-1
```

### Step 2: Configure Backend

```bash
# Copy the example backend configuration
cp backend.tfvars.example backend.tfvars

# Edit backend.tfvars with your values
vim backend.tfvars
```

### Step 3: Initialize and Deploy

```bash
# Initialize Terraform with backend configuration
terraform init -backend-config=backend.tfvars

# Plan the deployment
terraform plan -var-file=envs/dev/infra.tfvars

# Apply the configuration
terraform apply -var-file=envs/dev/infra.tfvars
```

### Step 4: Configure kubectl

```bash
# Configure kubectl to use the new EKS cluster
aws eks update-kubeconfig --region ap-south-1 --name myapp-dev-cluster

# Verify connection
kubectl get nodes
kubectl get pods --all-namespaces
```

## 🔧 Configuration

### Environment Variables

Edit `envs/dev/infra.tfvars` to customize your deployment:

```hcl
# Basic Configuration
environment  = "dev"
project_name = "myapp"
owner        = "Platform Team"
aws_region   = "ap-south-1"

# Networking
vpc_cidr = "10.0.0.0/16"

# EKS Configuration
eks_cluster_version = "1.28"
eks_node_group_instance_types = ["t3.medium"]
eks_node_group_desired_size = 2

# ECR Repositories
ecr_repositories = ["web-app", "api-service", "worker"]
```

### Multi-Environment Support

Create additional environment configurations:

```bash
mkdir -p envs/stage envs/prod
cp envs/dev/infra.tfvars envs/stage/infra.tfvars
cp envs/dev/infra.tfvars envs/prod/infra.tfvars

# Edit each file with environment-specific values
```

Deploy to different environments:

```bash
# Stage environment
terraform apply -var-file=envs/stage/infra.tfvars

# Production environment
terraform apply -var-file=envs/prod/infra.tfvars
```

## 🛠️ Module Configuration

### Networking Module

The networking module creates:
- VPC with DNS resolution enabled
- Public and private subnets across multiple AZs
- Internet Gateway and NAT Gateways
- Route tables and security groups
- Kubernetes-specific subnet tags

### EKS Module

Features include:
- EKS cluster with OIDC provider
- Managed node groups with auto-scaling
- Essential add-ons (CoreDNS, kube-proxy, VPC CNI, EBS CSI)
- CloudWatch logging
- Encryption at rest with KMS

### External Secrets Module

Integrates with AWS services:
- Secrets Manager integration
- Parameter Store integration
- IRSA (IAM Roles for Service Accounts)
- Example SecretStore configurations

### Ingress Module

NGINX Ingress Controller with:
- Network Load Balancer integration
- SSL/TLS termination
- High availability (multi-replica)
- Metrics collection

### Load Balancer Controller

AWS Load Balancer Controller for:
- Application Load Balancer support
- Network Load Balancer support
- WAF integration
- Advanced routing capabilities

## 📊 Monitoring and Observability

### CloudWatch Integration

The infrastructure includes:
- EKS cluster logging to CloudWatch
- Route53 health checks and alarms
- Application Load Balancer metrics

### Metrics Collection

Ingress controller exposes metrics on port 10254:
```bash
kubectl port-forward -n ingress-nginx deployment/ingress-nginx-controller 10254:10254
curl http://localhost:10254/metrics
```

## 🔐 Security Best Practices

### IAM Roles and Policies

- Least privilege access for all service accounts
- IRSA for secure AWS service integration
- Separate roles for each component

### Network Security

- Private subnets for worker nodes
- Security groups with minimal required access
- VPC flow logs enabled

### Encryption

- EKS secrets encryption with KMS
- ECR repositories with AES256 encryption
- HTTPS/TLS termination at load balancer

## 🔄 Maintenance

### Updating Kubernetes Version

1. Update `eks_cluster_version` in your tfvars file
2. Run `terraform plan` to review changes
3. Apply with `terraform apply`

### Scaling Node Groups

Update the node group size variables:
```hcl
eks_node_group_desired_size = 5
eks_node_group_max_size     = 10
```

### Adding ECR Repositories

Add repository names to the `ecr_repositories` list:
```hcl
ecr_repositories = [
  "web-app",
  "api-service", 
  "worker",
  "new-service"  # Add new repository
]
```

## 🧹 Cleanup

To destroy the infrastructure:

```bash
terraform destroy -var-file=envs/dev/infra.tfvars
```

**Warning**: This will delete all resources including data. Make sure to backup any important data before destroying.

## 📝 Useful Commands

### Kubernetes Operations

```bash
# Get cluster info
kubectl cluster-info

# Get all resources in ingress-nginx namespace
kubectl get all -n ingress-nginx

# Get external-secrets pods
kubectl get pods -n external-secrets-system

# View load balancer services
kubectl get svc -A | grep LoadBalancer
```

### ECR Operations

```bash
# Login to ECR
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.ap-south-1.amazonaws.com

# Build and push image
docker build -t myapp-dev-web-app .
docker tag myapp-dev-web-app:latest <account-id>.dkr.ecr.ap-south-1.amazonaws.com/myapp-dev-web-app:latest
docker push <account-id>.dkr.ecr.ap-south-1.amazonaws.com/myapp-dev-web-app:latest
```

### Troubleshooting

```bash
# Check node status
kubectl describe nodes

# Check pod logs
kubectl logs -f deployment/ingress-nginx-controller -n ingress-nginx

# Check external-secrets operator
kubectl logs -f deployment/external-secrets -n external-secrets-system

# Check AWS Load Balancer Controller
kubectl logs -f deployment/aws-load-balancer-controller -n kube-system
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Test your changes
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For issues and questions:
1. Check the troubleshooting section
2. Review AWS and Kubernetes documentation
3. Open an issue in this repository
