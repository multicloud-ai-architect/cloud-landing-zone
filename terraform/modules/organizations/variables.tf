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

variable "aws_service_access_principals" {
  description = "List of AWS service principal names to enable organization-level integration"
  type        = list(string)
  default = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "sso.amazonaws.com",
    "guardduty.amazonaws.com",
    "securityhub.amazonaws.com",
    "ram.amazonaws.com",
    "tagpolicies.tag.amazonaws.com",
  ]
}

variable "workloads_child_ous" {
  description = "Child OU names to create inside the Workloads OU"
  type        = list(string)
  default     = ["Dev", "Staging", "Prod"]
}