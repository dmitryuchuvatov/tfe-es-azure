output "ssh_login" {
  description = "SSH login command"
  value       = "ssh ${local.user}@${local.ip}"
}

output "replicated_dashboard" {
  description = "URL for Replicated dashboard"
  value       = "https://${local.fqdn}.westeurope.cloudapp.azure.com:8800"
}
