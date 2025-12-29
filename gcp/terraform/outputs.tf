output "data_lake_bucket" {
  description = "Name of the data lake bucket"
  value       = module.storage.data_lake_bucket
}

output "function_url" {
  description = "URL of the Cloud Function"
  value       = module.functions.function_url
}

output "cloudrun_service_url" {
  description = "URL of the Cloud Run service"
  value       = module.cloud_run.service_url
}

output "workflow_id" {
  description = "ID of the Cloud Workflow"
  value       = module.workflows.workflow_id
}

output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}