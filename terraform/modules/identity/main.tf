# ============================================================
# REFERENCE IMPLEMENTATION — Sandbox only
# In a real production deployment:
# - IAM Identity Center is enabled at the organization level via the console
#   before applying Terraform (cannot be enabled via Terraform directly)
# - The identity store ID and instance ARN are discovered from the existing
#   IAM Identity Center deployment, not created by Terraform
# - Account assignments require all target accounts to exist first
# - Permission set changes take effect immediately for active sessions —
#   users may need to re-authenticate to see changes
# See docs/landing-zone-reference.md — Chapter 5 for full context.
# ============================================================

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ── Discover IAM Identity Center instance ────────────────────────────────────
# IAM Identity Center must be enabled manually in the management account
# before this data source can resolve.

data "aws_ssoadmin_instances" "main" {}

locals {
  sso_instance_arn  = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  identity_store_id = tolist(data.aws_ssoadmin_instances.main.identity_store_ids)[0]

  common_tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = "maia"
    Repository  = "https://github.com/multicloud-ai-architect/cloud-landing-zone"
  })
}