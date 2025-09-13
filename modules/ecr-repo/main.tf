# ECR Repository
resource "aws_ecr_repository" "repos" {
  count = length(var.repository_names)

  name                 = "${var.project_name}-${var.environment}-${var.repository_names[count.index]}"
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-${var.repository_names[count.index]}"
  })
}

# ECR Repository Policy (optional - for cross-account access)
resource "aws_ecr_repository_policy" "policy" {
  count = length(var.repository_names)

  repository = aws_ecr_repository.repos[count.index].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPull"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetAuthorizationToken"
        ]
      }
    ]
  })
}
 
# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}
