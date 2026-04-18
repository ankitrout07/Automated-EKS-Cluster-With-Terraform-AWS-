module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.30"

  cluster_addons = {
    vpc-cni = {
      most_recent    = true
      before_compute = true
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }

  # Network mapping
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Security: Allows you to connect to the cluster API over the internet
  cluster_endpoint_public_access = true

  # IAM: Enables IAM Roles for Service Accounts (OIDC)
  enable_irsa = true

  # Managed Node Groups - The EC2 workers
  eks_managed_node_groups = {
    general = {
      desired_size = 2
      min_size     = 1
      max_size     = 3

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND" # Swap to "SPOT" for maximum cost savings

      # Tags required for cluster autoscaling
      tags = {
        "k8s.io/cluster-autoscaler/enabled" = "true"
        "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
      }
    }
  }

  # Observability: Enable Control Plane logging to CloudWatch
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = {
    Project     = "CoreFour-Project-2"
    Environment = "dev"
  }
}