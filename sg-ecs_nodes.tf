resource aws_security_group "ecs_nodes" {
  name        = "ecs-${var.name}-nodes"
  description = "SG for ECS nodes"
  vpc_id      = var.vpc_id

  tags = {
    Name = "ecs-${var.name}-nodes"
  }
}

resource aws_security_group_rule "all_from_alb_to_ecs_nodes" {
  count                    = var.alb ? 1 : 0
  description              = "from ALB"
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 0
  type                     = "ingress"
  security_group_id        = aws_security_group.ecs_nodes.id
  source_security_group_id = aws_security_group.alb[0].id
}

resource aws_security_group_rule "all_from_internal_alb_to_ecs_nodes" {
  count                    = var.alb_internal ? 1 : 0
  description              = "from ALB Internal"
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 0
  type                     = "ingress"
  security_group_id        = aws_security_group.ecs_nodes.id
  source_security_group_id = aws_security_group.alb_internal[0].id
}

resource aws_security_group_rule "all_from_ecs_nodes_to_ecs_nodes" {
  description              = "Traffic between ecs node"
  type                     = "ingress"
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 0
  security_group_id        = aws_security_group.ecs_nodes.id
  source_security_group_id = aws_security_group.ecs_nodes.id
}

resource aws_security_group_rule "allfrom_ecs_node_to_world" {
  description       = "Traffic to internet"
  type              = "egress"
  to_port           = 0
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.ecs_nodes.id
  cidr_blocks       = ["0.0.0.0/0"]
}