output "policy_ids" {
  description = "Map of SCP name to policy ID"
  value = {
    deny_root                = aws_organizations_policy.deny_root.id
    deny_regions             = aws_organizations_policy.deny_regions.id
    deny_disable_cloudtrail  = aws_organizations_policy.deny_disable_cloudtrail.id
    deny_disable_guardduty   = aws_organizations_policy.deny_disable_guardduty.id
    deny_leave_org           = aws_organizations_policy.deny_leave_org.id
    deny_disable_securityhub = aws_organizations_policy.deny_disable_securityhub.id
    require_s3_encryption    = aws_organizations_policy.require_s3_encryption.id
    require_imdsv2           = aws_organizations_policy.require_imdsv2.id
    deny_public_s3           = aws_organizations_policy.deny_public_s3.id
    deny_unencrypted_ebs     = aws_organizations_policy.deny_unencrypted_ebs.id
  }
}