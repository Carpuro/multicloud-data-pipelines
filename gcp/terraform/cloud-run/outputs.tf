output "service_name" {
  description = "Name of the Cloud Run service"
  value       = google_cloud_run_v2_service.etl_processor.name
}

output "service_url" {
  description = "URL of the Cloud Run service"
  value       = google_cloud_run_v2_service.etl_processor.uri
}

output "docker_repo" {
  description = "Artifact Registry repository name"
  value       = google_artifact_registry_repository.docker_repo.name
}