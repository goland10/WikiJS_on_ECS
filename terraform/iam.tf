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
    Name        = "wikijs-ecs-task-execution-role"
    Project     = "WikiJS"
    Environment = "Assessment"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

########################################
# ECS Task Role for S3 access
########################################

resource "aws_iam_role" "ecs_task_role" {
  name = "wikijs-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "wikijs-ecs-task-role"
    Project     = "WikiJS"
    Environment = "Assessment"
    ManagedBy   = "Terraform"
  }
}

# Policy to allow ECS tasks to read the S3 .env file
resource "aws_iam_role_policy" "ecs_s3_access" {
  name = "ecs-s3-read-wikijs-env"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject"],
        Resource = "arn:aws:s3:::wikijs-conf/wikijs.env"
      }
    ]
  })
}