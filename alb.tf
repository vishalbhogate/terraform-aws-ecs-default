resource aws_lb ecs {
  count              = var.alb ? 1 : 0
  name               = "ecs-${var.name}"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [aws_security_group.alb[0].id]
  idle_timeout       = 400

  dynamic "access_logs" {
    for_each = compact([var.lb_access_logs_bucket])

    content {
      bucket  = var.lb_access_logs_bucket
      prefix  = var.lb_access_logs_prefix
      enabled = true
    }
  }

  tags = {
    Name = "ecs-${var.name}"
  }
}

resource aws_alb_listener "ecs_https" {
  count             = var.alb ? 1 : 0
  load_balancer_arn = aws_lb.ecs[0].arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ecs_default_https[0].arn
  }
}

resource aws_alb_listener "ecs_http_redirect" {
  count             = var.alb ? 1 : 0
  load_balancer_arn = aws_lb.ecs[0].arn
  protocol          = "HTTP"
  port              = 80

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource aws_alb_listener "ecs_test_https" {
  count             = var.alb ? 1 : 0
  load_balancer_arn = aws_lb.ecs[0].arn
  protocol          = "HTTPS"
  port              = 8443
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ecs_default_https[0].arn
  }
}

resource aws_alb_listener "ecs_tes_http_redirect" {
  count             = var.alb ? 1 : 0
  load_balancer_arn = aws_lb.ecs[0].arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "8443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Generate a random string to add it to the name of the Target Group
resource random_string "alb_prefix" {
  count   = var.alb ? 1 : 0
  length  = 4
  upper   = false
  special = false
}

resource aws_alb_target_group "ecs_default_http" {
  count    = var.alb ? 1 : 0
  name     = substr("ecs-${var.name}-default-http-${random_string.alb_prefix[0].result}", 0, 32)
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource aws_alb_target_group "ecs_default_https" {
  count    = var.alb ? 1 : 0
  name     = substr("ecs-${var.name}-default-https-${random_string.alb_prefix[0].result}", 0, 32)
  protocol = "HTTPS"
  port     = 443
  vpc_id   = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}
