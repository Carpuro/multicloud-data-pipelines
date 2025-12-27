output "data_lake_bucket" {
  description = "Name of the data lake bucket"
  value       = aws_s3_bucket.data_lake.bucket
}

output "data_lake_bucket_id" {
  description = "ID of the data lake bucket"
  value       = aws_s3_bucket.data_lake.id
}

output "data_lake_bucket_arn" {
  description = "ARN of the data lake bucket"
  value       = aws_s3_bucket.data_lake.arn
}

output "data_lake_bucket_domain_name" {
  description = "Domain name of the bucket"
  value       = aws_s3_bucket.data_lake.bucket_domain_name
}

output "logs_bucket" {
  description = "Name of the logs bucket"
  value       = aws_s3_bucket.logs.bucket
}