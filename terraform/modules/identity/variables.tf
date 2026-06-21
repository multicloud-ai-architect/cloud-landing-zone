# ============================================================
# REFERENCE IMPLEMENTATION — Sandbox only
# See docs/landing-zone-reference.md — Chapter 5 for full context.
# ============================================================

variable "project" {
  description = "Project name — used in all resource names and tags"
  type        = string
}

variable "environment" {
  description = "Environment: dev, staging, prod"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}

variable "management_account_id" {
  description = "AWS account ID of the management account"
  type        = string
}

variable "audit_account_id" {
  description = "AWS account ID of the Audit account (Security OU)"
  type        = string
}

variable "log_archive_account_id" {
  description = "AWS account ID of the Log Archive account (Security OU)"
  type        = string
}

variable "dev_account_ids" {
  description = "List of AWS account IDs in the Dev OU"
  type        = list(string)
  default     = []
}

variable "staging_account_ids" {
  description = "List of AWS account IDs in the Staging OU"
  type        = list(string)
  default     = []
}

variable "prod_account_ids" {
  description = "List of AWS account IDs in the Prod OU"
  type        = list(string)
  default     = []
}

variable "platform_team_group_id" {
  description = "IAM Identity Center group ID for the platform team (AdministratorAccess)"
  type        = string
  default     = ""
}

variable "developers_group_id" {
  description = "IAM Identity Center group ID for developers (PowerUserAccess in Dev)"
  type        = string
  default     = ""
}

variable "security_team_group_id" {
  description = "IAM Identity Center group ID for the security team (SecurityAuditAccess)"
  type        = string
  default     = ""
}

variable "finops_group_id" {
  description = "IAM Identity Center group ID for the FinOps team (BillingAccess)"
  type        = string
  default     = ""
}