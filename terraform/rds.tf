resource "aws_db_subnet_group" "wiki" {
  name       = "wikijs-db-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = merge(local.common_tags, {
    Name = "wikijs-db-subnet-group"
  })
}

resource "aws_db_parameter_group" "wiki" {
  name   = "wikijs-postgres17"
  family = "postgres17"

  parameter {
    name  = "rds.force_ssl"
    value = "0"
  }

  tags = merge(local.common_tags, {
    Name = "wikijs-db-parameter-group"
  })
}
########################################
# DB Instance
########################################
resource "aws_db_instance" "wiki" {
  identifier = "wikijs-db"

  engine         = "postgres"
  engine_version = "17.6"
  instance_class = "db.t4g.micro"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"

  db_name  = "wikijs"
  username = var.db_username
  #Manage the master password with Secrets Manager.
  manage_master_user_password = true

  port                 = 5432
  parameter_group_name = aws_db_parameter_group.wiki.name

  db_subnet_group_name   = aws_db_subnet_group.wiki.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  publicly_accessible = false
  multi_az            = false

  storage_encrypted = true

  backup_retention_period   = 0
  delete_automated_backups  = true
  skip_final_snapshot       = true
  final_snapshot_identifier = "wikijs-final-snapshot-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  deletion_protection       = false

  auto_minor_version_upgrade = true
  apply_immediately          = true

  performance_insights_enabled          = false
  performance_insights_retention_period = 7
  monitoring_interval                   = 60
  monitoring_role_arn                   = aws_iam_role.rds_monitoring.arn

  tags = {
    Name = "wikijs-db"
  }
}
