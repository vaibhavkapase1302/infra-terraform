# Environment Configuration
environment  = "dev"
project_name = "myapp"
owner        = "vaibhav.kapase"
aws_region   = "ap-south-1"

# Networking Configuration
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

# EKS Configuration
eks_cluster_version                = "1.32"
eks_node_group_instance_types      = ["t3.medium"]
eks_node_group_ami_type            = "AL2_x86_64"
eks_node_group_desired_size        = 2
eks_node_group_max_size           = 5
eks_node_group_min_size           = 1

# EKS Addons
eks_addons = [
  {
    name    = "coredns"
    version = "v1.11.4-eksbuild.10"
  },
  {
    name    = "kube-proxy"
    version = "v1.32.3-eksbuild.7"
  },
  {
    name    = "vpc-cni"
    version = "v1.19.5-eksbuild.3"
  },
  {
    name    = "aws-ebs-csi-driver"
    version = "v1.47.1-eksbuild.1"
  }
]

# ECR Configuration
ecr_repositories = [
  "web-app",
  "api-service",
  "worker"
]

# AWS Secrets Manager secrets
# secret_names = [
#   "service/backend1",
#   "service/backend2"
# ]
secret_names = []

# Additional Tags
additional_tags = {
  purpose     = "AlgoTest-Test"
  created-by  = "terraform"
}

# Domain Configuration
domain_name = "kubetux.com"

# Enable Traefik Kubernetes manifests for routing (disable for initial deployment)
enable_traefik_manifests = false

# Enable External Secrets stores (after cluster is ready)
enable_external_secrets_stores = false
