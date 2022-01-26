resource "aws_iam_role" "ecs-instance-role" {
  name = "ecs-instance-role-jenkins"
  path = "/"

  assume_role_policy = jsonencode({
    "Version" : "2008-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : ["ec2.amazonaws.com"]
        },
        "Effect" : "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment" {
  role       = aws_iam_role.ecs-instance-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_service_role" {
  role = aws_iam_role.ecs-instance-role.name
}

resource "aws_iam_role" "jenkins_execution_role" {
  name = "jenkins-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}

resource "aws_iam_role" "jenkins_role" {
  name = "jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "jenkins_policy" {
  name = "jenkins-policy"
  role = aws_iam_role.jenkins_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "ecs:RegisterTaskDefinition",
          "ecs:ListClusters",
          "ecs:DescribeContainerInstances",
          "ecs:ListTaskDefinitions",
          "ecs:DescribeTaskDefinition",
          "ecs:DeregisterTaskDefinition",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "ecs:ListContainerInstances",
          "ecs:RunTask",
          "ecs:StopTask",
          "ecs:DescribeTasks",
          "iam:GetRole",
          "iam:PassRole"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
