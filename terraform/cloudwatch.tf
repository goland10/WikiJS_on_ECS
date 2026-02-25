resource "aws_cloudwatch_log_group" "wikijs" {
  name              = "/ecs/wikijs"
  retention_in_days = var.cloudwatch_retention_in_days #3

  tags = {
    Name = "wikijs-log-group"
  }
}