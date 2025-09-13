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

variable "oidc_provider_arn" {
  description = "ARN of the OIDC Provider for EKS"
  type        = string
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for external-secrets"
  type        = string
  default     = "external-secrets-system"
}

variable "chart_version" {
  description = "External Secrets Operator Helm chart version"
  type        = string
  default     = "0.9.9"
}

variable "enabled" {
  description = "Enable/disable external-secrets helm release"
  type        = bool
  default     = true
}

variable "helm" {
  description = "Helm release configuration for external-secrets"
  type        = map(any)
  default = {
    repository      = "https://charts.external-secrets.io"
    name            = "external-secrets"
    chart           = "external-secrets"
    namespace       = "external-secrets-system"
    version         = "0.9.9"
    cleanup_on_fail = true
  }
}

variable "enable_cert_controller" {
  description = "Enable cert-controller for certificate management"
  type        = bool
  default     = true
}

variable "enable_webhook" {
  description = "Enable webhook for external-secrets"
  type        = bool
  default     = true
}

variable "enable_secret_stores" {
  description = "Enable creation of SecretStore resources (requires live cluster)"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}
