output "controller_sg_id" {
  description = "ID of the controller security group"
  value       = aws_security_group.controller.id
}

output "worker_sg_id" {
  description = "ID of the worker security group"
  value       = aws_security_group.worker.id
}

output "database_sg_id" {
  description = "ID of the database security group"
  value       = aws_security_group.database.id
}

output "lb_sg_id" {
  description = "ID of the load balancer security group"
  value       = aws_security_group.lb.id
}
