resource "aws_lb" "wikijs" {
  name               = "wikijs-alb"
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.alb_sg.id]

  tags = merge(local.common_tags, {
    Name = "wikijs-alb"
  })
}

resource "aws_lb_target_group" "wikijs" {
  name        = "wikijs-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(local.common_tags, {
    Name = "wikijs-tg"
  })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.wikijs.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wikijs.arn
  }

  tags = merge(local.common_tags, {
    Name = "wikijs-http-listener"
  })
}
