# EKS Security Groups
output "eks_cluster_security_group_id" {
  description = "Security group ID for EKS cluster"
  value       = aws_security_group.eks_cluster.id
}

output "eks_nodes_security_group_id" {
  description = "Security group ID for EKS nodes"
  value       = aws_security_group.eks_nodes.id
}

# Load Balancer Security Groups
output "alb_security_group_id" {
  description = "Security group ID for ALB"
  value       = aws_security_group.alb.id
}

output "nlb_targets_security_group_id" {
  description = "Security group ID for NLB targets"
  value       = aws_security_group.nlb_targets.id
}

# Traefik Security Group
output "traefik_security_group_id" {
  description = "Security group ID for Traefik"
  value       = aws_security_group.traefik.id
}

# RDS Security Group
output "rds_security_group_id" {
  description = "Security group ID for RDS"
  value       = aws_security_group.rds.id
}

# Bastion Security Group
output "bastion_security_group_id" {
  description = "Security group ID for bastion host"
  value       = aws_security_group.bastion.id
}
