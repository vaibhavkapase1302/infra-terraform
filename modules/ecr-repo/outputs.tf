output "repository_urls" {
  description = "List of ECR repository URLs"
  value       = aws_ecr_repository.repos[*].repository_url
}

output "repository_arns" {
  description = "List of ECR repository ARNs"
  value       = aws_ecr_repository.repos[*].arn
}

output "repository_names" {
  description = "List of ECR repository names"
  value       = aws_ecr_repository.repos[*].name
}

output "registry_id" {
  description = "The registry ID where the repository was created"
  value       = length(aws_ecr_repository.repos) > 0 ? aws_ecr_repository.repos[0].registry_id : ""
}
