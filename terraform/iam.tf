########################################
# IAM Role - Task Execution Role
########################################

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "wikijs-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "wikijs-ecs-task-execution-role"
  }
}

# AWS managed policy for image pull and CloudWatch logs
resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Inline policy to read configuration from S3
resource "aws_iam_role_policy" "s3_read_bucket" {
  name = "wikijsS3ReadBucket"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowBucketDiscovery"
        Effect = "Allow"
        Action = ["s3:GetBucketLocation", "s3:ListBucket"]
        Resource = ["arn:aws:s3:::wikijs-conf"]
      },
      {
        Sid    = "AllowReadConfigObjects"
        Effect = "Allow"
        Action = ["s3:GetObject"]
        Resource = ["arn:aws:s3:::wikijs-conf/*"]
      }
    ]
  })
}

# Inline policy to allow ECS to fetch the password from Secret Manager created by RDS
resource "aws_iam_role_policy" "ecs_rds_secret_access" {
  role = aws_iam_role.ecs_task_execution_role.id
  name = "wikijsGetSecretValue"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = [aws_db_instance.wiki.master_user_secret[0].secret_arn]
    }]
  })
}
