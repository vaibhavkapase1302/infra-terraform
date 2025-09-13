#!/bin/bash

# EKS Infrastructure Deployment Script
# Usage: ./deploy.sh [dev|stage|prod]

set -e

ENVIRONMENT=${1:-dev}
PROJECT_NAME="myapp"

echo "🚀 Deploying EKS infrastructure for environment: $ENVIRONMENT"

# Check if environment tfvars file exists
TFVARS_FILE="envs/$ENVIRONMENT/infra.tfvars"
if [ ! -f "$TFVARS_FILE" ]; then
    echo "❌ Error: Environment file $TFVARS_FILE not found"
    echo "Please create the environment-specific variables file"
    exit 1
fi

# Check if backend.tfvars exists
if [ ! -f "backend.tfvars" ]; then
    echo "❌ Error: backend.tfvars not found"
    echo "Please copy backend.tfvars.example to backend.tfvars and configure it"
    exit 1
fi

# Check AWS credentials
echo "🔍 Checking AWS credentials..."
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo "❌ Error: AWS credentials not configured"
    echo "Please run 'aws configure' or set AWS environment variables"
    exit 1
fi

# Initialize Terraform
echo "📦 Initializing Terraform..."
terraform init -backend-config=backend.tfvars

# Validate configuration
echo "✅ Validating Terraform configuration..."
terraform validate

# Plan deployment
echo "📋 Planning deployment..."
terraform plan -var-file="$TFVARS_FILE" -out=tfplan

# Ask for confirmation
echo ""
read -p "🤔 Do you want to proceed with the deployment? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Deployment cancelled"
    exit 1
fi

# Apply configuration
echo "🏗️  Applying Terraform configuration..."
terraform apply tfplan

# Get cluster name from outputs
CLUSTER_NAME=$(terraform output -raw eks_cluster_name)
AWS_REGION=$(terraform output -raw aws_region || echo "ap-south-1")

# Configure kubectl
echo "⚙️  Configuring kubectl..."
aws eks update-kubeconfig --region "$AWS_REGION" --name "$CLUSTER_NAME"

# Verify cluster connection
echo "🔍 Verifying cluster connection..."
if kubectl get nodes > /dev/null 2>&1; then
    echo "✅ Successfully connected to EKS cluster"
    kubectl get nodes
else
    echo "❌ Failed to connect to EKS cluster"
    exit 1
fi

# Display useful information
echo ""
echo "🎉 Deployment completed successfully!"
echo ""
echo "📝 Useful commands:"
echo "  • Get nodes: kubectl get nodes"
echo "  • Get all pods: kubectl get pods --all-namespaces"
echo "  • Get ingress controller: kubectl get pods -n ingress-nginx"
echo "  • Get external secrets: kubectl get pods -n external-secrets-system"
echo ""

# Show outputs
echo "📊 Important outputs:"
terraform output

echo ""
echo "🔗 Next steps:"
echo "  1. Deploy your applications to the cluster"
echo "  2. Configure DNS records if using Route53"
echo "  3. Set up monitoring and logging"
echo "  4. Configure external secrets for your applications"

# Clean up plan file
rm -f tfplan
