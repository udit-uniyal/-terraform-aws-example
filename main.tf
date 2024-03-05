resource "aws_s3_bucket" "example" {
  bucket = "my-secure-bucket"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
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
    block_public_acls   = true
    block_public_policy = true
    ignore_public_acls  = true
    restrict_public_buckets = true
  }
}

resource "aws_kms_key" "my_key" {
  description = "KMS key for S3 bucket encryption"
  policy      = data.aws_iam_policy_document.kms_policy.json
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = "my-secure-bucket-logs"
  acl    = "log-delivery-write"
}

