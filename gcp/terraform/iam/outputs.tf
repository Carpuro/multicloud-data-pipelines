output "function_service_account" {
  description = "Email of the Cloud Function service account"
  value       = google_service_account.function.email
}

output "cloudrun_service_account" {
  description = "Email of the Cloud Run service account"
  value       = google_service_account.cloudrun.email
}

output "workflow_service_account" {
  description = "Email of the Workflow service account"
  value       = google_service_account.workflow.email
}