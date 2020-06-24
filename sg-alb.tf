resource aws_security_group "alb" {
  count       = var.alb ? 1 : 0
  name        = "ecs-${var.name}-lb"
  description = "SG for ECS ALB"
  vpc_id      = var.vpc_id

  tags = {
    Name = "ecs-${var.name}-lb"
  }
}

resource aws_security_group_rule "http_from_world_to_alb" {
  count             = var.alb ? 1 : 0
  description       = "HTTP redirect yo ecs"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb[0].id
}

resource aws_security_group_rule "https_from_world_to_alb" {
  count             = var.alb ? 1 : 0
  description       = "HTTPS redirect yo ecs"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = "tcp"
  security_group_id = aws_security_group.alb[0].id
}

resource aws_security_group_rule "https_test_listener_from_world_to_alb" {
  count             = var.alb ? 1 : 0
  description       = "HTTPS ECS ALB Test Listener"
  type              = "ingress"
  from_port         = 8443
  to_port           = 8443
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = "tcp"
  security_group_id = aws_security_group.alb[0].id
}

resource aws_security_group_rule "to_ecs_nodes" {
  count                    = var.alb ? 1 : 0
  description              = "Traffic to ecs nodes"
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.alb[0].id
  source_security_group_id = aws_security_group.ecs_nodes.id
}