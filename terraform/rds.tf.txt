resource "aws_db_subnet_group" "wiki" {
  name       = "wikijs-db-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "wikijs-db-subnet-group"
  }
}

resource "aws_security_group" "rds" {
  name        = "wikijs-rds-sg"
  description = "Allow PostgreSQL access from ECS only"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Postgres from ECS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    #security_groups = [aws_security_group.ecs.id] # define later
    cidr_blocks      = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wikijs-rds-sg"
  }
}

resource "aws_db_parameter_group" "wiki" {
  name   = "wikijs-postgres17"
  family = "postgres17"

  parameter {
    name  = "rds.force_ssl"
    value = "0"
  }

  tags = {
    Name = "wikijs-postgres17"
  }
}

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
  password = var.db_password
  port     = 5432
  parameter_group_name = aws_db_parameter_group.wiki.name

  db_subnet_group_name   = aws_db_subnet_group.wiki.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible = false
  multi_az            = false

  storage_encrypted = true

  backup_retention_period = 7
  skip_final_snapshot     = true
  final_snapshot_identifier = "my-final-db-snapshot-12345"
  deletion_protection     = false

  auto_minor_version_upgrade = true
  apply_immediately          = true

  performance_insights_enabled = false
  monitoring_interval           = 0

  tags = {
    Name = "wikijs-db"
  }
}
