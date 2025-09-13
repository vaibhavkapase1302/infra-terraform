# Global Variables
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name (dev, stage, prod)"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "owner" {
  description = "Owner/Team responsible for the infrastructure"
  type        = string
}

# Networking Variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

# EKS Variables
variable "eks_cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.32"
}

variable "eks_node_group_instance_types" {
  description = "Instance types for EKS node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_node_group_desired_size" {
  description = "Desired number of nodes in EKS node group"
  type        = number
  default     = 2
}

variable "eks_node_group_max_size" {
  description = "Maximum number of nodes in EKS node group"
  type        = number
  default     = 5
}

variable "eks_node_group_min_size" {
  description = "Minimum number of nodes in EKS node group"
  type        = number
  default     = 1
}

variable "eks_node_group_ami_type" {
  description = "AMI type for EKS node group"
  type        = string
  default     = "AL2_x86_64"
}

# EKS addon variables surfaced to root
variable "eks_addons" {
  description = "List of EKS addons to install"
  type = list(object({
    name                        = string
    version                     = string
    enable                      = optional(bool, true)
    resolve_conflicts_on_create = optional(string, "OVERWRITE")
    resolve_conflicts_on_update = optional(string, "OVERWRITE")
    service_account_role_arn    = optional(string, null)
  }))
  default = [
    {
      name    = "coredns"
      version = "v1.10.1-eksbuild.5"
    },
    {
      name    = "kube-proxy"
      version = "v1.28.2-eksbuild.2"
    },
    {
      name    = "vpc-cni"
      version = "v1.15.4-eksbuild.1"
    },
    {
      name    = "aws-ebs-csi-driver"
      version = "v1.25.0-eksbuild.1"
    }
  ]
}

# ECR Variables
variable "ecr_repositories" {
  description = "List of ECR repository names to create"
  type        = list(string)
  default     = []
}

variable "enable_external_secrets_stores" {
  description = "Enable creation of External Secrets SecretStore resources (requires live cluster)"
  type        = bool
  default     = false
}

# Common Tags
variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# AWS Secrets Manager names to create (optional)
variable "secret_names" {
  description = "List of secret name suffixes, e.g., [\"service/backend1\", \"service/backend1\"]"
  type        = list(string)
  default     = []
}

# Load Balancer Configuration
variable "ssl_certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS listeners"
  type        = string
  default     = ""
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for load balancers"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Main domain name for the application"
  type        = string
  default     = "kubetux.com"
}

variable "enable_traefik_manifests" {
  description = "Enable creation of Traefik Kubernetes manifests (requires live cluster)"
  type        = bool
  default     = false
}
