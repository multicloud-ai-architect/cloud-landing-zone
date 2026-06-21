# ============================================================
# SANDBOX ENVIRONMENT — for validation only
# Destroy after each session: terraform destroy -auto-approve
# Estimated cost if left running: ~$50/month
# See docs/landing-zone-reference.md for full context.
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

provider "aws" {
  region = var.aws_region
}

locals {
  environment = "dev"
  common_tags = {
    Project     = var.project
    Environment = local.environment
    ManagedBy   = "terraform"
    Owner       = "maia"
    Repository  = "https://github.com/multicloud-ai-architect/cloud-landing-zone"
  }
}

# ── Organizations & OU structure ──────────────────────────────────────────────

module "organizations" {
  source = "../../modules/organizations"

  project     = var.project
  environment = local.environment
  tags        = local.common_tags
}

# ── Service Control Policies ──────────────────────────────────────────────────

module "scp" {
  source = "../../modules/scp"

  project              = var.project
  environment          = local.environment
  tags                 = local.common_tags
  approved_regions     = var.approved_regions
  security_ou_id       = module.organizations.security_ou_id
  infrastructure_ou_id = module.organizations.infrastructure_ou_id
  workloads_ou_id      = module.organizations.workloads_ou_id

  depends_on = [module.organizations]
}

# ── Identity & Access ─────────────────────────────────────────────────────────
# Requires IAM Identity Center to be enabled manually before applying.
# Set group IDs in terraform.tfvars after creating groups in Identity Center.

module "identity" {
  source = "../../modules/identity"

  project     = var.project
  environment = local.environment
  tags        = local.common_tags

  management_account_id  = var.management_account_id
  audit_account_id       = var.audit_account_id
  log_archive_account_id = var.log_archive_account_id

  platform_team_group_id = var.platform_team_group_id
  developers_group_id    = var.developers_group_id
  security_team_group_id = var.security_team_group_id
  finops_group_id        = var.finops_group_id

  depends_on = [module.organizations]
}