# Example Terraform configuration for adding EC2 instances as targets in Boundary
# This configuration should be applied AFTER the main Boundary infrastructure is provisioned
# Use this file as a reference for adding your own targets

# Create a project in the default scope
resource "boundary_scope" "project" {
  scope_id                 = "global"
  name                     = "EC2 Servers"
  description              = "Project for EC2 server access"
  auto_create_admin_role   = true
  auto_create_default_role = true
}

# Create a static host catalog
resource "boundary_host_catalog_static" "ec2_servers" {
  name        = "AWS EC2 Servers"
  description = "EC2 instances for access"
  scope_id    = boundary_scope.project.id
}

# Create static hosts for your EC2 instances
resource "boundary_host_static" "app_server" {
  name            = "App Server"
  description     = "Application server in private subnet"
  address         = "10.0.3.10"  # Update with your EC2 instance's private IP
  host_catalog_id = boundary_host_catalog_static.ec2_servers.id
}

resource "boundary_host_static" "db_server" {
  name            = "Database Server"
  description     = "Database server in private subnet"
  address         = "10.0.3.20"  # Update with your EC2 instance's private IP
  host_catalog_id = boundary_host_catalog_static.ec2_servers.id
}

# Create a host set for the web servers
resource "boundary_host_set_static" "app_servers" {
  name            = "Application Servers"
  description     = "All application servers"
  host_catalog_id = boundary_host_catalog_static.ec2_servers.id
  host_ids        = [boundary_host_static.app_server.id]
}

# Create a host set for the database servers
resource "boundary_host_set_static" "db_servers" {
  name            = "Database Servers"
  description     = "All database servers"
  host_catalog_id = boundary_host_catalog_static.ec2_servers.id
  host_ids        = [boundary_host_static.db_server.id]
}

# Create a credential store for SSH keys
resource "boundary_credential_store_static" "ssh_keys" {
  name        = "SSH Keys"
  description = "SSH keys for server access"
  scope_id    = boundary_scope.project.id
}

# Create SSH key credentials
resource "boundary_credential_ssh_private_key" "app_server_key" {
  name                = "App Server SSH Key"
  description         = "SSH key for application server access"
  credential_store_id = boundary_credential_store_static.ssh_keys.id
  username            = "ec2-user"
  private_key         = file("~/.ssh/app_server_key.pem")  # Update with your key path
}

resource "boundary_credential_ssh_private_key" "db_server_key" {
  name                = "DB Server SSH Key"
  description         = "SSH key for database server access"
  credential_store_id = boundary_credential_store_static.ssh_keys.id
  username            = "ec2-user"
  private_key         = file("~/.ssh/db_server_key.pem")  # Update with your key path
}

# Create targets for SSH connections
resource "boundary_target" "app_ssh" {
  name         = "Application SSH"
  description  = "SSH access to application servers"
  type         = "ssh"
  scope_id     = boundary_scope.project.id
  default_port = "22"
  
  host_source_ids = [
    boundary_host_set_static.app_servers.id
  ]
  
  credential_source_ids = [
    boundary_credential_ssh_private_key.app_server_key.id
  ]
  
  session_connection_limit = -1
}

resource "boundary_target" "db_ssh" {
  name         = "Database SSH"
  description  = "SSH access to database servers"
  type         = "ssh"
  scope_id     = boundary_scope.project.id
  default_port = "22"
  
  host_source_ids = [
    boundary_host_set_static.db_servers.id
  ]
  
  credential_source_ids = [
    boundary_credential_ssh_private_key.db_server_key.id
  ]
  
  session_connection_limit = -1
}

# Create roles for access control
resource "boundary_role" "app_admin" {
  name        = "Application Server Admin"
  description = "Administrator access to application servers"
  scope_id    = "global"
  
  grant_strings = [
    "id=${boundary_target.app_ssh.id};actions=authorize-session,list,read",
    "id=${boundary_scope.project.id};actions=list,read,no-op"
  ]
  
  principal_ids = [
    # Add user or group IDs here
  ]
}

resource "boundary_role" "db_admin" {
  name        = "Database Server Admin"
  description = "Administrator access to database servers"
  scope_id    = "global"
  
  grant_strings = [
    "id=${boundary_target.db_ssh.id};actions=authorize-session,list,read",
    "id=${boundary_scope.project.id};actions=list,read,no-op"
  ]
  
  principal_ids = [
    # Add user or group IDs here
  ]
}

# Output connection commands for reference
output "connect_app_ssh_command" {
  value = "boundary connect ssh -target-id=${boundary_target.app_ssh.id}"
}

output "connect_db_ssh_command" {
  value = "boundary connect ssh -target-id=${boundary_target.db_ssh.id}"
}
