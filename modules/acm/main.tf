# ACM Certificate for wildcard subdomain (covers all subdomains)
resource "aws_acm_certificate" "wildcard" {
  domain_name               = "*.${var.domain_name}"
  subject_alternative_names = ["${var.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-wildcard-${var.domain_name}"
  })
}

# Note: Certificate validation will be done manually in Route 53
# You'll need to add the DNS validation records manually to your domain's DNS
