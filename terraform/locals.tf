data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

locals {
  bucket = "${var.app_name}-conf"
  env_file = "${var.app_name}.env"
}

locals {
  common_tags = {
    Project     = "WikiJS"
    Environment = "Assessment"
    ManagedBy   = "Terraform"
  }
}