output "data_lake_bucket" {
  description = "Name of the data lake bucket"
  value       = google_storage_bucket.data_lake.name
}

output "data_lake_bucket_url" {
  description = "URL of the data lake bucket"
  value       = google_storage_bucket.data_lake.url
}

output "logs_bucket" {
  description = "Name of the logs bucket"
  value       = google_storage_bucket.logs.name
}