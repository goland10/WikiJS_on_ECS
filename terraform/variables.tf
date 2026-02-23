variable "region" {
  type        = string
  description = "Default region"
  default = "eu-west-1"
}

variable "db_username" {
  type        = string
  description = "Database admin username"
  default = "postgres"
}

variable "db_password" {
  type        = string
  description = "Database admin password"
  sensitive   = true
  default = ""
}