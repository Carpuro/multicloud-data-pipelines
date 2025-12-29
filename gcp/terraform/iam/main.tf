locals {
  prefix = "${var.project_name}-${var.environment}"
}

# Service Account para Cloud Functions
resource "google_service_account" "function" {
  account_id   = "${local.prefix}-function-sa"
  display_name = "Service Account for Cloud Functions"
  project      = var.project_id
}

# Permisos para Cloud Function (escribir a Storage)
# Access for Cloud Functions to write to Storage
resource "google_project_iam_member" "function_storage" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.function.email}"
}

# Service Account para Cloud Run
resource "google_service_account" "cloudrun" {
  account_id   = "${local.prefix}-cloudrun-sa"
  display_name = "Service Account for Cloud Run"
  project      = var.project_id
}

# Permisos para Cloud Run (leer/escribir Storage)
resource "google_project_iam_member" "cloudrun_storage" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.cloudrun.email}"
}

# Service Account para Workflows
resource "google_service_account" "workflow" {
  account_id   = "${local.prefix}-workflow-sa"
  display_name = "Service Account for Cloud Workflows"
  project      = var.project_id
}

# Permisos para Workflow (invocar Functions y Cloud Run)
resource "google_project_iam_member" "workflow_functions" {
  project = var.project_id
  role    = "roles/cloudfunctions.invoker"
  member  = "serviceAccount:${google_service_account.workflow.email}"
}

resource "google_project_iam_member" "workflow_run" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.workflow.email}"
}