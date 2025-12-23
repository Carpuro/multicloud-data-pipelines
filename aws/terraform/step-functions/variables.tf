variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "lambda_arn" {
  type = string
}

variable "ecs_cluster_arn" { 
    type = string 
}

variable "ecs_task_definition_arn" { 
    type = string 
}

variable "subnets" { 
    type = list(string) 
}

variable "security_groups" { 
    type = list(string) 
}