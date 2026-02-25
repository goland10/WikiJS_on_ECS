######################
# ALB Security Group
######################
resource "aws_security_group" "alb_sg" {
  name        = "wikijs-alb-sg"
  description = "Application Load Balancer"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.common_tags, {
    Name = "wikijs-alb-sg"
  })

}

## Ingress (from Internet)
#resource "aws_vpc_security_group_ingress_rule" "alb_http" {
#  security_group_id = aws_security_group.alb_sg.id
#  cidr_ipv4         = "0.0.0.0/0"
#  ip_protocol       = "tcp"
#  from_port         = 80
#  to_port           = 80
#  description       = "HTTP from Internet"
#}

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

########################################
# ECS Security Group
########################################
resource "aws_security_group" "ecs_sg" {
  name        = "wikijs-ecs-sg"
  description = "ECS tasks"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.common_tags, {
    Name = "wikijs-ecs-sg"
  })
}

# Ingress (from ALB)
resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb" {
  security_group_id            = aws_security_group.ecs_sg.id
  ip_protocol                  = "tcp"
  from_port                    = var.app_port
  to_port                      = var.app_port
  referenced_security_group_id = aws_security_group.alb_sg.id
  description                  = "Allow ALB to reach ECS tasks"
}

# Egress (to DB)
resource "aws_vpc_security_group_egress_rule" "ecs_to_db" {
  security_group_id            = aws_security_group.ecs_sg.id
  ip_protocol                  = "tcp"
  from_port                    = var.db_port
  to_port                      = var.db_port
  referenced_security_group_id = aws_security_group.db_sg.id
  description                  = "ECS tasks can reach RDS"
}

# Get AWS managed S3 prefix list
data "aws_prefix_list" "s3" {
  name = "com.amazonaws.${var.region}.s3"
}

# ECS egress to S3 over HTTPS
resource "aws_vpc_security_group_egress_rule" "ecs_to_s3" {
  security_group_id = aws_security_group.ecs_sg.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  prefix_list_id    = data.aws_prefix_list.s3.id
  description       = "ECS outbound to Gateway VPC Endpoint (S3)"
}

# Egress (to vpc endpoints)
resource "aws_vpc_security_group_egress_rule" "ecs_to_vpce" {
  security_group_id            = aws_security_group.ecs_sg.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  referenced_security_group_id = aws_security_group.vpce.id
  description                  = "ECS outbound to Interface VPC Endpoints"
}

########################################
# Interface VPC Endpoints Security Group
########################################
resource "aws_security_group" "vpce" {
  name        = "wikijs-vpce-sg"
  description = "Allow ECS to access VPC interface endpoints"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.common_tags, {
    Name = "wikijs-vpce-sg"
  })
}

# Ingress (from ecs)
resource "aws_vpc_security_group_ingress_rule" "vpce_from_ecs" {
  security_group_id            = aws_security_group.vpce.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  referenced_security_group_id = aws_security_group.ecs_sg.id
  description                  = "Allow ECS tasks to access interface endpoints"
}

########################################
# RDS Security Group
########################################
resource "aws_security_group" "db_sg" {
  name        = "wikijs-db-sg"
  description = "Allow PostgreSQL access from ECS only"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.common_tags, {
    Name = "wikijs-db-sg"
  })
}

# Ingress (from ECS)
resource "aws_vpc_security_group_ingress_rule" "db_from_ecs" {
  security_group_id            = aws_security_group.db_sg.id
  ip_protocol                  = "tcp"
  from_port                    = var.db_port
  to_port                      = var.db_port
  referenced_security_group_id = aws_security_group.ecs_sg.id
  description                  = "Allow ECS tasks to connect"
}
