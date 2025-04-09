output "instance_id" {
  description = "ID of the worker EC2 instance"
  value       = aws_instance.worker.id
}

output "private_ip" {
  description = "Private IP address of the worker"
  value       = aws_instance.worker.private_ip
}

output "public_ip" {
  description = "Public IP address of the worker (from EIP)"
  value       = aws_eip.worker.public_ip
}

output "elastic_ip_id" {
  description = "ID of the Elastic IP assigned to the worker"
  value       = aws_eip.worker.id
}

output "logs_group" {
  description = "CloudWatch Logs group for worker logs"
  value       = aws_cloudwatch_log_group.worker.name
}
