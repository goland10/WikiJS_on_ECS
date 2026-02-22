variable "db_username" {
  type        = string
  description = "Database admin username"
  default = "postgres"
}

variable "db_password" {
  type        = string
  description = "Database admin password"
  sensitive   = true
  default = "hvr54sGO"
}