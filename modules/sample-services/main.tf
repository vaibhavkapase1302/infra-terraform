# Sample Web Application
resource "kubernetes_deployment" "web_app" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = "algo-test-web"
    namespace = var.namespace
    labels = {
      app = "algo-test-web"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "algo-test-web"
      }
    }

    template {
      metadata {
        labels = {
          app = "algo-test-web"
        }
      }

      spec {
        container {
          name  = "web-app"
          image = "nginx:alpine"
          
          port {
            container_port = 80
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
          }

          # Simple HTML page for testing
          volume_mount {
            name       = "html-content"
            mount_path = "/usr/share/nginx/html"
          }
        }

        volume {
          name = "html-content"
          config_map {
            name = kubernetes_config_map.web_html[0].metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_namespace.sample_services
  ]
}

# Sample API Service
resource "kubernetes_deployment" "api_service" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = "algo-test-api"
    namespace = var.namespace
    labels = {
      app = "algo-test-api"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "algo-test-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "algo-test-api"
        }
      }

      spec {
        container {
          name  = "api-service"
          image = "httpd:alpine"
          
          port {
            container_port = 80
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
          }

          # Simple API response for testing
          volume_mount {
            name       = "api-content"
            mount_path = "/usr/local/apache2/htdocs"
          }
        }

        volume {
          name = "api-content"
          config_map {
            name = kubernetes_config_map.api_html[0].metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_namespace.sample_services
  ]
}

# Namespace for sample services
resource "kubernetes_namespace" "sample_services" {
  count = var.enabled ? 1 : 0

  metadata {
    name = var.namespace
    labels = {
      name = var.namespace
    }
  }
}

# ConfigMap for web app HTML content
resource "kubernetes_config_map" "web_html" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = "web-html-content"
    namespace = var.namespace
  }

  data = {
    "index.html" = <<-EOT
    <!DOCTYPE html>
    <html>
    <head>
        <title>AlgoTest Web App</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; background: #f0f0f0; }
            .container { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            h1 { color: #333; }
            .status { color: #28a745; font-weight: bold; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🚀 AlgoTest Web Application</h1>
            <p class="status">✅ Successfully deployed on EKS!</p>
            <p>This is a sample web application running in your Kubernetes cluster.</p>
            <p><strong>Environment:</strong> ${var.environment}</p>
            <p><strong>Namespace:</strong> ${var.namespace}</p>
            <p><strong>Pod:</strong> <span id="pod-name">Loading...</span></p>
            <script>
                // Simple script to show pod info
                document.getElementById('pod-name').textContent = window.location.hostname;
            </script>
        </div>
    </body>
    </html>
    EOT
  }

  depends_on = [
    kubernetes_namespace.sample_services
  ]
}

# ConfigMap for API service content
resource "kubernetes_config_map" "api_html" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = "api-html-content"
    namespace = var.namespace
  }

  data = {
    "index.html" = <<-EOT
    <!DOCTYPE html>
    <html>
    <head>
        <title>AlgoTest API Service</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; background: #e8f4fd; }
            .container { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            h1 { color: #007bff; }
            .status { color: #28a745; font-weight: bold; }
            .json { background: #f8f9fa; padding: 15px; border-radius: 5px; font-family: monospace; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🔧 AlgoTest API Service</h1>
            <p class="status">✅ API Service is running!</p>
            <p>This is a sample API service running in your Kubernetes cluster.</p>
            <div class="json">
                <pre>{
  "service": "algo-test-api",
  "environment": "${var.environment}",
  "namespace": "${var.namespace}",
  "status": "healthy",
  "timestamp": "<span id="timestamp"></span>",
  "pod": "<span id="pod-name"></span>"
}</pre>
            </div>
            <script>
                document.getElementById('timestamp').textContent = new Date().toISOString();
                document.getElementById('pod-name').textContent = window.location.hostname;
            </script>
        </div>
    </body>
    </html>
    EOT
  }

  depends_on = [
    kubernetes_namespace.sample_services
  ]
}

# Service for web app
resource "kubernetes_service" "web_app" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = "algo-test-web-service"
    namespace = var.namespace
    labels = {
      app = "algo-test-web"
    }
  }

  spec {
    selector = {
      app = "algo-test-web"
    }

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }

  depends_on = [
    kubernetes_deployment.web_app
  ]
}

# Service for API service
resource "kubernetes_service" "api_service" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = "algo-test-api-service"
    namespace = var.namespace
    labels = {
      app = "algo-test-api"
    }
  }

  spec {
    selector = {
      app = "algo-test-api"
    }

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }

  depends_on = [
    kubernetes_deployment.api_service
  ]
}
