variable "aws_region" {
  description = "Target AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS Cluster Identity"
  type        = string
  default     = "ankit-eks"
}

variable "vpc_cidr" {
  description = "VPC Network Range"
  type        = string
  default     = "10.0.0.0/16"
}