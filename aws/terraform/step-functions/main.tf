locals {
  prefix = "${var.project_name}-${var.environment}"
}

resource "aws_iam_role" "step_functions_role" {
  name = "${local.prefix}-step-functions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "states.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "invoke_lambda" {
  name = "${local.prefix}-invoke-lambda"
  role = aws_iam_role.step_functions_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["lambda:InvokeFunction"]
      Resource = var.lambda_arn
    }]
  })
}

resource "aws_sfn_state_machine" "data_pipeline" {
  name     = "${local.prefix}-data-pipeline"
  role_arn = aws_iam_role.step_functions_role.arn

  definition = jsonencode({
    Comment = "AWS data pipeline: ingestion + transformation"
    StartAt = "IngestData"
    States = {
      IngestData = {
        Type     = "Task"
        Resource = var.lambda_arn
        Next     = "TransformData"
        Retry = [{
          ErrorEquals     = ["States.ALL"]
          IntervalSeconds = 5
          MaxAttempts     = 3
          BackoffRate     = 2.0
        }]
      }

      TransformData = {
        Type     = "Task"
        Resource = "arn:aws:states:::ecs:runTask.sync"
        Parameters = {
          Cluster = var.ecs_cluster_arn
          TaskDefinition = var.ecs_task_definition_arn
          LaunchType = "FARGATE"
          NetworkConfiguration = {
            AwsvpcConfiguration = {
              AssignPublicIp = "ENABLED"
              Subnets        = var.subnets
              SecurityGroups = var.security_groups
            }
          }
        }
        End = true
      }
    }
  })
}

resource "aws_iam_role_policy" "ecs_run_task" {
  name = "${local.prefix}-ecs-run-task"
  role = aws_iam_role.step_functions_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:RunTask",
          "ecs:StopTask",
          "ecs:DescribeTasks"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = ["iam:PassRole"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "eventbridge_permissions" {
  name = "${local.prefix}-eventbridge-permissions"
  role = aws_iam_role.step_functions_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "events:PutTargets",
          "events:PutRule",
          "events:DescribeRule"
        ]
        Resource = "*"
      }
    ]
  })
}