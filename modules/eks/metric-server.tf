# Metrics Server deployment via Helm
resource "helm_release" "metrics_server" {
  count = var.metrics_server ? 1 : 0

  name             = lookup(var.metrics_server_helm, "name", "metrics-server")
  repository       = lookup(var.metrics_server_helm, "repository", "https://kubernetes-sigs.github.io/metrics-server/")
  chart            = lookup(var.metrics_server_helm, "chart", "metrics-server")
  version          = lookup(var.metrics_server_helm, "version", "3.11.0")
  namespace        = lookup(var.metrics_server_helm, "namespace", "kube-system")
  timeout          = lookup(var.metrics_server_helm, "timeout", 600)  # Increased timeout
  cleanup_on_fail  = lookup(var.metrics_server_helm, "cleanup_on_fail", true)
  wait             = true
  wait_for_jobs    = true
  atomic           = true

  values = [
    yamlencode({
      metrics = {
        enabled = true
      }
      serviceMonitor = {
        enabled = false
      }
      args = [
        "--cert-dir=/tmp",
        "--secure-port=4443",
        "--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname",
        "--kubelet-use-node-status-port",
        "--metric-resolution=15s",
        "--kubelet-insecure-tls"  # Add this for EKS compatibility
      ]
      resources = {
        requests = {
          cpu    = "100m"
          memory = "200Mi"
        }
        limits = {
          cpu    = "1000m"
          memory = "1000Mi"
        }
      }
      nodeSelector = {
        "kubernetes.io/os" = "linux"
      }
      tolerations = [
        {
          key      = "node-role.kubernetes.io/control-plane"
          operator = "Exists"
          effect   = "NoSchedule"
        }
      ]
      # Add readiness and liveness probes
      readinessProbe = {
        httpGet = {
          path = "/readyz"
          port = 4443
          scheme = "HTTPS"
        }
        initialDelaySeconds = 20
        periodSeconds = 10
        timeoutSeconds = 5
        failureThreshold = 3
      }
      livenessProbe = {
        httpGet = {
          path = "/livez"
          port = 4443
          scheme = "HTTPS"
        }
        initialDelaySeconds = 30
        periodSeconds = 10
        timeoutSeconds = 5
        failureThreshold = 3
      }
    })
  ]

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main,
    aws_eks_addon.addons,
  ]

  # Add a time delay to ensure cluster is fully ready
  provisioner "local-exec" {
    command = "sleep 30"
  }
}
