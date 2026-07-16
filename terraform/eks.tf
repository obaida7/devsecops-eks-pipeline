module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.30"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  # Enable OIDC provider for IRSA
  enable_irsa = true

  eks_managed_node_groups = {
    general = {
      desired_size = 2
      min_size     = 1
      max_size     = 4

      instance_types = ["m5.large"]
      capacity_type  = "ON_DEMAND"
    }
  }
}

# ------------------------------------------------------------------------------
# IAM Role for Service Accounts (IRSA) - Zero Trust access for our FastAPI pod
# ------------------------------------------------------------------------------
module "iam_eks_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version   = "~> 5.0"
  role_name = "${var.cluster_name}-finance-api-role"

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["default:finance-api-sa"]
    }
  }

  role_policy_arns = {
    # Example: Granting read-only access to a specific S3 bucket (if it existed)
    # AmazonS3ReadOnlyAccess = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  }
}
