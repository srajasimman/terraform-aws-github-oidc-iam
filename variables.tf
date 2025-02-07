variable "create" {
  description = "Controls if resources should be created (affects all resources)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to the resources created"
  type        = map(any)
  default     = {}
}

variable "client_id_list" {
  description = "List of client IDs (also known as audiences) for the IAM OIDC provider. Defaults to STS service if not values are provided"
  type        = list(string)
  default     = []
}

variable "url" {
  description = "The URL of the identity provider. Corresponds to the iss claim"
  type        = string
  default     = "https://token.actions.githubusercontent.com"
}

variable "additional_thumbprints" {
  description = "List of additional thumbprints to add to the thumbprint list."
  type        = list(string)
  # https://github.blog/changelog/2023-06-27-github-actions-update-on-oidc-integration-with-aws/
  default = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]
}

variable "role_name" {
  description = "Name of the IAM role for GitHub Actions"
  type        = string
  default     = "GitHubActionsRole"
}

variable "github_repositories" {
  description = "List of GitHub repositories allowed to assume the role (e.g., 'repo:org/repo:*')"
  type        = list(string)
  default     = ["repo:my-org/my-repo:*"]
}

variable "policy_arns" {
  description = "List of existing policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "create_custom_policy" {
  description = "Whether to create a custom IAM policy"
  type        = bool
  default     = false
}

variable "custom_policy_name" {
  description = "Name of the custom IAM policy"
  type        = string
  default     = "GitHubActionsCustomPolicy"
}

variable "custom_policy_document" {
  description = "Custom IAM policy document"
  type        = string
  default     = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject"
      ],
      "Resource": "*"
    }
  ]
}
EOT
}