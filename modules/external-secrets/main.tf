# Namespace for External Secrets
resource "kubernetes_namespace" "external_secrets" {
  metadata {
    name = var.namespace
    labels = {
      name = var.namespace
    }
  }
}

# IAM Role for External Secrets Service Account
resource "aws_iam_role" "external_secrets" {
  name = "${var.project_name}-${var.environment}-external-secrets-role"

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
            "${var.oidc_issuer_url}:sub" = "system:serviceaccount:${var.namespace}:external-secrets"
            "${var.oidc_issuer_url}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-external-secrets-role"
  })
}

# IAM Policy for External Secrets to access AWS Secrets Manager and Parameter Store
resource "aws_iam_role_policy" "external_secrets" {
  name = "${var.project_name}-${var.environment}-external-secrets-policy"
  role = aws_iam_role.external_secrets.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets"
        ]
        Resource = [
          "arn:aws:secretsmanager:*:*:secret:${var.project_name}/${var.environment}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath",
          "ssm:DescribeParameters"
        ]
        Resource = [
          "arn:aws:ssm:*:*:parameter/${var.project_name}/${var.environment}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = [
          "arn:aws:kms:*:*:key/*"
        ]
        Condition = {
          StringEquals = {
            "kms:ViaService" = [
              "secretsmanager.*.amazonaws.com",
              "ssm.*.amazonaws.com"
            ]
          }
        }
      }
    ]
  })
}

# External Secrets Operator Helm Release
resource "helm_release" "external_secrets" {
  count            = var.enabled ? 1 : 0
  name             = lookup(var.helm, "name", "external-secrets")
  chart            = lookup(var.helm, "chart", "external-secrets")
  repository       = lookup(var.helm, "repository", "https://charts.external-secrets.io")
  version          = lookup(var.helm, "version", var.chart_version)
  namespace        = lookup(var.helm, "namespace", kubernetes_namespace.external_secrets.metadata[0].name)
  cleanup_on_fail  = lookup(var.helm, "cleanup_on_fail", true)

  values = [
    yamlencode({
      installCRDs = true
      
      serviceAccount = {
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.external_secrets.arn
        }
        name = "external-secrets"
      }

      securityContext = {
        runAsNonRoot = true
        runAsUser    = 65534
        runAsGroup   = 65534
      }

      resources = {
        requests = {
          cpu    = "100m"
          memory = "128Mi"
        }
        limits = {
          cpu    = "500m"
          memory = "512Mi"
        }
      }

      webhook = {
        create = var.enable_webhook
        
        resources = {
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
        }
      }

      certController = {
        create = var.enable_cert_controller
        
        resources = {
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
        }
      }

      nodeSelector = {
        "kubernetes.io/os" = "linux"
      }

      tolerations = []

      affinity = {}
    })
  ]

  depends_on = [
    kubernetes_namespace.external_secrets
  ]
}

## ClusterSecretStore for AWS Secrets Manager (cluster-scoped)
resource "kubernetes_manifest" "clustersecretstore_aws_sm" {
  count = var.enable_secret_stores ? 1 : 0

  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ClusterSecretStore"

    metadata = {
      name = "aws-secretsmanager"
    }

    spec = {
      provider = {
        aws = {
          service = "SecretsManager"
          region  = data.aws_region.current.name

          auth = {
            jwt = {
              serviceAccountRef = {
                name = "external-secrets"
                namespace = var.namespace
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.external_secrets
  ]
}

## ClusterSecretStore for AWS Systems Manager Parameter Store (optional example)
resource "kubernetes_manifest" "clustersecretstore_aws_ps" {
  count = var.enable_secret_stores ? 1 : 0

  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ClusterSecretStore"

    metadata = {
      name = "aws-parameterstore"
    }

    spec = {
      provider = {
        aws = {
          service = "ParameterStore"
          region  = data.aws_region.current.name

          auth = {
            jwt = {
              serviceAccountRef = {
                name = "external-secrets"
                namespace = var.namespace
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.external_secrets
  ]
}



# Data source to get current AWS region
data "aws_region" "current" {}
