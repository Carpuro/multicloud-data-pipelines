locals {
  prefix = "${var.project_name}-${var.environment}"
}

# Cloud Workflow para orquestar el pipeline
resource "google_workflows_workflow" "data_pipeline" {
  name            = "${local.prefix}-data-pipeline"
  project         = var.project_id
  region          = var.location
  description     = "Data pipeline orchestration"
  service_account = var.service_account
  
  source_contents = <<-EOF
    main:
      steps:
        - ingest_data:
            call: http.post
            args:
              url: ${var.function_url}
              auth:
                type: OIDC
            result: ingestion_result
        
        - log_ingestion:
            call: sys.log
            args:
              text: $${"Ingestion completed: " + json.encode_to_string(ingestion_result)}
              severity: INFO
        
        - transform_data:
            call: http.post
            args:
              url: ${var.cloudrun_url}
              auth:
                type: OIDC
              body:
                input_path: $${ingestion_result.body.s3_path}
            result: transformation_result
        
        - log_transformation:
            call: sys.log
            args:
              text: $${"Transformation completed: " + json.encode_to_string(transformation_result)}
              severity: INFO
        
        - return_result:
            return:
              ingestion: $${ingestion_result}
              transformation: $${transformation_result}
              status: "SUCCESS"
  EOF
}