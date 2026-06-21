# ── AdministratorAccess ───────────────────────────────────────────────────────
# Break-glass only. All usage should trigger a CloudWatch alarm.
# Assign only to the platform team leads group, in Management/Security/Network
# accounts. Never assign in Prod workload accounts.

resource "aws_ssoadmin_permission_set" "administrator" {
  name             = "AdministratorAccess"
  description      = "Full AWS access — break-glass only, all usage triggers alert"
  instance_arn     = local.sso_instance_arn
  session_duration = "PT4H"

  tags = local.common_tags
}

resource "aws_ssoadmin_managed_policy_attachment" "administrator" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.administrator.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# ── PowerUserAccess ───────────────────────────────────────────────────────────
# Full AWS access except IAM write. Prevents privilege escalation in Dev.

resource "aws_ssoadmin_permission_set" "power_user" {
  name             = "PowerUserAccess"
  description      = "Full access except IAM — developers in Dev OU"
  instance_arn     = local.sso_instance_arn
  session_duration = "PT8H"

  tags = local.common_tags
}

resource "aws_ssoadmin_managed_policy_attachment" "power_user" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.power_user.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

# ── DeveloperAccess ───────────────────────────────────────────────────────────
# Scoped to developer-relevant services. Dev and Staging only.
# Explicitly denies IAM write to prevent privilege escalation.

resource "aws_ssoadmin_permission_set" "developer" {
  name             = "DeveloperAccess"
  description      = "Scoped developer permissions — Dev and Staging only"
  instance_arn     = local.sso_instance_arn
  session_duration = "PT8H"

  tags = local.common_tags
}

resource "aws_ssoadmin_permission_set_inline_policy" "developer" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.developer.arn
  inline_policy      = data.aws_iam_policy_document.developer.json
}

data "aws_iam_policy_document" "developer" {
  statement {
    sid    = "DeveloperServices"
    effect = "Allow"
    actions = [
      "ec2:*", "ecs:*", "ecr:*", "lambda:*",
      "s3:*", "rds:Describe*", "rds:List*",
      "cloudwatch:*", "logs:*", "xray:*",
      "codebuild:*", "codecommit:*",
      "ssm:GetParameter*", "ssm:DescribeParameters",
      "elasticloadbalancing:*", "autoscaling:*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "DenyIAMWrite"
    effect = "Deny"
    actions = [
      "iam:CreateUser", "iam:DeleteUser",
      "iam:CreateRole", "iam:DeleteRole",
      "iam:AttachRolePolicy", "iam:DetachRolePolicy",
      "iam:PutRolePolicy", "iam:DeleteRolePolicy",
      "iam:CreateAccessKey", "iam:DeleteAccessKey",
    ]
    resources = ["*"]
  }
}

# ── ReadOnlyAccess ────────────────────────────────────────────────────────────
# Default for new team members across all accounts.

resource "aws_ssoadmin_permission_set" "read_only" {
  name             = "ReadOnlyAccess"
  description      = "Read-only access — default for new team members across all accounts"
  instance_arn     = local.sso_instance_arn
  session_duration = "PT8H"

  tags = local.common_tags
}

resource "aws_ssoadmin_managed_policy_attachment" "read_only" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.read_only.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# ── SecurityAuditAccess ───────────────────────────────────────────────────────
# Read all security services across all accounts. Cannot modify or delete.
# Used by the security team to investigate findings and query logs cross-account.

resource "aws_ssoadmin_permission_set" "security_audit" {
  name             = "SecurityAuditAccess"
  description      = "Read all security services across all accounts — security team"
  instance_arn     = local.sso_instance_arn
  session_duration = "PT8H"

  tags = local.common_tags
}

resource "aws_ssoadmin_managed_policy_attachment" "security_audit_base" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.security_audit.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

resource "aws_ssoadmin_managed_policy_attachment" "security_audit_view" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.security_audit.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
}

# ── BillingAccess ─────────────────────────────────────────────────────────────
# Read and manage billing data. Management account only.

resource "aws_ssoadmin_permission_set" "billing" {
  name             = "BillingAccess"
  description      = "Billing and cost management — Management account only, FinOps team"
  instance_arn     = local.sso_instance_arn
  session_duration = "PT8H"

  tags = local.common_tags
}

resource "aws_ssoadmin_managed_policy_attachment" "billing" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.billing.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/job-function/Billing"
}