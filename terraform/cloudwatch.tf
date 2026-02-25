resource "aws_cloudwatch_log_group" "wikijs" {
  name              = "/ecs/wikijs"
  retention_in_days = 14

  tags = {
    Name = "wikijs-log-group"
  }
}