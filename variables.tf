# AWS Configuration
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

# Existing Infrastructure IDs
variable "vpc_id" {
  description = "ID of the existing VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of existing public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of existing private subnet IDs"
  type        = list(string)
}

variable "db_endpoint" {
  description = "Endpoint for the existing database"
  type        = string
}

variable "db_username" {
  description = "Username for the existing database"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password for the existing database"
  type        = string
  sensitive   = true
}

# Boundary Configuration
variable "boundary_version" {
  description = "Boundary version to install (include +ent suffix for enterprise)"
  type        = string
  default     = "0.15.0+ent"
}

variable "boundary_license_path" {
  description = "Path to Boundary enterprise license file"
  type        = string
}

# AMI Configuration
variable "controller_ami_id" {
  description = "ID of the custom AMI to use for the controller"
  type        = string
}

variable "worker_ami_id" {
  description = "ID of the custom AMI to use for the worker"
  type        = string
}

# EC2 Configuration
variable "controller_instance_type" {
  description = "Instance type for the Boundary controller"
  type        = string
  default     = "t3.medium"
}

variable "worker_instance_type" {
  description = "Instance type for the Boundary worker"
  type        = string
  default     = "t3.medium"
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair to use for EC2 instances"
  type        = string
}

# Admin Credentials
variable "initial_admin_username" {
  description = "Username for the initial admin user"
  type        = string
  default     = "admin"
}

variable "initial_admin_password" {
  description = "Password for the initial admin user"
  type        = string
  sensitive   = true
}
