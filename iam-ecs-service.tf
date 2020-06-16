data aws_iam_policy_document "ecs_service_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    sid     = ""
    principals {
      type        = "service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource aws_iam_role "ecs_service" {
  name               = "ecs-service-${var.name}-${data.aws_region.current.name}"
  assume_role_policy = data.aws_iam_policy_document.ecs_service_assume.json
}

data aws_iam_policy_document "ecs_service_policy" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:RegisterTargets",
      "ec2:Describe*",
    "ec2:AuthorizeSecurityGroupIngress"]
  }
}

resource aws_iam_role_policy "ecs_service" {
  name   = "esc-service-role-policy-${var.name}"
  policy = data.aws_iam_policy_document.ecs_service_policy.json
  role   = aws_iam_role.ecs_service.id
}