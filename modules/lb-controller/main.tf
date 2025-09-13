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
  version          = lookup(var.helm, "version", null)
  namespace        = lookup(var.helm, "namespace", var.namespace)
  cleanup_on_fail  = lookup(var.helm, "cleanup_on_fail", true)
  timeout          = 600
  wait             = true
  wait_for_jobs    = true

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

      # Remove pod anti-affinity since we're running single replica
      affinity = {}

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
      
      # Webhook configurations
      webhook = {
        create = true
        port = 9443
        hostNetwork = false
        hostPort = null
      }
      
      # Health check configurations
      healthCheck = {
        enabled = true
        port = 61779
        path = "/healthz"
      }
      
      # Readiness probe configuration
      readinessProbe = {
        enabled = true
        port = 61779
        path = "/healthz"
        initialDelaySeconds = 10
        periodSeconds = 10
        timeoutSeconds = 10
        failureThreshold = 2
      }
      
      # Liveness probe configuration
      livenessProbe = {
        enabled = true
        port = 61779
        path = "/healthz"
        initialDelaySeconds = 30
        periodSeconds = 10
        timeoutSeconds = 10
        failureThreshold = 2
      }

      # Metrics
      enableMetrics = true
      metricsBindAddr = ":8080"

      # Leader election configuration
      enableLeaderElection = true
      leaderElectionID     = "aws-load-balancer-controller-leader"
      leaderElectionNamespace = var.namespace
      leaderElectionLeaseDuration = "15s"
      leaderElectionRenewDeadline = "10s"
      leaderElectionRetryPeriod = "2s"
      
      # Additional stability configurations
      syncPeriod = "30s"
      ingressClass = "alb"
      
      # Disable problematic features that can cause conflicts
      enableServiceMutatorWebhook = false
      enablePodReadinessGateInject = true
      
      # Additional controller stability settings
      controllerConfig = {
        enableShield = var.enable_shield
        enableWaf = var.enable_waf
        enableWafv2 = var.enable_wafv2
        enableCertManager = var.enable_cert_manager
      }
    })
  ]

  depends_on = [
    kubernetes_service_account.aws_load_balancer_controller,
    aws_iam_role_policy_attachment.aws_load_balancer_controller,
  ]
}


# Data source to get current AWS region
data "aws_region" "current" {}
