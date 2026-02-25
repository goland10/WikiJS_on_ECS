variable "region" {
  type        = string
  description = "Default region"
  default     = "eu-west-1"
}

variable "db_username" {
  type        = string
  description = "Database admin username"
  default     = "postgres"
}

variable "ecs_min_capacity" {
type = number
default = 1
}

variable "ecs_max_capacity" {
type = number
default = 3
}