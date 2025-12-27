variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "data_lake_bucket" {
  description = "S3 bucket name"
  type        = string
}

variable "subnets" {
  description = "Subnet IDs for ECS tasks"
  type        = list(string)
}

variable "security_groups" {
  description = "Security group IDs for ECS tasks"
  type        = list(string)
}

variable "task_cpu" {
  description = "CPU units for ECS task"
  type        = string
  default     = "256"  # 0.25 vCPU
}

variable "task_memory" {
  description = "Memory for ECS task (MB)"
  type        = string
  default     = "512"  # 512 MB
}

variable "container_image" {
  description = "Docker image for ETL processing"
  type        = string
  default     = "public.ecr.aws/docker/library/python:3.11-slim"  # Placeholder
}