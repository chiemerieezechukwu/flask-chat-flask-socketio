data "aws_iam_policy_document" "web-prod-ecs-iam-policy-doc" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "pull-from-private-registry" {
  name = "pull-from-private-registry"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "secretsmanager:GetSecretValue"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "web-prod-ecs-iam-role" {
  name               = local.ecs_task_role
  assume_role_policy = data.aws_iam_policy_document.web-prod-ecs-iam-policy-doc.json
}

resource "aws_iam_role_policy_attachment" "ecs-full-access-role-policy-attachment" {
  role       = aws_iam_role.web-prod-ecs-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.web-prod-ecs-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment" {
  role       = aws_iam_role.web-prod-ecs-iam-role.name
  policy_arn = aws_iam_policy.pull-from-private-registry.arn
}
