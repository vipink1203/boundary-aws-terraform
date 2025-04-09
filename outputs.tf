output "boundary_endpoint" {
  description = "URL for accessing the Boundary UI and API"
  value       = "https://${module.load_balancer.dns_name}:9200"
}

output "controller_private_ip" {
  description = "Private IP address of the Boundary controller"
  value       = module.controller.private_ip
}

output "worker_public_ip" {
  description = "Public IP address of the Boundary worker"
  value       = module.worker.public_ip
}

output "database_endpoint" {
  description = "Endpoint for the Boundary database"
  value       = module.database.endpoint
}

output "auth_method_id" {
  description = "ID of the password auth method"
  value       = module.controller.auth_method_id
}

output "initial_admin_username" {
  description = "Username for the initial admin user"
  value       = var.initial_admin_username
}

output "initial_admin_password" {
  description = "Password for the initial admin user"
  value       = var.initial_admin_password
  sensitive   = true
}

output "boundary_login_command" {
  description = "Command to authenticate to Boundary using the CLI"
  value       = "boundary authenticate password -auth-method-id=${module.controller.auth_method_id} -login-name=${var.initial_admin_username} -password=<your-password>"
}

output "ssh_command_controller" {
  description = "Command to SSH to the controller"
  value       = "ssh -i <path-to-key> ec2-user@${module.controller.private_ip}"
}

output "ssh_command_worker" {
  description = "Command to SSH to the worker"
  value       = "ssh -i <path-to-key> ec2-user@${module.worker.public_ip}"
}
