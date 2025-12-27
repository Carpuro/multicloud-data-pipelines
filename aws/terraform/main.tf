# Look for the default VPC and its subnets and security groups
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name   = "default"
}

# Modules
module "s3" {
  source                  = "./s3"
  project_name            = var.project_name
  environment             = var.environment
  enable_versioning       = true
  lifecycle_rules_enabled = var.environment == "prod"
}

module "iam" {
  source       = "./iam"
  project_name = var.project_name
  environment  = var.environment
}

module "lambda" {
  source           = "./lambda"
  project_name     = var.project_name
  environment      = var.environment
  data_lake_bucket = module.s3.data_lake_bucket
}

module "ecs" {
  source           = "./ecs"
  project_name     = var.project_name
  environment      = var.environment
  data_lake_bucket = module.s3.data_lake_bucket
  subnets          = data.aws_subnets.default.ids
  security_groups  = [data.aws_security_group.default.id]
}

module "step_functions" {
  source                  = "./step-functions"
  project_name            = var.project_name
  environment             = var.environment
  lambda_arn              = module.lambda.lambda_arn
  ecs_cluster_arn         = module.ecs.cluster_arn
  ecs_task_definition_arn = module.ecs.task_definition_arn
  subnets                 = data.aws_subnets.default.ids
  security_groups         = [data.aws_security_group.default.id]
}