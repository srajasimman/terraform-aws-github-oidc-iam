provider "aws" {
  region = "us-west-2"
}

module "github_oidc_iam" {
  source = "../../"

  role_name = "github-actions-deploy-role"
  github_repositories  = ["repo:srajasimman/*:*"]
  policy_arns          = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
  create_custom_policy = true
  custom_policy_name   = "github-actions-deploy-policy"
  custom_policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::my-bucket",
          "arn:aws:s3:::my-bucket/*"
        ]
      }
    ]
  })
}
