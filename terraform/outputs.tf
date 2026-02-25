##########################
# ALB Outputs
##########################
output "alb_dns_name" {
  value = aws_lb.wikijs.dns_name
}

output "alb_region" {
  value = aws_lb.wikijs.region
}
##########################
# Database Outputs
##########################
output "db_endpoint" {
  value = aws_db_instance.wiki.endpoint
}

output "db_availability_zone" {
  value = aws_db_instance.wiki.availability_zone
}

################################
# ECS Cluster & Service Outputs
################################
output "ecs_cluster_name" {
  value = aws_ecs_cluster.wikijs.name
}

output "ecs_service_name" {
  value = aws_ecs_service.wikijs.name
}

output "ecs_service_desired_count" {
  value = aws_ecs_service.wikijs.desired_count
}
##########################
# Autoscaling Outputs
##########################
output "ecs_autoscaling_min_capacity" {
  value = aws_appautoscaling_target.ecs.min_capacity
}

output "ecs_autoscaling_max_capacity" {
  value = aws_appautoscaling_target.ecs.max_capacity
}

output "ecs_autoscaling_resource_id" {
  value = aws_appautoscaling_target.ecs.resource_id
}

output "ecs_cpu_scaling_policy_name" {
  value = aws_appautoscaling_policy.ecs_cpu.name
}

output "ecs_cpu_scaling_target_value" {
  value = aws_appautoscaling_policy.ecs_cpu.target_tracking_scaling_policy_configuration[0].target_value
}

##########################
# VPC Endpoint Outputs
##########################
output "vpce_s3_state" {
  value = aws_vpc_endpoint.s3.state
}

output "vpce_ecr_api_state" {
  value = aws_vpc_endpoint.ecr_api.state
}

output "vpce_ecr_dkr_state" {
  value = aws_vpc_endpoint.ecr_dkr.state
}

output "vpce_logs_state" {
  value = aws_vpc_endpoint.logs.state
}

output "vpce_secretsmanager_state" {
  value = aws_vpc_endpoint.secretsmanager.state
}
