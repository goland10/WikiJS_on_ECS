########################################
# Security Groups
########################################

# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "wikijs-alb-sg"
  description = "Application Load Balancer"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name        = "wikijs-alb-sg"
    Project     = "WikiJS"
    Environment = "Assessment"
    ManagedBy   = "Terraform"
  }
}

# ECS Security Group
resource "aws_security_group" "ecs_sg" {
  name        = "wikijs-ecs-sg"
  description = "ECS tasks"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name        = "wikijs-ecs-sg"
    Project     = "WikiJS"
    Environment = "Assessment"
    ManagedBy   = "Terraform"
  }
}

# RDS Security Group
resource "aws_security_group" "db_sg" {
  name        = "wikijs-db-sg"
  description = "RDS PostgreSQL"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name        = "wikijs-db-sg"
    Project     = "WikiJS"
    Environment = "Assessment"
    ManagedBy   = "Terraform"
  }
}

########################################
# Rules
########################################

########################################
# ALB Security Group
########################################

# Ingress (from Internet)
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  description       = "HTTP from Internet"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  description       = "HTTPS from Internet"
}

# Egress
resource "aws_vpc_security_group_egress_rule" "alb_to_ecs" {
  security_group_id            = aws_security_group.alb_sg.id
  ip_protocol                  = "tcp"
  from_port                    = 3000
  to_port                      = 3000
  referenced_security_group_id = aws_security_group.ecs_sg.id
  description                  = "ALB can reach ECS tasks"
}

resource "aws_vpc_security_group_egress_rule" "alb_egress_general" {
  security_group_id = aws_security_group.alb_sg.id
  ip_protocol       = "tcp"
  from_port         = 0
  to_port           = 0
  cidr_ipv4         = "0.0.0.0/0"
  description       = "ALB general outbound"
}

########################################
# ECS Security Group
########################################

# Ingress (from ALB)
resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb" {
  security_group_id            = aws_security_group.ecs_sg.id
  ip_protocol                  = "tcp"
  from_port                    = 3000
  to_port                      = 3000
  referenced_security_group_id = aws_security_group.alb_sg.id
  description                  = "Allow ALB to reach ECS tasks"
}

# Egress (to DB + general)
resource "aws_vpc_security_group_egress_rule" "ecs_to_db" {
  security_group_id            = aws_security_group.ecs_sg.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  referenced_security_group_id = aws_security_group.db_sg.id
  description                  = "ECS tasks can reach RDS"
}

resource "aws_vpc_security_group_egress_rule" "ecs_egress_general" {
  security_group_id = aws_security_group.ecs_sg.id
  ip_protocol       = "tcp"
  from_port         = 0
  to_port           = 0
  cidr_ipv4         = "0.0.0.0/0"
  description       = "ECS general outbound traffic"
}

########################################
# RDS Security Group
########################################

# Ingress (from ECS)
resource "aws_vpc_security_group_ingress_rule" "db_from_ecs" {
  security_group_id            = aws_security_group.db_sg.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  referenced_security_group_id = aws_security_group.ecs_sg.id
  description                  = "Allow ECS tasks to connect"
}

# Egress (general)
resource "aws_vpc_security_group_egress_rule" "db_egress" {
  security_group_id = aws_security_group.db_sg.id
  ip_protocol       = "tcp"
  from_port         = 0
  to_port           = 0
  cidr_ipv4         = "0.0.0.0/0"
  description       = "RDS outbound traffic"
}