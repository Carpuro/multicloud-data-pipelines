variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "enable_versioning" {
  description = "Enable bucket versioning"
  type        = bool
  default     = true
}

variable "lifecycle_rules_enabled" {
  description = "Enable lifecycle rules for cost optimization"
  type        = bool
  default     = true
}

locals {
  prefix = "${var.project_name}-${var.environment}"
  
  common_tags = {
    Name        = "${local.prefix}-data-lake"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}