# Local values for common configuration
locals {
  common_tags = merge(var.additional_tags, {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    ManagedBy   = "Terraform"
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
  })

  # Naming convention
  name_prefix = "${var.project_name}-${var.environment}"
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

# Reference existing Route 53 hosted zone
data "aws_route53_zone" "existing" {
  zone_id = "Z00400341AOCKDAYPE8NU"
}

# Networking Module
module "networking" {
  source = "./modules/networking"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr            = var.vpc_cidr
  availability_zones  = length(var.availability_zones) > 0 ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  common_tags          = local.common_tags
}

# ECR Module (optional - only if repositories are specified)
module "ecr" {
  source = "./modules/ecr-repo"
  count  = length(var.ecr_repositories) > 0 ? 1 : 0

  project_name      = var.project_name
  environment       = var.environment
  repository_names  = var.ecr_repositories
  common_tags       = local.common_tags
}

# EKS Module
module "eks" {
  source = "./modules/eks"

  project_name                    = var.project_name
  environment                     = var.environment
  cluster_version                 = var.eks_cluster_version
  vpc_id                         = module.networking.vpc_id
  subnet_ids                     = concat(module.networking.private_subnet_ids, module.networking.public_subnet_ids)
  private_subnet_ids             = module.networking.private_subnet_ids
  cluster_security_group_id      = module.networking.eks_cluster_security_group_id
  nodes_security_group_id        = module.networking.eks_nodes_security_group_id
  node_group_instance_types      = var.eks_node_group_instance_types
  node_group_desired_size        = var.eks_node_group_desired_size
  node_group_max_size            = var.eks_node_group_max_size
  node_group_min_size            = var.eks_node_group_min_size
  node_group_ami_type            = var.eks_node_group_ami_type
  common_tags                    = local.common_tags

  # addons
  addons = var.eks_addons

  depends_on = [
    module.networking
  ]
}

# External Secrets Module
module "external_secrets" {
  source = "./modules/external-secrets"

  project_name                        = var.project_name
  environment                         = var.environment
  cluster_name                        = module.eks.cluster_name
  cluster_endpoint                    = module.eks.cluster_endpoint
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
  oidc_provider_arn                  = module.eks.oidc_provider_arn
  oidc_issuer_url                    = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  enable_secret_stores               = var.enable_external_secrets_stores
  common_tags                        = local.common_tags

  depends_on = [
    module.eks
  ]
}

# Traefik Ingress Module
module "traefik" {
  source = "./modules/ingress"

  project_name                        = var.project_name
  environment                         = var.environment
  cluster_name                        = module.eks.cluster_name
  cluster_endpoint                    = module.eks.cluster_endpoint
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
  traefik_security_group_id          = module.networking.traefik_security_group_id
  traefik_target_group_arn           = module.load_balancer.traefik_target_group_arn
  domain_name                         = var.domain_name
  enable_kubernetes_manifests        = var.enable_traefik_manifests
  common_tags                         = local.common_tags

  depends_on = [
    module.eks,
    module.load_balancer
  ]
}

# Load Balancer Module
module "load_balancer" {
  source = "./modules/load-balancer"

  project_name                = var.project_name
  environment                 = var.environment
  vpc_id                     = module.networking.vpc_id
  public_subnet_ids          = module.networking.public_subnet_ids
  public_subnet_cidrs        = var.public_subnet_cidrs
  alb_security_group_id      = module.networking.alb_security_group_id
  nlb_targets_security_group_id = module.networking.nlb_targets_security_group_id
  ssl_certificate_arn        = module.acm.certificate_arn
  enable_deletion_protection = var.enable_deletion_protection
  common_tags                = local.common_tags

  depends_on = [
    module.networking,
    module.acm
  ]
}

# AWS Load Balancer Controller Module
module "lb_controller" {
  source = "./modules/lb-controller"

  project_name      = var.project_name
  environment       = var.environment
  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_issuer_url   = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  vpc_id            = module.networking.vpc_id
  common_tags       = local.common_tags

  depends_on = [
    module.eks
  ]
}

# ACM Module for SSL Certificates
module "acm" {
  source = "./modules/acm"

  project_name = var.project_name
  environment  = var.environment
  domain_name  = var.domain_name
  common_tags  = local.common_tags
}

# Route 53 DNS Records (using existing hosted zone)
# Commented out - manage DNS records manually
# module "route53" {
#   source = "./modules/route53"
# 
#   project_name    = var.project_name
#   environment     = var.environment
#   domain_name     = var.domain_name
#   hosted_zone_id  = data.aws_route53_zone.existing.zone_id
#   alb_dns_name    = module.load_balancer.alb_dns_name
#   alb_zone_id     = module.load_balancer.alb_zone_id
#   common_tags     = local.common_tags
# 
#   depends_on = [
#     module.load_balancer
#   ]
# }

# Sample Services Module
module "sample_services" {
  source = "./modules/sample-services"

  project_name = var.project_name
  environment  = var.environment
  enabled      = var.enable_sample_services

  depends_on = [
    module.eks
  ]
}

# AWS Secrets Manager secrets
# values for secret_names are like [service/backend1, service/backend2]
locals {
  secret_names = var.secret_names
}

resource "aws_secretsmanager_secret" "service_secrets" {
  for_each = toset(local.secret_names)
  name     = "/${var.environment}/${each.value}"

  tags = merge(local.common_tags, {
    Name = "/${var.environment}/${each.value}"
  })
}
