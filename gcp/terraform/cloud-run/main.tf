locals {
  prefix = "${var.project_name}-${var.environment}"
}

# Artifact Registry para almacenar imágenes Docker
resource "google_artifact_registry_repository" "docker_repo" {
  location      = var.location
  repository_id = "${local.prefix}-docker-repo"
  project       = var.project_id
  description   = "Docker repository for Cloud Run images"
  format        = "DOCKER"
}

# Cloud Run Service
resource "google_cloud_run_v2_service" "etl_processor" {
  name     = "${local.prefix}-etl-processor"
  location = var.location
  project  = var.project_id
  
  template {
    service_account = var.service_account
    
    containers {
      image = "${var.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/etl-processor:latest"
      
      env {
        name  = "DATA_LAKE_BUCKET"
        value = var.data_lake_bucket
      }
      
      env {
        name  = "ENVIRONMENT"
        value = var.environment
      }
      
      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }
    }
    
    scaling {
      max_instance_count = 10
    }
  }
  
  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
}

# Permitir invocación por service account
resource "google_cloud_run_v2_service_iam_member" "invoker" {
  project  = var.project_id
  location = var.location
  name     = google_cloud_run_v2_service.etl_processor.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${var.service_account}"
}