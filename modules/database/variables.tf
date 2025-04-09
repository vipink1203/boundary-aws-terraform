variable "name" {
  description = "Name for the database and related resources"
  type        = string
}

variable "instance_type" {
  description = "RDS instance type for the database"
  type        = string
  default     = "db.t3.medium"
}

variable "username" {
  description = "Username for the database"
  type        = string
  sensitive   = true
}

variable "password" {
  description = "Password for the database"
  type        = string
  sensitive   = true
}

variable "subnet_ids" {
  description = "List of subnet IDs for the database subnet group"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID of the security group for the database"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
