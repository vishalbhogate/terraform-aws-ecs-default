data aws_iam_policy_document "ecs_task_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    sid     = ""
    principals {
      type        = "service"
      identifiers = ["ecs-task.amazonaws.com"]
    }
  }
}

resource aws_iam_role "ecs_task" {
  name               = "ecs-task-${var.name}-${data.aws_region.current.name}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}

resource aws_iam_role_policy_attachment "ecs_task" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data aws_iam_policy_document "ecs_task_policy" {
  statement {
    effect    = "Allow"
    resources = ["arn:aws:ssm:*:*:parameter/*"]
    actions   = ["ssm:GetParameters"]
  }
}

resource aws_iam_role_policy "ecs_task" {
  name   = "ecs-ssm-policy"
  role   = aws_iam_role.ecs_task.name
  policy = data.aws_iam_policy_document.ecs_task_policy.json
}