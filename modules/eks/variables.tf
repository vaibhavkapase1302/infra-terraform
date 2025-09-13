variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.28"
}

variable "vpc_id" {
  description = "VPC ID where EKS cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for EKS cluster"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EKS node groups"
  type        = list(string)
}

variable "cluster_security_group_id" {
  description = "Security group ID for EKS cluster"
  type        = string
}

variable "nodes_security_group_id" {
  description = "Security group ID for EKS nodes"
  type        = string
}

variable "node_group_instance_types" {
  description = "Instance types for EKS node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_group_desired_size" {
  description = "Desired number of nodes in EKS node group"
  type        = number
  default     = 2
}

variable "node_group_max_size" {
  description = "Maximum number of nodes in EKS node group"
  type        = number
  default     = 5
}

variable "node_group_min_size" {
  description = "Minimum number of nodes in EKS node group"
  type        = number
  default     = 1
}

variable "node_group_capacity_type" {
  description = "Capacity type for EKS node group (ON_DEMAND or SPOT)"
  type        = string
  default     = "ON_DEMAND"
  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_group_capacity_type)
    error_message = "Capacity type must be either ON_DEMAND or SPOT."
  }
}

variable "node_group_ami_type" {
  description = "AMI type for EKS node group"
  type        = string
  default     = "AL2_x86_64"
  validation {
    condition     = contains(["AL2_x86_64", "AL2_ARM_64", "AL2_x86_64_GPU", "AL2_ARM_64_GPU", "BOTTLEROCKET_ARM_64", "BOTTLEROCKET_x86_64", "CUSTOM"], var.node_group_ami_type)
    error_message = "AMI type must be one of: AL2_x86_64, AL2_ARM_64, AL2_x86_64_GPU, AL2_ARM_64_GPU, BOTTLEROCKET_ARM_64, BOTTLEROCKET_x86_64, CUSTOM."
  }
}

variable "node_group_disk_size" {
  description = "Disk size for EKS node group instances"
  type        = number
  default     = 20
}

variable "enable_cluster_endpoint_private_access" {
  description = "Enable private API server endpoint"
  type        = bool
  default     = true
}

variable "enable_cluster_endpoint_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks that can access the public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_enabled_log_types" {
  description = "List of EKS cluster log types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}

# Add-on controls
variable "addons" {
  description = "List of EKS addons to install"
  type = list(object({
    name                        = string
    version                     = string
    enable                      = optional(bool, true)
    resolve_conflicts_on_create = optional(string, "OVERWRITE")
    resolve_conflicts_on_update = optional(string, "OVERWRITE")
    service_account_role_arn    = optional(string, null)
  }))
  default = []
}

# Metrics Server configuration
variable "metrics_server" {
  description = "Enable/disable metrics-server helm release"
  type        = bool
  default     = false
}

variable "metrics_server_helm" {
  description = "Helm release configuration for metrics-server"
  type        = map(any)
  default = {
    repository      = "https://kubernetes-sigs.github.io/metrics-server/"
    name            = "metrics-server"
    chart           = "metrics-server"
    namespace       = "kube-system"
    version         = "3.11.0"
    timeout         = 600  # Increased timeout to 10 minutes
    cleanup_on_fail = true
  }
}
