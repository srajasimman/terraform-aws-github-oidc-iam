# GitHub OIDC and IAM Terraform Module

This Terraform module sets up OIDC and IAM for GitHub Actions in your AWS accounts.

## Features

- Creates an OIDC Identity Provider for GitHub.
- Creates an IAM role for GitHub Actions with configurable policies.
- Supports attaching existing policies or creating custom policies.
- Configurable GitHub repository conditions.

## Usage

```hcl
provider "aws" {
  region = "us-west-2"
}

module "github_oidc_iam" {
  source = "github.com/srajasimman/terraform-aws-github-oidc-iam"

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
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | >= 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_openid_connect_provider.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.github_actions_custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.github_actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.github_actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.github_actions_custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [tls_certificate.this](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_thumbprints"></a> [additional\_thumbprints](#input\_additional\_thumbprints) | List of additional thumbprints to add to the thumbprint list. | `list(string)` | <pre>[<br/>  "6938fd4d98bab03faadb97b34396831e3780aea1",<br/>  "1c58a3a8518e8759bf075b76b750d4f2df264fcd"<br/>]</pre> | no |
| <a name="input_client_id_list"></a> [client\_id\_list](#input\_client\_id\_list) | List of client IDs (also known as audiences) for the IAM OIDC provider. Defaults to STS service if not values are provided | `list(string)` | `[]` | no |
| <a name="input_create"></a> [create](#input\_create) | Controls if resources should be created (affects all resources) | `bool` | `true` | no |
| <a name="input_create_custom_policy"></a> [create\_custom\_policy](#input\_create\_custom\_policy) | Whether to create a custom IAM policy | `bool` | `false` | no |
| <a name="input_custom_policy_document"></a> [custom\_policy\_document](#input\_custom\_policy\_document) | Custom IAM policy document | `string` | `"{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Effect\": \"Allow\",\n      \"Action\": [\n        \"s3:ListBucket\",\n        \"s3:GetObject\"\n      ],\n      \"Resource\": \"*\"\n    }\n  ]\n}\n"` | no |
| <a name="input_custom_policy_name"></a> [custom\_policy\_name](#input\_custom\_policy\_name) | Name of the custom IAM policy | `string` | `"GitHubActionsCustomPolicy"` | no |
| <a name="input_github_repositories"></a> [github\_repositories](#input\_github\_repositories) | List of GitHub repositories allowed to assume the role (e.g., 'repo:org/repo:*') | `list(string)` | <pre>[<br/>  "repo:my-org/my-repo:*"<br/>]</pre> | no |
| <a name="input_policy_arns"></a> [policy\_arns](#input\_policy\_arns) | List of existing policy ARNs to attach to the role | `list(string)` | `[]` | no |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Name of the IAM role for GitHub Actions | `string` | `"GitHubActionsRole"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to the resources created | `map(any)` | `{}` | no |
| <a name="input_url"></a> [url](#input\_url) | The URL of the identity provider. Corresponds to the iss claim | `string` | `"https://token.actions.githubusercontent.com"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | ARN of the IAM role for GitHub Actions |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | Name of the IAM role for GitHub Actions |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | ARN of the OIDC provider |

## License
Distributed under the MIT License. See [LICENSE](LICENSE) for more information.
