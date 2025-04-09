# AWS Configuration
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
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

# Database Configuration
variable "db_username" {
  description = "Username for the database"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password for the database"
  type        = string
  sensitive   = true
}

variable "db_instance_type" {
  description = "Instance type for the database"
  type        = string
  default     = "db.t3.medium"
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
