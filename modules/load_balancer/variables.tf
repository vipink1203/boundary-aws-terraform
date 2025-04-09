variable "name" {
  description = "Name for the load balancer and related resources"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the load balancer"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID of the security group for the load balancer"
  type        = string
}

variable "controller_instance_id" {
  description = "ID of the Boundary controller EC2 instance"
  type        = string
}

variable "worker_instance_id" {
  description = "ID of the Boundary worker EC2 instance"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
