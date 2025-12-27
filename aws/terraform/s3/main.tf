# Data Lake Bucket
resource "aws_s3_bucket" "data_lake" {
  bucket        = "${local.prefix}-data-lake"
  force_destroy = var.environment != "prod"  # Only allow force destroy in non-prod environments
  
  tags = local.common_tags
}

# Versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.data_lake.id
  
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

# Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.data_lake.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true  # Reduce costs for large objects
  }
}

# Block Public Access
resource "aws_s3_bucket_public_access_block" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle Policy (Ahorro de costos)
resource "aws_s3_bucket_lifecycle_configuration" "data_lake" {
  count  = var.lifecycle_rules_enabled ? 1 : 0
  bucket = aws_s3_bucket.data_lake.id

  rule {
    id     = "transition-old-data"
    status = "Enabled"

    # Transición a almacenamiento económico
    transition {
      days          = 30
      storage_class = "STANDARD_IA"  # Infrequent Access 
    }

    transition {
      days          = 90
      storage_class = "GLACIER_IR"  # Glacier Instant Retrieval
    }

    # Limpiar versiones antiguas
    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    # Limpiar uploads incompletos
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Logging (Opcional pero recomendado)
resource "aws_s3_bucket_logging" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "data-lake-logs/"
}

# Bucket para logs (Opcional)
resource "aws_s3_bucket" "logs" {
  bucket        = "${local.prefix}-logs"
  force_destroy = true
  
  tags = merge(local.common_tags, {
    Name = "${local.prefix}-logs"
  })
}

resource "aws_s3_object" "folders" {
  for_each = toset([
    "raw/",
    "staging/",
    "processed/",
    "archive/",
    "logs/",
    "temp/",
    "failed/"
  ])
  
  bucket  = aws_s3_bucket.data_lake.id
  key     = each.value
  content = ""
  
  tags = merge(local.common_tags, {
    Folder = each.value
  })
}