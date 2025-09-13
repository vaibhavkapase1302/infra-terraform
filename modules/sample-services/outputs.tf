output "namespace" {
  description = "Kubernetes namespace for sample services"
  value       = var.enabled ? kubernetes_namespace.sample_services[0].metadata[0].name : null
}

output "web_app_service_name" {
  description = "Name of the web app service"
  value       = var.enabled ? kubernetes_service.web_app[0].metadata[0].name : null
}

output "api_service_name" {
  description = "Name of the API service"
  value       = var.enabled ? kubernetes_service.api_service[0].metadata[0].name : null
}

output "web_app_deployment_name" {
  description = "Name of the web app deployment"
  value       = var.enabled ? kubernetes_deployment.web_app[0].metadata[0].name : null
}

output "api_deployment_name" {
  description = "Name of the API deployment"
  value       = var.enabled ? kubernetes_deployment.api_service[0].metadata[0].name : null
}
