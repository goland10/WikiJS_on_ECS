########################################
# Task Definition
########################################
resource "aws_ecs_task_definition" "wikijs" {
  family                   = "wikijs-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_definition_cpu    #"256" # .25 vCPU
  memory                   = var.task_definition_memory #"512" # 0.5 GB
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  #task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name       = "wikijs"
      image      = "${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/wiki:2.5.312"
      essential  = true
      entryPoint = ["sh", "-c", "printenv && node server"]
      secrets = [
        {
          name = "DB_PASS"
          # Extract the 'password' key from the RDS-generated secret
          valueFrom = "${aws_db_instance.wiki.master_user_secret[0].secret_arn}:password::"
        }
      ]
      environmentFiles = [
        {
          value = "arn:aws:s3:::${local.bucket}/${local.env_file}" #wikijs.env
          type  = "s3"
        }
      ]
      environment = [
        {
          name = "DB_HOST"
          # Reference the RDS instance address attribute
          value = aws_db_instance.wiki.address
        },
        {
          name  = "DB_USER"
          value = var.db_user
        },        
        {
          name  = "HA_PROXY"
          value = "true" # Tells Wiki.js it's behind a load balancer
        },
        {
          name  = "WIKI_URL"
          value = "https://${aws_lb.wikijs.dns_name}" # Vital for proper link generation
        }
      ]
      portMappings = [
        {
          containerPort = var.app_port
          hostPort      = var.app_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/wikijs"
          "awslogs-region"        = var.region
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
    Name = "wikijs-cluster"
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
  #enable_execute_command = true

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.wikijs.arn
    container_name   = "wikijs"
    container_port   = var.app_port
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  depends_on = [
    aws_lb_listener.https
  ]

  tags = merge(local.common_tags, {
    Name = "wikijs-service"
  })
}
############################
# Autoscaling Target
############################

resource "aws_appautoscaling_target" "ecs" {
  max_capacity       = var.ecs_max_capacity
  min_capacity       = var.ecs_min_capacity
  resource_id        = "service/${aws_ecs_cluster.wikijs.name}/${aws_ecs_service.wikijs.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

############################
# CPU Target Tracking (70%)
############################

resource "aws_appautoscaling_policy" "ecs_cpu" {
  name               = "ecs-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 70.0
    scale_in_cooldown  = 60
    scale_out_cooldown = 60

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}