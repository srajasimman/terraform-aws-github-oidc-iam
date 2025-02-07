terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.0"
    }
  }
}

# Data source to fetch AWS caller identity
data "aws_caller_identity" "current" {}

# Data source to fetch AWS partition (e.g., aws, aws-cn)
data "aws_partition" "current" {}

data "tls_certificate" "this" {
  count = var.create ? 1 : 0

  url = var.url
}

locals {
  provider_url = replace(replace(var.url, "https://", ""), "http://", "")
}

# Create OIDC Identity Provider for GitHub
resource "aws_iam_openid_connect_provider" "github" {
  count = var.create ? 1 : 0

  url             = "https://${local.provider_url}"
  client_id_list  = coalescelist(var.client_id_list, ["sts.${data.aws_partition.current.dns_suffix}"])
  thumbprint_list = distinct(concat(data.tls_certificate.this[0].certificates[*].sha1_fingerprint, var.additional_thumbprints))

  tags = var.tags
}

# Create IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.provider_url}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.provider_url}:aud" = "sts.${data.aws_partition.current.dns_suffix}"
          }
          StringLike = {
            "${local.provider_url}:sub" = var.github_repositories
          }
        }
      }
    ]
  })
}

# Attach Policies to the IAM Role
resource "aws_iam_role_policy_attachment" "github_actions" {
  for_each = toset(var.policy_arns)

  role       = aws_iam_role.github_actions.name
  policy_arn = each.value
}

# Optionally create a custom policy
resource "aws_iam_policy" "github_actions_custom" {
  count = var.create_custom_policy ? 1 : 0

  name        = var.custom_policy_name
  description = "Custom policy for GitHub Actions"
  policy      = var.custom_policy_document
}

# Attach custom policy if created
resource "aws_iam_role_policy_attachment" "github_actions_custom" {
  count = var.create_custom_policy ? 1 : 0

  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_custom[0].arn
}
