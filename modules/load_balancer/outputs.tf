output "dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.boundary.dns_name
}

output "zone_id" {
  description = "Hosted zone ID of the load balancer"
  value       = aws_lb.boundary.zone_id
}

output "controller_target_group_arn" {
  description = "ARN of the controller target group"
  value       = aws_lb_target_group.controller_api.arn
}

output "worker_target_group_arn" {
  description = "ARN of the worker target group"
  value       = aws_lb_target_group.worker_proxy.arn
}

output "certificate_arn" {
  description = "ARN of the SSL certificate"
  value       = aws_acm_certificate.boundary.arn
}
