output "organization_id" {
  description = "ID of the AWS Organization"
  value       = aws_organizations_organization.main.id
}

output "root_id" {
  description = "ID of the Organization root"
  value       = aws_organizations_organization.main.roots[0].id
}

output "security_ou_id" {
  description = "ID of the Security OU"
  value       = aws_organizations_organizational_unit.security.id
}

output "infrastructure_ou_id" {
  description = "ID of the Infrastructure OU"
  value       = aws_organizations_organizational_unit.infrastructure.id
}

output "workloads_ou_id" {
  description = "ID of the Workloads OU"
  value       = aws_organizations_organizational_unit.workloads.id
}

output "workloads_child_ou_ids" {
  description = "Map of child OU name to ID (Dev, Staging, Prod)"
  value       = { for k, v in aws_organizations_organizational_unit.workloads_children : k => v.id }
}