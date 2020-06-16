resource aws_iam_instance_profile "ecs" {
  name = "ecs-${var.name}-${data.aws_region.current.name}"
  role = aws_iam_role.ecs.name
}

data aws_iam_policy_document "ecs_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    sid     = ""
    principals {
      type        = "service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource aws_iam_role "ecs" {
  name               = "ecs-${var.name}-${data.aws_region.current.name}"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
}

resource aws_iam_role_policy_attachment "ecs_ssm" {
  role       = aws_iam_role.ecs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource aws_iam_role_policy_attachment "ecs_ecs" {
  role       = aws_iam_role.ecs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
