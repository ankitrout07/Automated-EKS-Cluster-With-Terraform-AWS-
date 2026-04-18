<<<<<<< HEAD
resource "aws_iam_policy" "cloudwatch_agent_policy" {
  name        = "${var.cluster_name}-cloudwatch-policy"
  description = "Allows EKS pods to send metrics to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "cloudwatch:PutMetricData",
          "ec2:DescribeVolumes",
          "ec2:DescribeTags",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
          "logs:CreateLogStream",
          "logs:CreateLogGroup"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

module "cloudwatch_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "${var.cluster_name}-cloudwatch-role"
  
  role_policy_arns = {
    policy = aws_iam_policy.cloudwatch_agent_policy.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["amazon-cloudwatch:cloudwatch-agent"]
    }
  }
}
=======
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
>>>>>>> 86e624dfdcd8934ade7559f44f6bb5c4a32f3d62
