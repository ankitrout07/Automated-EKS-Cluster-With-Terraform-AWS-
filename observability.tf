resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "60.0.1"

  # Prometheus configuration: Low retention to save on EBS costs
  set {
    name  = "prometheus.prometheusSpec.retention"
    value = "2d"
  }

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage"
    value = "10Gi"
  }

  # Grafana configuration
  set {
    name  = "grafana.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "grafana.adminPassword"
    value = "admin123" # Recommended: change this after login
  }

  set {
    name  = "grafana.defaultDashboardsEnabled"
    value = "true"
  }

  depends_on = [module.eks, kubernetes_namespace.monitoring]
}
