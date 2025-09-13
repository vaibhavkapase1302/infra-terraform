# Note: Hosted zone is managed externally, outputs are provided by main.tf

output "www_domain_name" {
  description = "Fully qualified domain name for www subdomain"
  value       = aws_route53_record.www.fqdn
}

output "root_domain_name" {
  description = "Fully qualified domain name for root domain"
  value       = aws_route53_record.root.fqdn
}

output "api_domain_name" {
  description = "Fully qualified domain name for api subdomain"
  value       = aws_route53_record.api.fqdn
}

output "traefik_domain_name" {
  description = "Fully qualified domain name for traefik subdomain"
  value       = aws_route53_record.traefik.fqdn
}
