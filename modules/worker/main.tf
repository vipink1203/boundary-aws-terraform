# Create IAM role for Boundary worker
resource "aws_iam_role" "worker" {
  name = "${var.name}-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  
  tags = var.common_tags
}

# Create IAM instance profile
resource "aws_iam_instance_profile" "worker" {
  name = "${var.name}-profile"
  role = aws_iam_role.worker.name
}

# Create worker EC2 instance
resource "aws_instance" "worker" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.ssh_key_name
  iam_instance_profile   = aws_iam_instance_profile.worker.name
  
  root_block_device {
    volume_size = 20
    volume_type = "gp2"
    encrypted   = true
  }
  
  tags = merge(
    var.common_tags,
    {
      Name = var.name
    }
  )
  
  user_data = templatefile("${path.module}/templates/worker_user_data.tmpl", {
    boundary_version         = var.boundary_version
    boundary_license         = var.boundary_license
    controller_token         = var.controller_generated_token
    worker_name              = var.name
  })
  
  lifecycle {
    create_before_destroy = true
  }
}

# Allocate Elastic IP
resource "aws_eip" "worker" {
  domain = "vpc"
  
  tags = merge(
    var.common_tags,
    {
      Name = "${var.name}-eip"
    }
  )
}

# Associate Elastic IP with worker
resource "aws_eip_association" "worker" {
  instance_id   = aws_instance.worker.id
  allocation_id = aws_eip.worker.id
}

# Create CloudWatch Log Group for worker logs
resource "aws_cloudwatch_log_group" "worker" {
  name              = "/boundary/worker/${var.name}"
  retention_in_days = 30
  
  tags = var.common_tags
}

# Data source for Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
