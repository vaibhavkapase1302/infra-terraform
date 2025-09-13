output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "availability_zones" {
  description = "Availability zones used"
  value       = var.availability_zones
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = aws_nat_gateway.main[*].id
}

output "eks_cluster_security_group_id" {
  description = "Security group ID for EKS cluster"
  value       = module.security_groups.eks_cluster_security_group_id
}

output "eks_nodes_security_group_id" {
  description = "Security group ID for EKS nodes"
  value       = module.security_groups.eks_nodes_security_group_id
}

output "alb_security_group_id" {
  description = "Security group ID for ALB"
  value       = module.security_groups.alb_security_group_id
}

output "traefik_security_group_id" {
  description = "Security group ID for Traefik"
  value       = module.security_groups.traefik_security_group_id
}

output "rds_security_group_id" {
  description = "Security group ID for RDS"
  value       = module.security_groups.rds_security_group_id
}

output "bastion_security_group_id" {
  description = "Security group ID for bastion host"
  value       = module.security_groups.bastion_security_group_id
}

output "nlb_targets_security_group_id" {
  description = "Security group ID for NLB targets"
  value       = module.security_groups.nlb_targets_security_group_id
}
