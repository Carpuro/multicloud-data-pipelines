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

variable "function_url" {
  description = "URL of the Cloud Function"
  type        = string
}

variable "cloudrun_url" {
  description = "URL of the Cloud Run service"
  type        = string
}

variable "service_account" {
  description = "Service account email for Workflow"
  type        = string
}