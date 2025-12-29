# Data sources - Buscar proyecto y región
data "google_project" "current" {}

data "google_compute_default_service_account" "default" {}

# Módulos
module "storage" {
  source       = "./storage"
  project_id   = var.project_id
  project_name = var.project_name
  environment  = var.environment
  location     = var.location
}

module "iam" {
  source       = "./iam"
  project_id   = var.project_id
  project_name = var.project_name
  environment  = var.environment
}

module "functions" {
  source            = "./functions"
  project_id        = var.project_id
  project_name      = var.project_name
  environment       = var.environment
  location          = var.location
  data_lake_bucket  = module.storage.data_lake_bucket
  service_account   = module.iam.function_service_account
}

module "cloud_run" {
  source            = "./cloud-run"
  project_id        = var.project_id
  project_name      = var.project_name
  environment       = var.environment
  location          = var.location
  data_lake_bucket  = module.storage.data_lake_bucket
  service_account   = module.iam.cloudrun_service_account
}

module "workflows" {
  source               = "./workflows"
  project_id           = var.project_id
  project_name         = var.project_name
  environment          = var.environment
  location             = var.location
  function_url         = module.functions.function_url
  cloudrun_url         = module.cloud_run.service_url
  service_account      = module.iam.workflow_service_account
}