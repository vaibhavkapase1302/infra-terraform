output "namespace" {
  description = "Kubernetes namespace where Traefik is deployed"
  value       = kubernetes_namespace.traefik.metadata[0].name
}

output "helm_release_status" {
  description = "Status of the Traefik Helm release"
  value       = var.enabled ? helm_release.traefik[0].status : null
}

output "service_name" {
  description = "Name of the Traefik service"
  value       = var.enabled ? kubernetes_service.traefik[0].metadata[0].name : null
}

output "service_namespace" {
  description = "Namespace of the Traefik service"
  value       = var.enabled ? kubernetes_service.traefik[0].metadata[0].namespace : null
}

output "load_balancer_hostname" {
  description = "Hostname of the Traefik load balancer"
  value = var.enabled ? try(
    kubernetes_service.traefik[0].status[0].load_balancer[0].ingress[0].hostname,
    ""
  ) : null
}

output "load_balancer_ip" {
  description = "IP address of the Traefik load balancer"
  value = var.enabled ? try(
    kubernetes_service.traefik[0].status[0].load_balancer[0].ingress[0].ip,
    ""
  ) : null
}

output "dashboard_url" {
  description = "URL for Traefik dashboard"
  value       = var.enabled ? "https://traefik.${var.domain_name}" : null
}

output "web_url" {
  description = "URL for the web application"
  value       = var.enabled ? "https://www.${var.domain_name}" : null
}

output "api_url" {
  description = "URL for the API"
  value       = var.enabled ? "https://api.${var.domain_name}/api" : null
}