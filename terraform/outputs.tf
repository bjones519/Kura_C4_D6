

output "security_group_id" {
  description = "The ID of the security group"
  value       = module.ssh_security_group.security_group_id

}
output "security_group_id2" {
  description = "The ID of the http-8080 security group"
  value       = module.http_8080_security_group.security_group_id

}
