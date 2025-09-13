# Networking Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.networking.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.networking.private_subnet_ids
}

output "availability_zones" {
  description = "Availability zones used"
  value       = module.networking.availability_zones
}

# EKS Outputs
output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_version" {
  description = "EKS cluster Kubernetes version"
  value       = module.eks.cluster_version
}

output "eks_cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

output "eks_cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "eks_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = module.eks.cluster_oidc_issuer_url
}

output "eks_oidc_provider_arn" {
  description = "ARN of the OIDC Provider for EKS"
  value       = module.eks.oidc_provider_arn
}

# ECR Outputs (conditional)
output "ecr_repository_urls" {
  description = "List of ECR repository URLs"
  value       = length(var.ecr_repositories) > 0 ? module.ecr[0].repository_urls : []
}

output "ecr_repository_names" {
  description = "List of ECR repository names"
  value       = length(var.ecr_repositories) > 0 ? module.ecr[0].repository_names : []
}


# External Secrets Outputs
output "external_secrets_namespace" {
  description = "Kubernetes namespace where external-secrets is deployed"
  value       = module.external_secrets.namespace
}

output "external_secrets_iam_role_arn" {
  description = "IAM role ARN for external-secrets service account"
  value       = module.external_secrets.iam_role_arn
}

# Load Balancer Controller Outputs
output "lb_controller_iam_role_arn" {
  description = "IAM role ARN for AWS Load Balancer Controller"
  value       = module.lb_controller.iam_role_arn
}

output "lb_controller_service_account_name" {
  description = "Kubernetes service account name for AWS Load Balancer Controller"
  value       = module.lb_controller.service_account_name
}

# Kubectl Configuration Command
output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

# Useful Commands
# Load Balancer Outputs
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.load_balancer.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = module.load_balancer.alb_zone_id
}

output "nlb_dns_name" {
  description = "DNS name of the Network Load Balancer"
  value       = module.load_balancer.nlb_dns_name
}

output "nlb_zone_id" {
  description = "Zone ID of the Network Load Balancer"
  value       = module.load_balancer.nlb_zone_id
}

# Traefik Ingress Outputs
output "traefik_namespace" {
  description = "Kubernetes namespace where Traefik is deployed"
  value       = module.traefik.namespace
}

output "traefik_load_balancer_hostname" {
  description = "Hostname of the Traefik load balancer"
  value       = module.traefik.load_balancer_hostname
}

output "traefik_dashboard_url" {
  description = "URL for Traefik dashboard"
  value       = module.traefik.dashboard_url
}

output "web_url" {
  description = "URL for the web application"
  value       = module.traefik.web_url
}

output "api_url" {
  description = "URL for the API"
  value       = module.traefik.api_url
}

# Route 53 Outputs (using existing hosted zone)
output "hosted_zone_id" {
  description = "ID of the existing Route 53 hosted zone"
  value       = data.aws_route53_zone.existing.zone_id
}

output "hosted_zone_name_servers" {
  description = "Name servers of the existing Route 53 hosted zone"
  value       = data.aws_route53_zone.existing.name_servers
}

# Manual DNS records to create
output "manual_dns_records" {
  description = "DNS records to create manually in Route 53"
  value = {
    www_domain = "www.kubetux.com"
    api_domain = "api.kubetux.com"
    traefik_domain = "traefik.kubetux.com"
    root_domain = "kubetux.com"
    alb_dns_name = module.load_balancer.alb_dns_name
    alb_zone_id = module.load_balancer.alb_zone_id
  }
}

# ACM Outputs
output "certificate_arn" {
  description = "ARN of the wildcard SSL certificate"
  value       = module.acm.certificate_arn
}

output "certificate_domain_name" {
  description = "Domain name of the SSL certificate"
  value       = module.acm.certificate_domain_name
}

output "certificate_status" {
  description = "Status of the SSL certificate"
  value       = module.acm.certificate_status
}

output "certificate_validation_records" {
  description = "DNS validation records that need to be added manually to Route 53"
  value       = module.acm.certificate_validation_records
}

# Sample Services Outputs
output "sample_services_namespace" {
  description = "Kubernetes namespace for sample services"
  value       = module.sample_services.namespace
}

output "web_app_service_name" {
  description = "Name of the web app service"
  value       = module.sample_services.web_app_service_name
}

output "api_service_name" {
  description = "Name of the API service"
  value       = module.sample_services.api_service_name
}

output "useful_commands" {
  description = "Useful commands for managing the infrastructure"
  value = {
    kubectl_config           = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
    get_nodes               = "kubectl get nodes"
    get_pods_all_namespaces = "kubectl get pods --all-namespaces"
    get_traefik_controller  = "kubectl get pods -n ${module.traefik.namespace}"
    get_external_secrets    = "kubectl get pods -n ${module.external_secrets.namespace}"
    get_sample_services     = module.sample_services.namespace != null ? "kubectl get pods -n ${module.sample_services.namespace}" : "N/A - Sample services not enabled"
    ecr_login              = length(var.ecr_repositories) > 0 ? "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${split("/", module.ecr[0].repository_urls[0])[0]}" : "N/A - No ECR repositories configured"
    certificate_validation  = "Add the DNS validation records from 'certificate_validation_records' output to your domain's DNS to validate the SSL certificate"
    manual_dns_setup       = "Create DNS records in Route 53: www.kubetux.com, api.kubetux.com, traefik.kubetux.com pointing to ALB DNS name"
  }
}
