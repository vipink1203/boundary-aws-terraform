# Security Group for Boundary Controller
resource "aws_security_group" "controller" {
  name        = "${var.name}-controller-sg"
  description = "Security group for Boundary controller"
  vpc_id      = var.vpc_id
  
  # HTTPS API and UI
  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS API and UI"
  }
  
  # Controller/Worker communication
  ingress {
    from_port   = 9201
    to_port     = 9201
    protocol    = "tcp"
    security_groups = [aws_security_group.worker.id]
    description = "Controller/Worker communication"
  }
  
  # SSH access (for management)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  
  tags = merge(
    var.common_tags,
    {
      Name = "${var.name}-controller-sg"
    }
  )
}

# Security Group for Boundary Worker
resource "aws_security_group" "worker" {
  name        = "${var.name}-worker-sg"
  description = "Security group for Boundary worker"
  vpc_id      = var.vpc_id
  
  # Worker proxying
  ingress {
    from_port   = 9202
    to_port     = 9202
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Worker proxying"
  }
  
  # Worker proxying on demand ports
  ingress {
    from_port   = 9000
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Worker proxying on demand ports range"
  }
  
  # SSH access (for management)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  
  tags = merge(
    var.common_tags,
    {
      Name = "${var.name}-worker-sg"
    }
  )
}

# Security Group for Database
resource "aws_security_group" "database" {
  name        = "${var.name}-database-sg"
  description = "Security group for Boundary database"
  vpc_id      = var.vpc_id
  
  # PostgreSQL
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.controller.id]
    description = "PostgreSQL access from controller"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  
  tags = merge(
    var.common_tags,
    {
      Name = "${var.name}-database-sg"
    }
  )
}

# Security Group for Load Balancer
resource "aws_security_group" "lb" {
  name        = "${var.name}-lb-sg"
  description = "Security group for Boundary load balancer"
  vpc_id      = var.vpc_id
  
  # HTTPS
  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS for API and UI"
  }
  
  # Worker proxying
  ingress {
    from_port   = 9202
    to_port     = 9202
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Worker proxying"
  }
  
  # Worker proxying on demand ports
  ingress {
    from_port   = 9000
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Worker proxying on demand ports range"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  
  tags = merge(
    var.common_tags,
    {
      Name = "${var.name}-lb-sg"
    }
  )
}
