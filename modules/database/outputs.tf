output "endpoint" {
  description = "The connection endpoint for the database"
  value       = aws_db_instance.boundary.endpoint
}

output "address" {
  description = "The address of the database (hostname without port)"
  value       = aws_db_instance.boundary.address
}

output "port" {
  description = "The port of the database"
  value       = aws_db_instance.boundary.port
}

output "name" {
  description = "The name of the database"
  value       = aws_db_instance.boundary.db_name
}

output "arn" {
  description = "The ARN of the database"
  value       = aws_db_instance.boundary.arn
}
