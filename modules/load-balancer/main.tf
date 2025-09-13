# Application Load Balancer
resource "aws_lb" "alb" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-alb"
  })
}

# Network Load Balancer
resource "aws_lb" "nlb" {
  name               = "${var.project_name}-${var.environment}-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.public_subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-nlb"
  })
}

# ALB Target Group for Traefik
resource "aws_lb_target_group" "traefik" {
  name        = "${var.project_name}-${var.environment}-traefik-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/ping"
    port                = "9000"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-traefik-tg"
  })
}

# NLB Target Group for Internal API
resource "aws_lb_target_group" "internal_api" {
  name        = "${var.project_name}-${var.environment}-internal-api-tg"
  port        = 443
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    port                = "traffic-port"
    protocol            = "TCP"
    timeout             = 10
    unhealthy_threshold = 2
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-internal-api-tg"
  })
}

# ALB Listener for HTTPS (443) - Only create if certificate is provided
resource "aws_lb_listener" "alb_https" {
  count = var.ssl_certificate_arn != "" ? 1 : 0

  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.ssl_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.traefik.arn
  }
}

# ALB Listener for HTTP (80) - Redirect to HTTPS if certificate available, otherwise forward
resource "aws_lb_listener" "alb_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  # When SSL certificate is available, redirect to HTTPS
  count = var.ssl_certificate_arn != "" ? 1 : 0

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# ALB Listener for HTTP (80) - Forward directly when no SSL certificate
resource "aws_lb_listener" "alb_http_forward" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  # When no SSL certificate, forward directly
  count = var.ssl_certificate_arn == "" ? 1 : 0

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.traefik.arn
  }
}

# NLB Listener for Internal API (443)
resource "aws_lb_listener" "nlb_https" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_api.arn
  }
}

