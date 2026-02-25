########################################
# Global Variables
########################################
variable "region" {
  type        = string
  description = "Default AWS region for deployment (e.g., eu-west-1)."
  default     = "eu-west-1"
}

variable "azs" {
  # The type is dynamic as it is passed from a module, but generally a list(string) is expected.
  description = "A list of availability zones to use for the VPC."
  default = [
    "eu-west-1a",
    "eu-west-1b",
    #"eu-west-1c",
  ]
}

variable "public_subnets" {
  # The type is dynamic as it is passed from a module, but generally a list(string) is expected.
  description = "A list of CIDR blocks for public subnets."
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    #"10.0.3.0/24",
  ]
}

variable "private_subnets" {
  # The type is dynamic as it is passed from a module, but generally a list(string) is expected.
  description = "A list of CIDR blocks for private subnets."
  default = [
    "10.0.11.0/24",
    "10.0.12.0/24",
    #"10.0.13.0/24",
  ]
}

variable "cloudwatch_retention_in_days" {
  type        = number
  description = "Number of days for CloudWatch log retention."
  default     = 3
}

########################################
# Application Variables
########################################
variable "app_port" {
  type        = number
  description = "The port the application listens on (e.g., 3000)."
  default     = 3000
}

variable "app_name" {
  type        = string
  description = "The name of the application, used for resource naming (e.g., wikijs)."
  default     = "wikijs"
}

########################################
# Database Variables
########################################
variable "db_username" {
  type        = string
  description = "Database admin username."
  default     = "postgres"
}

variable "db_port" {
  type        = number
  description = "The port the database listens on."
  default     = 5432
}

variable "db_instance_backup_retention_period" {
  type        = number
  description = "Number of days for database backup retention."
  default     = 0
}

variable "db_instance_delete_automated_backups" {
  type        = bool
  description = "Whether to delete automated backups when the DB instance is deleted."
  default     = true
}

variable "db_instance_skip_final_snapshot" {
  type        = bool
  description = "Whether to skip the final snapshot when deleting the DB instance."
  default     = true
}

variable "db_instance_deletion_protection" {
  type        = bool
  description = "Whether the database instance has deletion protection enabled."
  default     = false
}

variable "db_instance_apply_immediately" {
  type        = bool
  description = "Whether to apply changes immediately."
  default     = true
}

variable "db_instance_performance_insights_enabled" {
  type        = bool
  description = "Whether performance insights are enabled for the DB instance."
  default     = false
}

variable "db_instance_performance_insights_retention_period" {
  type        = number
  description = "Number of days to retain performance insights data."
  default     = 7
}

########################################
# ECS Variables
########################################
variable "task_definition_cpu" {
  type        = number
  description = "The CPU limit (in vCPU) for the ECS task definition."
  default     = 256 # .25 vCPU
}

variable "task_definition_memory" {
  type        = number
  description = "The memory limit (in GB) for the ECS task definition."
  default     = 512 # 0.5 GB
}

variable "ecs_min_capacity" {
  type        = number
  description = "Minimum capacity for ECS autoscaling."
  default     = 1
}

variable "ecs_max_capacity" {
  type        = number
  description = "Maximum capacity for ECS autoscaling."
  default     = 3
}
