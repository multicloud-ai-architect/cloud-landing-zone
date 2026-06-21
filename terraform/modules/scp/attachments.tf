# ── Tier 1 — attach to all OUs ────────────────────────────────────────────────

locals {
  tier1_policy_ids = [
    aws_organizations_policy.deny_root.id,
    aws_organizations_policy.deny_regions.id,
    aws_organizations_policy.deny_disable_cloudtrail.id,
    aws_organizations_policy.deny_disable_guardduty.id,
    aws_organizations_policy.deny_leave_org.id,
  ]

  tier2_all_ou_policy_ids = [
    aws_organizations_policy.deny_disable_securityhub.id,
    aws_organizations_policy.require_s3_encryption.id,
    aws_organizations_policy.require_imdsv2.id,
  ]

  # DenyPublicS3 and DenyUnencryptedEBS apply to Workloads OU only —
  # Security and Infrastructure accounts may have different requirements
  workloads_only_policy_ids = [
    aws_organizations_policy.deny_public_s3.id,
    aws_organizations_policy.deny_unencrypted_ebs.id,
  ]
}

resource "aws_organizations_policy_attachment" "tier1" {
  for_each = toset(flatten([
    for ou_id in local.all_ou_ids : [
      for policy_id in local.tier1_policy_ids : "${ou_id}:${policy_id}"
    ]
  ]))

  target_id = split(":", each.key)[0]
  policy_id = split(":", each.key)[1]
}

# ── Tier 2 — attach to all OUs ────────────────────────────────────────────────

resource "aws_organizations_policy_attachment" "tier2_all" {
  for_each = toset(flatten([
    for ou_id in local.all_ou_ids : [
      for policy_id in local.tier2_all_ou_policy_ids : "${ou_id}:${policy_id}"
    ]
  ]))

  target_id = split(":", each.key)[0]
  policy_id = split(":", each.key)[1]
}

# ── Tier 2 — Workloads OU only ────────────────────────────────────────────────

resource "aws_organizations_policy_attachment" "tier2_workloads" {
  for_each = toset(local.workloads_only_policy_ids)

  target_id = var.workloads_ou_id
  policy_id = each.key
}