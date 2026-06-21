output "sso_instance_arn" {
  description = "ARN of the IAM Identity Center instance"
  value       = local.sso_instance_arn
}

output "identity_store_id" {
  description = "ID of the IAM Identity Center identity store"
  value       = local.identity_store_id
}

output "permission_set_arns" {
  description = "Map of permission set name to ARN"
  value = {
    administrator  = aws_ssoadmin_permission_set.administrator.arn
    power_user     = aws_ssoadmin_permission_set.power_user.arn
    developer      = aws_ssoadmin_permission_set.developer.arn
    read_only      = aws_ssoadmin_permission_set.read_only.arn
    security_audit = aws_ssoadmin_permission_set.security_audit.arn
    billing        = aws_ssoadmin_permission_set.billing.arn
  }
}