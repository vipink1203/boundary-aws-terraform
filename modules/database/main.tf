# Subnet Group for Database
resource "aws_db_subnet_group" "boundary" {
  name        = "${var.name}-subnet-group"
  description = "Boundary database subnet group"
  subnet_ids  = var.subnet_ids
  
  tags = merge(
    var.common_tags,
    {
      Name = "${var.name}-subnet-group"
    }
  )
}

# Parameter Group for PostgreSQL
resource "aws_db_parameter_group" "boundary" {
  name        = "${var.name}-param-group"
  description = "Boundary database parameter group"
  family      = "postgres14"
  
  parameter {
    name  = "log_connections"
    value = "1"
  }
  
  parameter {
    name  = "log_disconnections"
    value = "1"
  }
  
  tags = merge(
    var.common_tags,
    {
      Name = "${var.name}-param-group"
    }
  )
}

# Database Instance for Boundary
resource "aws_db_instance" "boundary" {
  identifier             = var.name
  engine                 = "postgres"
  engine_version         = "14.8"
  instance_class         = var.instance_type
  allocated_storage      = 20
  storage_type           = "gp2"
  storage_encrypted      = true
  
  db_name                = "boundary"
  username               = var.username
  password               = var.password
  port                   = 5432
  
  vpc_security_group_ids = [var.security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.boundary.name
  parameter_group_name   = aws_db_parameter_group.boundary.name
  
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"
  
  multi_az               = false
  publicly_accessible    = false
  skip_final_snapshot    = true
  deletion_protection    = false
  
  performance_insights_enabled = true
  performance_insights_retention_period = 7
  
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  
  tags = merge(
    var.common_tags,
    {
      Name = var.name
    }
  )

  lifecycle {
    prevent_destroy = false
  }
}
