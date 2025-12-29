variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "location" {
  description = "GCP location/region"
  type        = string
}

variable "data_lake_bucket" {
  description = "Name of the data lake bucket"
  type        = string
}

variable "service_account" {
  description = "Service account email for Cloud Run"
  type        = string
}