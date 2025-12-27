locals {
  prefix = "${var.project_name}-${var.environment}"
}

# Cluster
resource "aws_ecs_cluster" "main" {
  name = "${local.prefix}-cluster"
}

# IAM Role para ECS Task
resource "aws_iam_role" "ecs_task_execution" {
  name = "${local.prefix}-ecs-task-execution"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM Role para la Task (código dentro del contenedor)
resource "aws_iam_role" "ecs_task" {
  name = "${local.prefix}-ecs-task"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Permisos S3 para la Task
resource "aws_iam_role_policy" "ecs_s3_access" {
  name = "${local.prefix}-ecs-s3-access"
  role = aws_iam_role.ecs_task.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ]
      Resource = [
        "arn:aws:s3:::${var.data_lake_bucket}",
        "arn:aws:s3:::${var.data_lake_bucket}/*"
      ]
    }]
  })
}

# Task Definition
resource "aws_ecs_task_definition" "etl" {
  family                   = "${local.prefix}-etl"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn
  
  container_definitions = jsonencode([{
    name  = "etl-processor"
    image = var.container_image
    
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
        "awslogs-region"        = data.aws_region.current.name
        "awslogs-stream-prefix" = "ecs"
      }
    }
    
    environment = [
      {
        name  = "DATA_LAKE_BUCKET"
        value = var.data_lake_bucket
      },
      {
        name  = "ENVIRONMENT"
        value = var.environment
      }
    ]
  }])
}

# CloudWatch Logs
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${local.prefix}-etl"
  retention_in_days = 7
}

data "aws_region" "current" {}