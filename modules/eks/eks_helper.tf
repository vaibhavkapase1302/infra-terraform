# EKS Helper resources for managing cluster configuration

# OIDC issuer URL for service account role mappings
locals {
  oidc_issuer_url = replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")
}

# Data source to get current AWS account ID and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
