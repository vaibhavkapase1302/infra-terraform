output "iam_role_arn" {
  description = "IAM role ARN for AWS Load Balancer Controller"
  value       = aws_iam_role.aws_load_balancer_controller.arn
}

output "iam_role_name" {
  description = "IAM role name for AWS Load Balancer Controller"
  value       = aws_iam_role.aws_load_balancer_controller.name
}

output "iam_policy_arn" {
  description = "IAM policy ARN for AWS Load Balancer Controller"
  value       = aws_iam_policy.aws_load_balancer_controller.arn
}

output "service_account_name" {
  description = "Kubernetes service account name for AWS Load Balancer Controller"
  value       = kubernetes_service_account.aws_load_balancer_controller.metadata[0].name
}

output "service_account_namespace" {
  description = "Kubernetes namespace for AWS Load Balancer Controller service account"
  value       = kubernetes_service_account.aws_load_balancer_controller.metadata[0].namespace
}

output "helm_release_status" {
  description = "Status of the AWS Load Balancer Controller Helm release"
  value       = var.enabled ? helm_release.aws_load_balancer_controller[0].status : null
}

output "helm_release_version" {
  description = "Version of the AWS Load Balancer Controller Helm release"
  value       = var.enabled ? helm_release.aws_load_balancer_controller[0].version : null
}
