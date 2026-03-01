########################################
# Application Load Balancer
########################################
resource "aws_lb" "wikijs" {
  name               = "wikijs-alb"
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.alb_sg.id]

  tags = {
    Name = "wikijs-alb"
  }
}

resource "aws_lb_target_group" "wikijs" {
  name        = "wikijs-tg"
  port        = var.app_port #3000
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

  tags = {
    Name = "wikijs-tg"
  }
}

# HTTPS (443) listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.wikijs.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09" # Recommended default
  certificate_arn   = aws_acm_certificate.wikijs_alb_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wikijs.arn
  }
}

# Redirect HTTP (80) to HTTPS (443)
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.wikijs.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
