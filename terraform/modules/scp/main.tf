# ============================================================
# REFERENCE IMPLEMENTATION — Sandbox only
# In a real production deployment:
# - Test each SCP in a sandbox OU before attaching to production OUs
# - DenyRegionsOutsideApproved must list ALL regions your organization uses
# - RequireEC2IMDSv2 will break legacy EC2 instances using IMDSv1 — audit first
# - Use aws_organizations_policy_attachment for each OU attachment separately
# See docs/landing-zone-reference.md — Chapter 2 for full context.
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

  # All OUs receive Tier 1 and Tier 2 (all) SCPs
  all_ou_ids = [
    var.security_ou_id,
    var.infrastructure_ou_id,
    var.workloads_ou_id,
  ]
}

# ── TIER 1 — Day 1, non-negotiable ───────────────────────────────────────────

resource "aws_organizations_policy" "deny_root" {
  name        = "DenyRootAccountUsage"
  description = "Prevents use of the root account user in all member accounts"
  type        = "SERVICE_CONTROL_POLICY"
  tags        = local.common_tags

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "DenyRootAccountUsage"
      Effect   = "Deny"
      Action   = "*"
      Resource = "*"
      Condition = {
        StringLike = { "aws:PrincipalArn" = ["arn:aws:iam::*:root"] }
      }
    }]
  })
}

resource "aws_organizations_policy" "deny_regions" {
  name        = "DenyRegionsOutsideApproved"
  description = "Restricts all API calls to the approved region list"
  type        = "SERVICE_CONTROL_POLICY"
  tags        = local.common_tags

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "DenyRegionsOutsideApproved"
      Effect = "Deny"
      NotAction = [
        "iam:*", "organizations:*", "support:*", "sts:*",
        "budgets:*", "cloudfront:*", "route53:*", "waf:*",
        "health:*", "trustedadvisor:*",
      ]
      Resource = "*"
      Condition = {
        StringNotEquals = { "aws:RequestedRegion" = var.approved_regions }
      }
    }]
  })
}

resource "aws_organizations_policy" "deny_disable_cloudtrail" {
  name        = "DenyDisableCloudTrail"
  description = "Prevents deletion or disabling of CloudTrail trails"
  type        = "SERVICE_CONTROL_POLICY"
  tags        = local.common_tags

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "DenyDisableCloudTrail"
      Effect = "Deny"
      Action = [
        "cloudtrail:DeleteTrail",
        "cloudtrail:StopLogging",
        "cloudtrail:UpdateTrail",
        "cloudtrail:PutEventSelectors",
      ]
      Resource = "*"
    }]
  })
}

resource "aws_organizations_policy" "deny_disable_guardduty" {
  name        = "DenyDisableGuardDuty"
  description = "Prevents disabling or tampering with GuardDuty detectors"
  type        = "SERVICE_CONTROL_POLICY"
  tags        = local.common_tags

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "DenyDisableGuardDuty"
      Effect = "Deny"
      Action = [
        "guardduty:DeleteDetector",
        "guardduty:DisassociateFromMasterAccount",
        "guardduty:DisassociateMembers",
        "guardduty:StopMonitoringMembers",
        "guardduty:UpdateDetector",
      ]
      Resource = "*"
    }]
  })
}

resource "aws_organizations_policy" "deny_leave_org" {
  name        = "DenyLeaveOrganization"
  description = "Prevents any account from leaving the organization"
  type        = "SERVICE_CONTROL_POLICY"
  tags        = local.common_tags

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "DenyLeaveOrganization"
      Effect   = "Deny"
      Action   = "organizations:LeaveOrganization"
      Resource = "*"
    }]
  })
}

# ── TIER 2 — Within 30 days ───────────────────────────────────────────────────

resource "aws_organizations_policy" "deny_disable_securityhub" {
  name        = "DenyDisableSecurityHub"
  description = "Prevents disabling Security Hub in any member account"
  type        = "SERVICE_CONTROL_POLICY"
  tags        = local.common_tags

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "DenyDisableSecurityHub"
      Effect   = "Deny"
      Action   = ["securityhub:DeleteHub", "securityhub:DisableSecurityHub"]
      Resource = "*"
    }]
  })
}

resource "aws_organizations_policy" "require_s3_encryption" {
  name        = "RequireS3Encryption"
  description = "Denies S3 PutObject calls that do not use server-side encryption"
  type        = "SERVICE_CONTROL_POLICY"
  tags        = local.common_tags

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "DenyUnencryptedS3Uploads"
      Effect   = "Deny"
      Action   = "s3:PutObject"
      Resource = "*"
      Condition = {
        "Null" = { "s3:x-amz-server-side-encryption" = "true" }
      }
    }]
  })
}

resource "aws_organizations_policy" "require_imdsv2" {
  name        = "RequireEC2IMDSv2"
  description = "Prevents launching EC2 instances without IMDSv2 enforced"
  type        = "SERVICE_CONTROL_POLICY"
  tags        = local.common_tags

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "RequireIMDSv2"
      Effect   = "Deny"
      Action   = "ec2:RunInstances"
      Resource = "arn:aws:ec2:*:*:instance/*"
      Condition = {
        StringNotEquals = { "ec2:MetadataHttpTokens" = "required" }
      }
    }]
  })
}

resource "aws_organizations_policy" "deny_public_s3" {
  name        = "DenyPublicS3Buckets"
  description = "Prevents disabling S3 Block Public Access at the account level"
  type        = "SERVICE_CONTROL_POLICY"
  tags        = local.common_tags

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "DenyPublicS3"
      Effect = "Deny"
      Action = [
        "s3:PutBucketPublicAccessBlock",
        "s3:DeletePublicAccessBlock",
        "s3:PutAccountPublicAccessBlock",
      ]
      Resource = "*"
    }]
  })
}

resource "aws_organizations_policy" "deny_unencrypted_ebs" {
  name        = "DenyUnencryptedEBS"
  description = "Prevents creation of unencrypted EBS volumes"
  type        = "SERVICE_CONTROL_POLICY"
  tags        = local.common_tags

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "DenyUnencryptedEBS"
      Effect   = "Deny"
      Action   = "ec2:CreateVolume"
      Resource = "*"
      Condition = {
        Bool = { "ec2:Encrypted" = "false" }
      }
    }]
  })
}