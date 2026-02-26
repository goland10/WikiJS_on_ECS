# Global
env = "prod"
region          = "eu-west-1"
azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
cloudwatch_retention_in_days = 90

# App
app_name = "wikijs"
app_port = 3000

# Database (Production Hardening)
db_instance_backup_retention_period  = 31
db_instance_delete_automated_backups = false
db_instance_skip_final_snapshot      = false
db_instance_deletion_protection      = true
db_instance_apply_immediately        = false
db_instance_performance_insights_enabled          = true
db_instance_performance_insights_retention_period = 731

# ECS (Scalable Performance)
task_definition_cpu    = 512
task_definition_memory = 1024
ecs_min_capacity       = 2
ecs_max_capacity       = 6
