# Middleware for HTTPS redirect
resource "kubernetes_manifest" "https_redirect" {
  count = var.enabled && var.enable_kubernetes_manifests ? 1 : 0

  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "https-redirect"
      namespace = var.namespace
    }
    spec = {
      redirectScheme = {
        scheme = "https"
        permanent = true
      }
    }
  }

  depends_on = [
    helm_release.traefik
  ]
}

# Middleware for security headers
resource "kubernetes_manifest" "security_headers" {
  count = var.enabled && var.enable_kubernetes_manifests ? 1 : 0

  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "security-headers"
      namespace = var.namespace
    }
    spec = {
      headers = {
        customRequestHeaders = {
          "X-Forwarded-Proto" = "https"
        }
        customResponseHeaders = {
          "X-Frame-Options" = "DENY"
          "X-Content-Type-Options" = "nosniff"
          "X-XSS-Protection" = "1; mode=block"
          "Referrer-Policy" = "strict-origin-when-cross-origin"
          "Strict-Transport-Security" = "max-age=31536000; includeSubDomains"
        }
      }
    }
  }

  depends_on = [
    helm_release.traefik
  ]
}

# Middleware for CORS (for API)
resource "kubernetes_manifest" "cors" {
  count = var.enabled && var.enable_kubernetes_manifests ? 1 : 0

  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "cors"
      namespace = var.namespace
    }
    spec = {
      headers = {
        accessControlAllowMethods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
        accessControlAllowOriginList = ["https://${var.domain_name}", "https://www.${var.domain_name}"]
        accessControlAllowHeaders = ["*"]
        accessControlMaxAge = 100
        addVaryHeader = true
      }
    }
  }

  depends_on = [
    helm_release.traefik
  ]
}

# Middleware for rate limiting
resource "kubernetes_manifest" "rate_limit" {
  count = var.enabled && var.enable_kubernetes_manifests ? 1 : 0

  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "rate-limit"
      namespace = var.namespace
    }
    spec = {
      rateLimit = {
        burst = 100
        average = 50
      }
    }
  }

  depends_on = [
    helm_release.traefik
  ]
}

# Middleware for basic auth (optional, for dashboard)
resource "kubernetes_manifest" "basic_auth" {
  count = var.enabled && var.enable_kubernetes_manifests ? 1 : 0

  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "basic-auth"
      namespace = var.namespace
    }
    spec = {
      basicAuth = {
        secret = "traefik-dashboard-auth"
      }
    }
  }

  depends_on = [
    helm_release.traefik
  ]
}
