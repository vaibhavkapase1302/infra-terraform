# Security Group for NLB Targets (Network Load Balancer doesn't use security groups)
# But we need one for the targets
resource "aws_security_group" "nlb_targets" {
  name        = "${var.project_name}-${var.environment}-nlb-targets-sg"
  description = "Security group for NLB targets"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from NLB"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.public_subnet_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-nlb-targets-sg"
  })
}
