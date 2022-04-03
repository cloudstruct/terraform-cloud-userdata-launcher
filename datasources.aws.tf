locals {
  create_s3_bootstrap_policy = !var.code_package_public && var.cloud_provider == "aws" && length(var.bootstrap_objectstorage_bucket_name) != 0
}

data "aws_iam_policy_document" "assume_role" {
  count = var.cloud_provider == "aws" ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Policy allowing fetching code package from S3
data "aws_iam_policy_document" "s3_bootstrap" {
  count = local.create_s3_bootstrap_policy ? 1 : 0

  statement {
    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${data.aws_s3_bucket.bootstrap[0].arn}/*",
    ]
  }
}

data "aws_s3_bucket" "bootstrap" {
  count  = local.create_s3_bootstrap_policy ? 1 : 0
  bucket = var.bootstrap_objectstorage_bucket_name
}
