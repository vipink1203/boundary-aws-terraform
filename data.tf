# Get available AWS availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Get latest Amazon Linux 2 AMI
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

# Get account ID for IAM policies
data "aws_caller_identity" "current" {}

# Get AWS partition for ARN construction
data "aws_partition" "current" {}

# Get current region for ARN construction
data "aws_region" "current" {}
