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

variable "security_ou_id" {
  description = "ID of the Security OU"
  type        = string
}

variable "infrastructure_ou_id" {
  description = "ID of the Infrastructure OU"
  type        = string
}

variable "workloads_ou_id" {
  description = "ID of the Workloads OU"
  type        = string
}

variable "approved_regions" {
  description = "List of AWS regions to allow — all other regions are denied"
  type        = list(string)
  default     = ["eu-west-1", "eu-west-3", "us-east-1"]
}