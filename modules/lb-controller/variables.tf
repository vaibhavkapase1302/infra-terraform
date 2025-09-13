variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC Provider for EKS"
  type        = string
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where ALB resources will be created"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for AWS Load Balancer Controller"
  type        = string
  default     = "kube-system"
}

variable "enabled" {
  description = "Enable/disable AWS Load Balancer Controller helm release"
  type        = bool
  default     = true
}

variable "helm" {
  description = "Helm release configuration"
  type        = map(any)
  default = {
    repository      = "https://aws.github.io/eks-charts"
    name            = "aws-load-balancer-controller"
    chart           = "aws-load-balancer-controller"
    namespace       = "kube-system"
    cleanup_on_fail = true
  }
}

variable "chart_version" {
  description = "AWS Load Balancer Controller Helm chart version"
  type        = string
  default     = "1.6.2"
}

variable "image_tag" {
  description = "AWS Load Balancer Controller image tag"
  type        = string
  default     = "v2.6.2"
}

variable "replica_count" {
  description = "Number of AWS Load Balancer Controller replicas"
  type        = number
  default     = 1
  validation {
    condition     = var.replica_count == 1
    error_message = "AWS Load Balancer Controller should run with exactly 1 replica to avoid leader election conflicts."
  }
}

variable "enable_shield" {
  description = "Enable AWS Shield Advanced integration"
  type        = bool
  default     = false
}

variable "enable_waf" {
  description = "Enable AWS WAF integration"
  type        = bool
  default     = false
}

variable "enable_wafv2" {
  description = "Enable AWS WAFv2 integration"
  type        = bool
  default     = true
}

variable "enable_cert_manager" {
  description = "Enable cert-manager integration"
  type        = bool
  default     = false
}

variable "log_level" {
  description = "Log level for AWS Load Balancer Controller"
  type        = string
  default     = "info"
  validation {
    condition     = contains(["debug", "info", "warn", "error"], var.log_level)
    error_message = "Log level must be one of: debug, info, warn, error."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}
