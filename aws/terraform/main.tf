module "ecs" {
  source           = "./ecs"
  project_name     = var.project_name
  environment      = var.environment
  data_lake_bucket = module.s3.data_lake_bucket
  subnets          = var.subnets
  security_groups  = var.security_groups
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

module "s3" {
  source = "./s3"
  project_name            = var.project_name
  environment             = var.environment
  enable_versioning       = true
  lifecycle_rules_enabled = var.environment == "prod"  # Only enable lifecycle rules in prod
}

module "step_functions" {
  source                  = "./step-functions"
  project_name            = var.project_name
  environment             = var.environment
  lambda_arn              = module.lambda.lambda_arn
  ecs_cluster_arn         = module.ecs.cluster_arn          
  ecs_task_definition_arn = module.ecs.task_definition_arn  
  subnets                 = var.subnets
  security_groups         = var.security_groups
}