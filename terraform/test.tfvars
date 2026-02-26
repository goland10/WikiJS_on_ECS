# Global
env    = "test"
region = "eu-west-1"
bucket = "wikijs-conf"

#Network
vpc_cidr        = "10.0.0.0/16"
azs             = ["eu-west-1a", "eu-west-1b"]
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

# App
app_name = "wikijs"
app_port = 3000

# Database (Low cost, no protection)
db_instance_class                        = "db.t4g.micro"
db_instance_backup_retention_period      = 0
db_instance_delete_automated_backups     = true
db_instance_skip_final_snapshot          = true
db_instance_deletion_protection          = false
db_instance_apply_immediately            = true
db_instance_performance_insights_enabled = false


# ECS (Minimal footprint)
task_definition_cpu    = 256
task_definition_memory = 512
ecs_min_capacity       = 1
ecs_max_capacity       = 2

# Logs
cloudwatch_retention_in_days = 3
