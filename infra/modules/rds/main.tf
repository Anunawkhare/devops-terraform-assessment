resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags = {
    Name = "${var.environment}-db-subnet-group"
  }
}

resource "aws_db_instance" "main" {
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  storage_encrypted      = var.storage_encrypted
  db_name                = var.db_name
  username               = var.username
  password               = var.password
  backup_retention_period = var.backup_retention_days
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  vpc_security_group_ids = [var.ecs_sg_id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  deletion_protection    = var.deletion_protection
  skip_final_snapshot    = true
  publicly_accessible    = false
  tags = {
    Name = "${var.environment}-rds"
  }
}