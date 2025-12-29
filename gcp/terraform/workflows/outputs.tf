output "workflow_id" {
  description = "ID of the Cloud Workflow"
  value       = google_workflows_workflow.data_pipeline.id
}

output "workflow_name" {
  description = "Name of the Cloud Workflow"
  value       = google_workflows_workflow.data_pipeline.name
}