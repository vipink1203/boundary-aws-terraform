variable "name" {
  description = "Name for the Boundary controller and related resources"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the Boundary controller"
  type        = string
  default     = "t3.medium"
}

variable "ami_id" {
  description = "ID of the custom AMI to use for the controller"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet where the controller will be deployed"
  type        = string
}

variable "security_group_id" {
  description = "ID of the security group for the controller"
  type        = string
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair for EC2 instance"
  type        = string
}

variable "db_endpoint" {
  description = "Endpoint for the PostgreSQL database"
  type        = string
}

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

variable "root_kms_key_id" {
  description = "KMS key ID for root key encryption"
  type        = string
}

variable "worker_auth_kms_key_id" {
  description = "KMS key ID for worker authentication"
  type        = string
}

variable "recovery_kms_key_id" {
  description = "KMS key ID for recovery"
  type        = string
}

variable "boundary_version" {
  description = "Boundary version to install (include +ent suffix for enterprise)"
  type        = string
  default     = "0.15.0+ent"
}

variable "boundary_license" {
  description = "Contents of the Boundary Enterprise license"
  type        = string
  sensitive   = true
}

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

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
