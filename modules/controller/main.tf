# Generate a random token for worker authentication
resource "random_string" "worker_token" {
  length  = 32
  special = false
}

# Create IAM role for Boundary controller
resource "aws_iam_role" "controller" {
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
resource "aws_iam_instance_profile" "controller" {
  name = "${var.name}-profile"
  role = aws_iam_role.controller.name
}

# Create IAM policy for KMS access
resource "aws_iam_policy" "kms_access" {
  name        = "${var.name}-kms-access"
  description = "Allow Boundary controller to use KMS keys"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:DescribeKey"
        ]
        Effect   = "Allow"
        Resource = [
          var.root_kms_key_id,
          var.worker_auth_kms_key_id,
          var.recovery_kms_key_id
        ]
      }
    ]
  })
}

# Attach KMS policy to role
resource "aws_iam_role_policy_attachment" "kms_access" {
  role       = aws_iam_role.controller.name
  policy_arn = aws_iam_policy.kms_access.arn
}

# Create controller EC2 instance
resource "aws_instance" "controller" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.ssh_key_name
  iam_instance_profile   = aws_iam_instance_profile.controller.name
  
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
  
  user_data = templatefile("${path.module}/templates/controller_user_data.tmpl", {
    boundary_version        = var.boundary_version
    boundary_license        = var.boundary_license
    db_endpoint             = var.db_endpoint
    db_username             = var.db_username
    db_password             = var.db_password
    root_kms_key_id         = var.root_kms_key_id
    worker_auth_kms_key_id  = var.worker_auth_kms_key_id
    recovery_kms_key_id     = var.recovery_kms_key_id
    worker_token            = random_string.worker_token.result
    initial_admin_username  = var.initial_admin_username
    initial_admin_password  = var.initial_admin_password
  })
  
  lifecycle {
    create_before_destroy = true
  }
}

# Create CloudWatch Log Group for controller logs
resource "aws_cloudwatch_log_group" "controller" {
  name              = "/boundary/controller/${var.name}"
  retention_in_days = 30
  
  tags = var.common_tags
}

# Create S3 bucket for file storage (optional)
resource "aws_s3_bucket" "storage" {
  bucket = "boundary-${var.name}-storage-${random_string.bucket_suffix.result}"
  
  tags = var.common_tags
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  lower   = true
  upper   = false
}

resource "aws_s3_bucket_server_side_encryption_configuration" "storage" {
  bucket = aws_s3_bucket.storage.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Store initial auth method ID in SSM parameter store
resource "aws_ssm_parameter" "auth_method_id" {
  name        = "/boundary/${var.name}/auth_method_id"
  description = "Auth method ID for password authentication"
  type        = "String"
  value       = "ampw_1234567890" # This is a placeholder, will be updated by controller
  
  tags = var.common_tags
}

# Local file for storing the auth method ID (for Terraform reference)
resource "local_file" "auth_method_id" {
  content  = "ampw_1234567890" # This is a placeholder, will be updated manually after deployment
  filename = "${path.module}/auth_method_id"
}

# Data source to read the auth method ID (for outputs)
data "local_file" "auth_method_id" {
  filename = "${path.module}/auth_method_id"
  depends_on = [local_file.auth_method_id]
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
