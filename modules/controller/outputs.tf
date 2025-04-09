output "instance_id" {
  description = "ID of the controller EC2 instance"
  value       = aws_instance.controller.id
}

output "private_ip" {
  description = "Private IP address of the controller"
  value       = aws_instance.controller.private_ip
}

output "worker_token" {
  description = "Token for worker authentication"
  value       = random_string.worker_token.result
  sensitive   = true
}

output "auth_method_id" {
  description = "ID of the password auth method"
  value       = data.local_file.auth_method_id.content
}

output "storage_bucket" {
  description = "S3 bucket for Boundary storage"
  value       = aws_s3_bucket.storage.bucket
}

output "logs_group" {
  description = "CloudWatch Logs group for controller logs"
  value       = aws_cloudwatch_log_group.controller.name
}
