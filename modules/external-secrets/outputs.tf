output "namespace" {
  description = "Kubernetes namespace where external-secrets is deployed"
  value       = kubernetes_namespace.external_secrets.metadata[0].name
}

output "iam_role_arn" {
  description = "IAM role ARN for external-secrets service account"
  value       = aws_iam_role.external_secrets.arn
}

output "iam_role_name" {
  description = "IAM role name for external-secrets service account"
  value       = aws_iam_role.external_secrets.name
}

output "helm_release_status" {
  description = "Status of the external-secrets Helm release"
  value       = var.enabled ? helm_release.external_secrets[0].status : null
}

output "clustersecretstore_aws_sm_name" {
  description = "Name of the AWS Secrets Manager ClusterSecretStore"
  value       = var.enable_secret_stores ? kubernetes_manifest.clustersecretstore_aws_sm[0].manifest.metadata.name : null
}

output "clustersecretstore_aws_ps_name" {
  description = "Name of the AWS Parameter Store ClusterSecretStore"
  value       = var.enable_secret_stores ? kubernetes_manifest.clustersecretstore_aws_ps[0].manifest.metadata.name : null
}
