# Example Terraform configuration for deploying Boundary with existing VPC and database
# This file provides a reference for how to structure your Terraform configuration

# Configure your provider details
provider "aws" {
  region = "us-east-1"
}

# Define your existing infrastructure variables
locals {
  # Your existing VPC details
  vpc_id             = "vpc-01234567890abcdef"
  public_subnet_ids  = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
  private_subnet_ids = ["subnet-0123456789abcdef2", "subnet-0123456789abcdef3"]
  
  # Your existing database details
  db_endpoint = "boundary-db.abcdefghij.us-east-1.rds.amazonaws.com:5432"
  db_username = "boundary"
  db_password = "your-secure-password"
  
  # Your custom AMI IDs
  controller_ami_id = "ami-01234567890abcdef"
  worker_ami_id     = "ami-01234567890abcdef"
  
  # SSH key name to use for EC2 instances
  ssh_key_name = "your-key-name"
  
  # Boundary configuration
  boundary_license_path = "./license.hclic"
  boundary_version      = "0.15.0+ent"
  
  # Admin credentials
  admin_username = "admin"
  admin_password = "your-secure-admin-password"
}

# Example of how to integrate with the main Boundary module
module "boundary" {
  source = "../"
  
  # AWS configuration
  aws_region = "us-east-1"
  
  # Existing infrastructure IDs
  vpc_id             = local.vpc_id
  public_subnet_ids  = local.public_subnet_ids
  private_subnet_ids = local.private_subnet_ids
  db_endpoint        = local.db_endpoint
  db_username        = local.db_username
  db_password        = local.db_password
  
  # AMI configuration
  controller_ami_id = local.controller_ami_id
  worker_ami_id     = local.worker_ami_id
  
  # EC2 configuration
  controller_instance_type = "t3.medium"
  worker_instance_type     = "t3.medium"
  ssh_key_name             = local.ssh_key_name
  
  # Boundary configuration
  boundary_version      = local.boundary_version
  boundary_license_path = local.boundary_license_path
  
  # Admin credentials
  initial_admin_username = local.admin_username
  initial_admin_password = local.admin_password
}

# Output the Boundary endpoint
output "boundary_endpoint" {
  value = module.boundary.boundary_endpoint
}

# Output the login command
output "boundary_login_command" {
  value = module.boundary.boundary_login_command
}
