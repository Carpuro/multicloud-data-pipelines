output "function_name" {
  description = "Name of the Cloud Function"
  value       = google_cloudfunctions2_function.ingestion.name
}

output "function_url" {
  description = "URL of the Cloud Function"
  value       = google_cloudfunctions2_function.ingestion.service_config[0].uri
}