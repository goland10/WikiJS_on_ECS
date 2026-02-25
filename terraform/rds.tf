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
  #password = var.db_password
  
  port                 = 5432
  parameter_group_name = aws_db_parameter_group.wiki.name

  db_subnet_group_name   = aws_db_subnet_group.wiki.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  publicly_accessible = false
  multi_az            = false

  storage_encrypted = true

  backup_retention_period   = 0
  skip_final_snapshot       = true
  final_snapshot_identifier = "my-final-db-snapshot-12345"
  deletion_protection       = false

  auto_minor_version_upgrade = true
  apply_immediately          = true

  performance_insights_enabled = false
  monitoring_interval          = 0

  tags = merge(local.common_tags, {
    Name = "wikijs-db"
  })
}

output "db_address" {
  value = aws_db_instance.wiki.address
}