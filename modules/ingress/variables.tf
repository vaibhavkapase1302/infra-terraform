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

variable "cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
}

variable "cluster_certificate_authority_data" {
  description = "EKS cluster certificate authority data"
  type        = string
}

variable "traefik_security_group_id" {
  description = "Security group ID for Traefik"
  type        = string
}

variable "traefik_target_group_arn" {
  description = "ARN of the Traefik target group"
  type        = string
}

variable "domain_name" {
  description = "Main domain name (e.g., kubetux.com)"
  type        = string
  default     = "kubetux.com"
}

variable "namespace" {
  description = "Kubernetes namespace for Traefik"
  type        = string
  default     = "traefik"
}

variable "enabled" {
  description = "Enable/disable Traefik helm release"
  type        = bool
  default     = true
}

variable "enable_kubernetes_manifests" {
  description = "Enable creation of Kubernetes manifests (requires live cluster)"
  type        = bool
  default     = false
}

variable "helm" {
  description = "Helm release configuration for Traefik"
  type        = map(any)
  default = {
    repository      = "https://traefik.github.io/charts"
    name            = "traefik"
    chart           = "traefik"
    namespace       = "traefik"
    version         = "26.1.0"
    cleanup_on_fail = true
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}