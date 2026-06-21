# ============================================================
# REFERENCE IMPLEMENTATION — Sandbox only
# In a real production deployment:
# - Organizations must be enabled via the console on the management account first
# - Control Tower creates the Security OU, Log Archive, and Audit accounts automatically
# - The Management account cannot be a member account — it is always the management account
# - Child OUs under Workloads are created as workload teams onboard, not upfront
# See docs/landing-zone-reference.md — Chapter 1 for full context.
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

locals {
  common_tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = "maia"
    Repository  = "https://github.com/multicloud-ai-architect/cloud-landing-zone"
  })
}

# ── Organization ──────────────────────────────────────────────────────────────

resource "aws_organizations_organization" "main" {
  aws_service_access_principals = var.aws_service_access_principals

  # ALL is required for SCPs — CONSOLIDATED_BILLING disables them
  feature_set          = "ALL"
  enabled_policy_types = ["SERVICE_CONTROL_POLICY", "TAG_POLICY"]
}

# ── Root-level OUs ────────────────────────────────────────────────────────────

resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = aws_organizations_organization.main.roots[0].id
}

resource "aws_organizations_organizational_unit" "infrastructure" {
  name      = "Infrastructure"
  parent_id = aws_organizations_organization.main.roots[0].id
}

resource "aws_organizations_organizational_unit" "workloads" {
  name      = "Workloads"
  parent_id = aws_organizations_organization.main.roots[0].id
}

# ── Workloads child OUs ───────────────────────────────────────────────────────

resource "aws_organizations_organizational_unit" "workloads_children" {
  for_each = toset(var.workloads_child_ous)

  name      = each.key
  parent_id = aws_organizations_organizational_unit.workloads.id
}