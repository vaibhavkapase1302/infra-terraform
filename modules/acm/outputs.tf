output "certificate_arn" {
  description = "ARN of the wildcard certificate"
  value       = aws_acm_certificate.wildcard.arn
}

output "certificate_domain_name" {
  description = "Domain name of the certificate"
  value       = aws_acm_certificate.wildcard.domain_name
}

output "certificate_status" {
  description = "Status of the certificate"
  value       = aws_acm_certificate.wildcard.status
}

output "certificate_validation_records" {
  description = "DNS validation records that need to be added manually to Route 53"
  value = {
    for dvo in aws_acm_certificate.wildcard.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
}
