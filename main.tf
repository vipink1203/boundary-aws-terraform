terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    boundary = {
      source  = "hashicorp/boundary"
      version = "~> 1.1"
    }
  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = var.aws_region
}

# Local variables for resource naming and tagging
locals {
  name_prefix = "boundary"
  common_tags = {
    Project     = "boundary"
    Environment = "production"
    Terraform   = "true"
  }
}

# Random ID for unique naming
resource "random_id" "id" {
  byte_length = 4
}

# KMS key for Boundary root encryption
resource "aws_kms_key" "boundary_root" {
  description             = "Boundary root encryption key"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  tags                    = local.common_tags
}

resource "aws_kms_alias" "boundary_root" {
  name          = "alias/boundary-root-${random_id.id.hex}"
  target_key_id = aws_kms_key.boundary_root.key_id
}

# KMS key for Boundary worker auth
resource "aws_kms_key" "boundary_worker_auth" {
  description             = "Boundary worker authentication key"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  tags                    = local.common_tags
}

resource "aws_kms_alias" "boundary_worker_auth" {
  name          = "alias/boundary-worker-auth-${random_id.id.hex}"
  target_key_id = aws_kms_key.boundary_worker_auth.key_id
}

# KMS key for Boundary recovery
resource "aws_kms_key" "boundary_recovery" {
  description             = "Boundary recovery key"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  tags                    = local.common_tags
}

resource "aws_kms_alias" "boundary_recovery" {
  name          = "alias/boundary-recovery-${random_id.id.hex}"
  target_key_id = aws_kms_key.boundary_recovery.key_id
}

# VPC for Boundary infrastructure
module "vpc" {
  source = "./modules/vpc"

  name                = "${local.name_prefix}-vpc-${random_id.id.hex}"
  cidr                = var.vpc_cidr
  public_subnets      = var.public_subnets
  private_subnets     = var.private_subnets
  availability_zones  = data.aws_availability_zones.available.names
  common_tags         = local.common_tags
}

# Security groups for Boundary components
module "security_groups" {
  source = "./modules/security_groups"

  name       = local.name_prefix
  vpc_id     = module.vpc.vpc_id
  common_tags = local.common_tags
}

# Database for Boundary storage
module "database" {
  source = "./modules/database"

  name                = "${local.name_prefix}-db-${random_id.id.hex}"
  instance_type       = var.db_instance_type
  username            = var.db_username
  password            = var.db_password
  subnet_ids          = module.vpc.private_subnet_ids
  security_group_id   = module.security_groups.database_sg_id
  common_tags         = local.common_tags
}

# Boundary controller instance
module "controller" {
  source = "./modules/controller"

  name                    = "${local.name_prefix}-controller-${random_id.id.hex}"
  ami_id                  = var.controller_ami_id
  instance_type           = var.controller_instance_type
  subnet_id               = module.vpc.private_subnet_ids[0]
  security_group_id       = module.security_groups.controller_sg_id
  ssh_key_name            = var.ssh_key_name
  db_endpoint             = module.database.endpoint
  db_username             = var.db_username
  db_password             = var.db_password
  root_kms_key_id         = aws_kms_key.boundary_root.key_id
  worker_auth_kms_key_id  = aws_kms_key.boundary_worker_auth.key_id
  recovery_kms_key_id     = aws_kms_key.boundary_recovery.key_id
  boundary_version        = var.boundary_version
  boundary_license        = file(var.boundary_license_path)
  initial_admin_username  = var.initial_admin_username
  initial_admin_password  = var.initial_admin_password
  common_tags             = local.common_tags
}

# Boundary worker instance
module "worker" {
  source = "./modules/worker"

  name                    = "${local.name_prefix}-worker-${random_id.id.hex}"
  ami_id                  = var.worker_ami_id
  instance_type           = var.worker_instance_type
  subnet_id               = module.vpc.public_subnet_ids[0]
  security_group_id       = module.security_groups.worker_sg_id
  ssh_key_name            = var.ssh_key_name
  controller_generated_token = module.controller.worker_token
  boundary_version        = var.boundary_version
  boundary_license        = file(var.boundary_license_path)
  common_tags             = local.common_tags
}

# Load balancer for external access
module "load_balancer" {
  source = "./modules/load_balancer"

  name                = "${local.name_prefix}-lb-${random_id.id.hex}"
  public_subnet_ids   = module.vpc.public_subnet_ids
  security_group_id   = module.security_groups.lb_sg_id
  controller_instance_id = module.controller.instance_id
  worker_instance_id  = module.worker.instance_id
  common_tags         = local.common_tags
}

# Configure the Boundary provider after deployment for further configuration
provider "boundary" {
  addr                            = "https://${module.load_balancer.dns_name}:9200"
  auth_method_id                  = module.controller.auth_method_id
  password_auth_method_login_name = var.initial_admin_username
  password_auth_method_password   = var.initial_admin_password
}
