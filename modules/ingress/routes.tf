# IngressRoute for algo-test-web (Frontend)
resource "kubernetes_manifest" "algo_test_web" {
  count = var.enabled && var.enable_kubernetes_manifests ? 1 : 0

  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "algo-test-web"
      namespace = var.namespace
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`www.${var.domain_name}`) || Host(`${var.domain_name}`)"
          kind  = "Rule"
          services = [
            {
              name      = "algo-test-web-service"
              namespace = "sample-services"
              port      = 80
            }
          ]
          middlewares = [
            {
              name = "security-headers"
            }
          ]
        }
      ]
      tls = {
        secretName = "algo-test-web-tls"
      }
    }
  }

  depends_on = [
    helm_release.traefik,
    kubernetes_manifest.security_headers
  ]
}

# IngressRoute for algo-test-api (Backend API)
resource "kubernetes_manifest" "algo_test_api" {
  count = var.enabled && var.enable_kubernetes_manifests ? 1 : 0

  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "algo-test-api"
      namespace = var.namespace
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`api.${var.domain_name}`) && PathPrefix(`/api`)"
          kind  = "Rule"
          services = [
            {
              name      = "algo-test-api-service"
              namespace = "sample-services"
              port      = 80
            }
          ]
          middlewares = [
            {
              name = "cors"
            },
            {
              name = "rate-limit"
            },
            {
              name = "security-headers"
            }
          ]
        }
      ]
      tls = {
        secretName = "algo-test-api-tls"
      }
    }
  }

  depends_on = [
    helm_release.traefik,
    kubernetes_manifest.cors,
    kubernetes_manifest.rate_limit,
    kubernetes_manifest.security_headers
  ]
}

# IngressRoute for Traefik Dashboard (optional)
resource "kubernetes_manifest" "traefik_dashboard" {
  count = var.enabled && var.enable_kubernetes_manifests ? 1 : 0

  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "traefik-dashboard"
      namespace = var.namespace
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`traefik.${var.domain_name}`) && PathPrefix(`/`)"
          kind  = "Rule"
          services = [
            {
              name = "api@internal"
            }
          ]
          middlewares = [
            {
              name = "basic-auth"
            }
          ]
        }
      ]
      tls = {
        secretName = "traefik-dashboard-tls"
      }
    }
  }

  depends_on = [
    helm_release.traefik,
    kubernetes_manifest.basic_auth
  ]
}

# HTTP to HTTPS redirect for web
resource "kubernetes_manifest" "web_redirect" {
  count = var.enabled && var.enable_kubernetes_manifests ? 1 : 0

  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "web-redirect"
      namespace = var.namespace
    }
    spec = {
      entryPoints = ["web"]
      routes = [
        {
          match = "Host(`www.${var.domain_name}`) || Host(`${var.domain_name}`) || Host(`api.${var.domain_name}`)"
          kind  = "Rule"
          services = [
            {
              name = "api@internal"
            }
          ]
          middlewares = [
            {
              name = "https-redirect"
            }
          ]
        }
      ]
    }
  }

  depends_on = [
    helm_release.traefik,
    kubernetes_manifest.https_redirect
  ]
}
