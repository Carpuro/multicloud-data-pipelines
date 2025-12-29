locals {
  prefix = "${var.project_name}-${var.environment}"
}

# Data Lake Bucket
resource "google_storage_bucket" "data_lake" {
  name          = "${local.prefix}-data-lake"
  location      = var.location
  project       = var.project_id
  force_destroy = var.environment != "prod"
  
  uniform_bucket_level_access = true
  
  versioning {
    enabled = true
  }
  
  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }
  
  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }
  
  labels = {
    environment = var.environment
    project     = var.project_name
    managed_by  = "terraform"
  }
}

# Logs Bucket
resource "google_storage_bucket" "logs" {
  name          = "${local.prefix}-logs"
  location      = var.location
  project       = var.project_id
  force_destroy = true
  
  uniform_bucket_level_access = true
  
  labels = {
    environment = var.environment
    project     = var.project_name
    managed_by  = "terraform"
  }
}

# Folders (objetos vacíos para estructura)
resource "google_storage_bucket_object" "folders" {
  for_each = toset([
    "raw/",
    "staging/",
    "processed/",
    "archive/",
    "failed/"
  ])
  
  name    = each.value
  content = ""
  bucket  = google_storage_bucket.data_lake.name
}