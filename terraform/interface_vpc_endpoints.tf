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
  #referenced_security_group_id = aws_security_group.ecs_sg.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  cidr_ipv4         = "10.0.0.0/16"
  description                  = "Allow ECS tasks to access interface endpoints"
}

# Egress (to ecs)
resource "aws_vpc_security_group_egress_rule" "vpce_egress" {
  security_group_id = aws_security_group.vpce.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  #referenced_security_group_id = aws_security_group.ecs_sg.id
  cidr_ipv4         = "10.0.0.0/16"
  description       = "Endpoint outbound"
}
##########################
# Interface VPC Endpoints 
##########################
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [aws_security_group.vpce.id]
  private_dns_enabled = true

  tags = merge(local.common_tags, {
    Name = "wikijs-ecr-api-endpoint"
  })
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [aws_security_group.vpce.id]
  private_dns_enabled = true

  tags = merge(local.common_tags, {
    Name = "wikijs-ecr-dkr-endpoint"
  })
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [aws_security_group.vpce.id]
  private_dns_enabled = true

  tags = merge(local.common_tags, {
    Name = "wikijs-logs-endpoint"
  })
}