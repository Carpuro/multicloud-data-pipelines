locals {
  prefix = "${var.project_name}-${var.environment}"
}

# Cloud Storage bucket para el código de la función
resource "google_storage_bucket" "function_source" {
  name          = "${local.prefix}-function-source"
  location      = var.location
  project       = var.project_id
  force_destroy = true
  
  uniform_bucket_level_access = true
}

# Subir el código ZIP de la función
resource "google_storage_bucket_object" "function_zip" {
  name   = "ingestion-${filemd5("${path.module}/../../../pipelines/ingestion/function-source.zip")}.zip"
  bucket = google_storage_bucket.function_source.name
  source = "${path.module}/../../../pipelines/ingestion/function-source.zip"
}

# Cloud Function
resource "google_cloudfunctions2_function" "ingestion" {
  name        = "${local.prefix}-ingestion"
  location    = var.location
  project     = var.project_id
  description = "Data ingestion function"
  
  build_config {
    runtime     = "python311"
    entry_point = "ingest_data"
    
    source {
      storage_source {
        bucket = google_storage_bucket.function_source.name
        object = google_storage_bucket_object.function_zip.name
      }
    }
  }
  
  service_config {
    max_instance_count    = 10
    available_memory      = "256M"
    timeout_seconds       = 60
    service_account_email = var.service_account
    
    environment_variables = {
      DATA_LAKE_BUCKET = var.data_lake_bucket
      ENVIRONMENT      = var.environment
    }
  }
}

# Permitir invocación pública (opcional, ajustar según necesidad)
resource "google_cloud_run_service_iam_member" "invoker" {
  project  = var.project_id
  location = var.location
  service  = google_cloudfunctions2_function.ingestion.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${var.service_account}"
}