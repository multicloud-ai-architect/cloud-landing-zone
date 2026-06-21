variable "project" {
  description = "Project name"
  type        = string
  default     = "maia-landing-zone"
}

variable "aws_region" {
  description = "Primary AWS region"
  type        = string
  default     = "us-east-1"
}

variable "approved_regions" {
  description = "List of approved AWS regions for the DenyRegionsOutsideApproved SCP"
  type        = list(string)
  default     = ["eu-west-1", "eu-west-3", "us-east-1"]
}

# Identity — group IDs populated after IAM Identity Center is configured
variable "platform_team_group_id" {
  description = "IAM Identity Center group ID for the platform team"
  type        = string
  default     = ""
}

variable "developers_group_id" {
  description = "IAM Identity Center group ID for developers"
  type        = string
  default     = ""
}

variable "security_team_group_id" {
  description = "IAM Identity Center group ID for the security team"
  type        = string
  default     = ""
}

variable "finops_group_id" {
  description = "IAM Identity Center group ID for the FinOps team"
  type        = string
  default     = ""
}

variable "management_account_id" {
  description = "AWS account ID of the management account"
  type        = string
  default     = ""
}

variable "audit_account_id" {
  description = "AWS account ID of the Audit account"
  type        = string
  default     = ""
}

variable "log_archive_account_id" {
  description = "AWS account ID of the Log Archive account"
  type        = string
  default     = ""
}