resource "aws_s3_bucket" "example" {
  bucket = "my-secure-bucket"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.my_key.arn
      }
    }
  }

  versioning {
    enabled = true
  }

  logging {
    target_bucket = aws_s3_bucket.log_bucket.id
    target_prefix = "log/"
  }

  public_access_block {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }

  lifecycle_rule {
    id      = "expire_logs"
    enabled = true

    expiration {
      days = 90
    }
  }
}

resource "aws_kms_key" "my_key" {
  description         = "KMS key for S3 bucket encryption"
  enable_key_rotation = true
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = "my-secure-bucket-logs"
  acl    = "log-delivery-write"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "expire_logs"
    enabled = true

    expiration {
      days = 90
    }
  }

  public_access_block {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

resource "aws_s3_bucket" "dest" {
  bucket = "my-secure-bucket-replica"
  region = "us-west-1"

  versioning {
    enabled = true
  }

  public_access_block {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

resource "aws_iam_role" "replication_role" {
  name = "s3_replication_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "s3.amazonaws.com",
      },
      Effect = "Allow",
      Sid    = "",
    }]
  })
}

resource "aws_sns_topic" "bucket_notifications" {
  name               = "bucket-notifications"
  kms_master_key_id  = aws_kms_key.my_key.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.example.id

  topic {
    topic_arn = aws_sns_topic.bucket_notifications.arn
    events    = ["s3:ObjectCreated:*"]
  }
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  bucket = aws_s3_bucket.example.id

  role = aws_iam_role.replication_role.arn

  rules {
    id     = "replicationRule"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.dest.arn
      storage_class = "STANDARD"
    }
  }
}

