# Namespace for Traefik
resource "kubernetes_namespace" "traefik" {
  metadata {
    name = var.namespace
    labels = {
      name = var.namespace
      "app.kubernetes.io/name" = "traefik"
      "app.kubernetes.io/instance" = "traefik"
    }
  }
}

# Traefik Ingress Controller Helm Release
resource "helm_release" "traefik" {
  count            = var.enabled ? 1 : 0
  name             = lookup(var.helm, "name", "traefik")
  chart            = lookup(var.helm, "chart", "traefik")
  repository       = lookup(var.helm, "repository", "https://traefik.github.io/charts")
  version          = lookup(var.helm, "version", "26.1.0")
  namespace        = lookup(var.helm, "namespace", kubernetes_namespace.traefik.metadata[0].name)
  cleanup_on_fail  = lookup(var.helm, "cleanup_on_fail", true)
  timeout          = 600
  wait             = true
  wait_for_jobs    = true

  values = [
    yamlencode({
      # Global configuration
      globalArguments = [
        "--global.checkNewVersion=false",
        "--global.sendAnonymousUsage=false"
      ]

      # Additional arguments
      additionalArguments = [
        "--api.dashboard=true",
        "--api.insecure=false",
        "--providers.kubernetescrd",
        "--providers.kubernetesingress",
        "--entrypoints.web.address=:8080",
        "--entrypoints.websecure.address=:8443",
        "--certificatesresolvers.letsencrypt.acme.tlschallenge=true",
        "--certificatesresolvers.letsencrypt.acme.email=admin@${var.domain_name}",
        "--certificatesresolvers.letsencrypt.acme.storage=/data/acme.json",
        "--log.level=INFO",
        "--accesslog=true",
        "--metrics.prometheus=true"
      ]

      # Service configuration
      service = {
        type = "LoadBalancer"
        annotations = {
          "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
          "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" = "tcp"
          "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled" = "true"
          "service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout" = "60"
        }
        spec = {
          loadBalancerSourceRanges = ["0.0.0.0/0"]
        }
      }

      # Ports configuration
      ports = {
        web = {
          port = 8080
          expose = true
          exposedPort = 80
          protocol = "TCP"
        }
        websecure = {
          port = 8443
          expose = true
          exposedPort = 443
          protocol = "TCP"
        }
        traefik = {
          port = 9000
          expose = true
          protocol = "TCP"
        }
      }

      # Deployment configuration
      deployment = {
        replicas = 1
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
        podAnnotations = {
          "prometheus.io/scrape" = "true"
          "prometheus.io/port"   = "8080"
        }
      }

      # Security context
      securityContext = {
        runAsNonRoot = true
        runAsUser    = 65532
        runAsGroup   = 65532
        fsGroup      = 65532
      }

      # Node selector and tolerations
      nodeSelector = {
        "kubernetes.io/os" = "linux"
      }

      tolerations = []

      # Affinity for high availability
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
                      values   = ["traefik"]
                    }
                  ]
                }
                topologyKey = "kubernetes.io/hostname"
              }
            }
          ]
        }
      }

      # Ingress class configuration
      ingressClass = {
        enabled = true
        isDefaultClass = true
      }

      # Metrics configuration
      metrics = {
        prometheus = {
          enabled = true
          addEntryPointsLabels = true
          addServicesLabels = true
        }
      }

      # Dashboard configuration
      dashboard = {
        enabled = true
        ingressRoute = true
      }

      # Pilot configuration
      pilot = {
        enabled = false
      }
      # 👇 this makes sure Traefik CRDs are installed
      installCRDs = true
    })
  ]

  depends_on = [
    kubernetes_namespace.traefik
  ]
}

# Service for Traefik (to get the LoadBalancer endpoint)
resource "kubernetes_service" "traefik" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = "traefik"
    namespace = kubernetes_namespace.traefik.metadata[0].name
  }

  spec {
    type = "LoadBalancer"
    selector = {
      "app.kubernetes.io/name" = "traefik"
    }
    port {
      name        = "web"
      port        = 80
      target_port = 8080
      protocol    = "TCP"
    }
    port {
      name        = "websecure"
      port        = 443
      target_port = 8443
      protocol    = "TCP"
    }
  }

  depends_on = [
    helm_release.traefik
  ]
}