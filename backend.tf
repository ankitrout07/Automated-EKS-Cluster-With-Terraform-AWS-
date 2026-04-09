terraform {
  backend "s3" {
    bucket         = "eks-terraform-state"
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-eks-lock-table"
    encrypt        = true
  }
}