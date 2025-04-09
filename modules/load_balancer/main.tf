# Create Load Balancer for Boundary
resource "aws_lb" "boundary" {
  name               = var.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnet_ids
  
  enable_deletion_protection = false
  
  tags = merge(
    var.common_tags,
    {
      Name = var.name
    }
  )
}

# Create Target Group for Controller API/UI
resource "aws_lb_target_group" "controller_api" {
  name     = "${var.name}-controller-api"
  port     = 9200
  protocol = "HTTPS"
  vpc_id   = data.aws_subnet.first_subnet.vpc_id
  
  health_check {
    protocol            = "HTTPS"
    path                = "/v1/auth-methods"
    port                = "9200"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }
  
  tags = var.common_tags
  
  lifecycle {
    create_before_destroy = true
  }
}

# Create Target Group for Worker Proxy
resource "aws_lb_target_group" "worker_proxy" {
  name     = "${var.name}-worker-proxy"
  port     = 9202
  protocol = "HTTP"
  vpc_id   = data.aws_subnet.first_subnet.vpc_id
  
  health_check {
    protocol            = "HTTP"
    path                = "/"
    port                = "9202"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-499"  # Workers may return various status codes
  }
  
  tags = var.common_tags
  
  lifecycle {
    create_before_destroy = true
  }
}

# Register controller with the target group
resource "aws_lb_target_group_attachment" "controller" {
  target_group_arn = aws_lb_target_group.controller_api.arn
  target_id        = var.controller_instance_id
  port             = 9200
}

# Register worker with the target group
resource "aws_lb_target_group_attachment" "worker" {
  target_group_arn = aws_lb_target_group.worker_proxy.arn
  target_id        = var.worker_instance_id
  port             = 9202
}

# Create Listener for API/UI
resource "aws_lb_listener" "controller_api" {
  load_balancer_arn = aws_lb.boundary.arn
  port              = 9200
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.boundary.arn
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.controller_api.arn
  }
}

# Create Listener for Worker Proxy
resource "aws_lb_listener" "worker_proxy" {
  load_balancer_arn = aws_lb.boundary.arn
  port              = 9202
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.boundary.arn
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.worker_proxy.arn
  }
}

# Create Listener for Worker On-Demand Ports
resource "aws_lb_listener" "worker_ports" {
  count = 10  # Create 10 listeners for ports 9000-9009
  
  load_balancer_arn = aws_lb.boundary.arn
  port              = 9000 + count.index
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.boundary.arn
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.worker_proxy.arn
  }
}

# Generate self-signed certificate for HTTPS
resource "tls_private_key" "boundary" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "boundary" {
  private_key_pem = tls_private_key.boundary.private_key_pem
  
  subject {
    common_name  = "boundary.example.com"
    organization = "Boundary Example"
  }
  
  validity_period_hours = 8760  # 1 year
  
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "boundary" {
  private_key      = tls_private_key.boundary.private_key_pem
  certificate_body = tls_self_signed_cert.boundary.cert_pem
  
  lifecycle {
    create_before_destroy = true
  }
}

# Get VPC information from subnet
data "aws_subnet" "first_subnet" {
  id = var.public_subnet_ids[0]
}
