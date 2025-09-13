variable "enabled" {
  description = "Enable/disable the sample services module"
  type        = bool
  default     = true
}

variable "namespace" {
  description = "Kubernetes namespace for sample services"
  type        = string
  default     = "sample-services"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}
