########################################
# Task Definition
########################################
resource "aws_ecs_task_definition" "wikijs" {
  family                   = "wikijs-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"   # .25 vCPU
  memory                   = "512"   # 0.5 GB
  execution_role_arn       = "arn:aws:iam::643218715566:role/WikijsTaskExecutionRole"
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "wikijs"
      image     = "643218715566.dkr.ecr.eu-west-1.amazonaws.com/wiki:2.5.312"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "WIKIJS_ENV_FILE"
          value = "s3://wikijs-conf/wikijs.env"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/wikijs"
          "awslogs-region"        = "eu-west-1"
          "awslogs-stream-prefix" = "wikijs"
        }
      }
    }
  ])
}
########################################
# ECS Cluster (Container Insights Disabled)
########################################
resource "aws_ecs_cluster" "wikijs" {
  name = "wikijs-cluster"

  tags = {
    Name        = "wikijs-cluster"
    Project     = "WikiJS"
    Environment = "Assessment"
  }
}
########################################
# ECS Service
########################################
resource "aws_ecs_service" "wikijs" {
  name            = "wikijs-service"
  cluster         = aws_ecs_cluster.wikijs.name
  task_definition = aws_ecs_task_definition.wikijs.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.wikijs.arn
    container_name   = "wikijs"
    container_port   = 3000
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  depends_on = [
    aws_lb_listener.http
  ]

  tags = merge(local.common_tags, {
    Name = "wikijs-service"
  })
}