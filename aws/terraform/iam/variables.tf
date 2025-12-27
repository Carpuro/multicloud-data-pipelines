variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

locals {
  prefix = "${var.project_name}-${var.environment}"
}