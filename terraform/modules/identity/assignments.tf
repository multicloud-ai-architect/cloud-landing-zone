# ── Platform team — AdministratorAccess in Management/Security/Network ────────

resource "aws_ssoadmin_account_assignment" "platform_admin_mgmt" {
  count = var.platform_team_group_id != "" ? 1 : 0

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.administrator.arn
  principal_id       = var.platform_team_group_id
  principal_type     = "GROUP"
  target_id          = var.management_account_id
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "platform_admin_audit" {
  count = var.platform_team_group_id != "" ? 1 : 0

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.administrator.arn
  principal_id       = var.platform_team_group_id
  principal_type     = "GROUP"
  target_id          = var.audit_account_id
  target_type        = "AWS_ACCOUNT"
}

# ── Developers — PowerUserAccess in Dev accounts ──────────────────────────────

resource "aws_ssoadmin_account_assignment" "developers_dev" {
  for_each = var.developers_group_id != "" ? toset(var.dev_account_ids) : toset([])

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.power_user.arn
  principal_id       = var.developers_group_id
  principal_type     = "GROUP"
  target_id          = each.value
  target_type        = "AWS_ACCOUNT"
}

# ── Security team — SecurityAuditAccess in all accounts ──────────────────────

locals {
  all_account_ids = concat(
    var.dev_account_ids,
    var.staging_account_ids,
    var.prod_account_ids,
    [var.management_account_id, var.audit_account_id, var.log_archive_account_id]
  )
}

resource "aws_ssoadmin_account_assignment" "security_all" {
  for_each = var.security_team_group_id != "" ? toset(local.all_account_ids) : toset([])

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.security_audit.arn
  principal_id       = var.security_team_group_id
  principal_type     = "GROUP"
  target_id          = each.value
  target_type        = "AWS_ACCOUNT"
}

# ── FinOps team — BillingAccess in Management account only ───────────────────

resource "aws_ssoadmin_account_assignment" "finops_billing" {
  count = var.finops_group_id != "" ? 1 : 0

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.billing.arn
  principal_id       = var.finops_group_id
  principal_type     = "GROUP"
  target_id          = var.management_account_id
  target_type        = "AWS_ACCOUNT"
}

# ── Read-only — all users in all accounts (default) ───────────────────────────
# Assign ReadOnlyAccess broadly as the default — upgrade per team as needed.
# Uncomment and configure group ID when a read-only group is defined.
#
# resource "aws_ssoadmin_account_assignment" "readonly_all" {
#   for_each = toset(local.all_account_ids)
#   instance_arn       = local.sso_instance_arn
#   permission_set_arn = aws_ssoadmin_permission_set.read_only.arn
#   principal_id       = var.readonly_group_id
#   principal_type     = "GROUP"
#   target_id          = each.value
#   target_type        = "AWS_ACCOUNT"
# }