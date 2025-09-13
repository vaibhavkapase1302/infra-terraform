# IAM Role for AWS Load Balancer Controller
resource "aws_iam_role" "aws_load_balancer_controller" {
  name = "${var.project_name}-${var.environment}-aws-load-balancer-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${var.oidc_issuer_url}:sub" = "system:serviceaccount:${var.namespace}:aws-load-balancer-controller"
            "${var.oidc_issuer_url}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-aws-load-balancer-controller-role"
  })
}

# IAM Policy for AWS Load Balancer Controller
resource "aws_iam_policy" "aws_load_balancer_controller" {
  name        = "${var.project_name}-${var.environment}-aws-load-balancer-controller-policy"
  description = "IAM policy for AWS Load Balancer Controller"

  policy = file("${path.module}/eks-alb-iam-policy.json")

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-aws-load-balancer-controller-policy"
  })
}

# Attach IAM Policy to Role
resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
  role       = aws_iam_role.aws_load_balancer_controller.name
}

# Kubernetes Service Account for AWS Load Balancer Controller
resource "kubernetes_service_account" "aws_load_balancer_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
      "app.kubernetes.io/version"   = var.image_tag
    }
    annotations = {
      "eks.amazonaws.com/role-arn"               = aws_iam_role.aws_load_balancer_controller.arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}

# AWS Load Balancer Controller Helm Release
resource "helm_release" "aws_load_balancer_controller" {
  count            = var.enabled ? 1 : 0
  name             = lookup(var.helm, "name", "aws-load-balancer-controller")
  chart            = lookup(var.helm, "chart", "aws-load-balancer-controller")
  repository       = lookup(var.helm, "repository", "https://aws.github.io/eks-charts")
  version          = lookup(var.helm, "version", var.chart_version)
  namespace        = lookup(var.helm, "namespace", var.namespace)
  cleanup_on_fail  = lookup(var.helm, "cleanup_on_fail", true)

  values = [
    yamlencode({
      clusterName = var.cluster_name
      
      serviceAccount = {
        create = false
        name   = kubernetes_service_account.aws_load_balancer_controller.metadata[0].name
      }

      region = data.aws_region.current.name
      vpcId  = var.vpc_id

      image = {
        tag = var.image_tag
      }

      replicaCount = var.replica_count

      nodeSelector = {
        "kubernetes.io/os" = "linux"
      }

      tolerations = []

      affinity = {
        podAntiAffinity = {
          preferredDuringSchedulingIgnoredDuringExecution = [
            {
              weight = 100
              podAffinityTerm = {
                labelSelector = {
                  matchExpressions = [
                    {
                      key      = "app.kubernetes.io/name"
                      operator = "In"
                      values   = ["aws-load-balancer-controller"]
                    }
                  ]
                }
                topologyKey = "kubernetes.io/hostname"
              }
            }
          ]
        }
      }

      resources = {
        requests = {
          cpu    = "100m"
          memory = "200Mi"
        }
        limits = {
          cpu    = "200m"
          memory = "500Mi"
        }
      }

      # Feature Gates
      enableShield         = var.enable_shield
      enableWaf            = var.enable_waf
      enableWafv2          = var.enable_wafv2
      enableCertManager    = var.enable_cert_manager

      # Logging
      logLevel = var.log_level

      # Security Context
      securityContext = {
        runAsNonRoot = true
        runAsUser    = 65534
        runAsGroup   = 65534
      }

      podSecurityContext = {
        fsGroup = 65534
      }

      # Additional configurations
      defaultSSLPolicy = "ELBSecurityPolicy-TLS-1-2-2017-01"
      
      ingressClassParams = {
        create = true
        name   = "default"
        spec = {
          namespaceSelector = {}
          group             = "elbv2.k8s.aws"
          scheme            = "internet-facing"
        }
      }

      # Webhook configurations
      webhookTLS = {
        caCert = ""
        cert   = ""
        key    = ""
      }

      # Metrics
      enableMetrics = true
      metricsBindAddr = ":8080"

      # Health probes
      enableLeaderElection = true
      leaderElectionID     = "aws-load-balancer-controller-leader"
    })
  ]

  depends_on = [
    kubernetes_service_account.aws_load_balancer_controller,
    aws_iam_role_policy_attachment.aws_load_balancer_controller,
  ]
}

# Data source to get current AWS region
data "aws_region" "current" {}
