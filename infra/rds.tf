# DB Subnet Group (requires at least two subnets in different AZs)
resource "aws_db_subnet_group" "private" {
  name        = "${var.project}-db-subnet-group"
  description = "Subnet group for RDS PostgreSQL"
  subnet_ids  = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name        = "${var.project}-db-subnet-group"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# RDS PostgreSQL instance
resource "aws_db_instance" "justauth_rds" {
  identifier     = "${var.project}-rds"
  engine         = "postgres"
  engine_version = "15"
  instance_class = "db.t3.micro"

  allocated_storage     = 20
  storage_encrypted     = true
  storage_type          = "gp2"

  db_name  = "justauthdb"
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.private.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  publicly_accessible = false
  skip_final_snapshot = true   # only for lab purposes

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  tags = {
    Name        = "${var.project}-rds"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}