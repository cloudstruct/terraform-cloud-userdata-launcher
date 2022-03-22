resource "aws_s3_bucket" "bootstrap" {
  count = var.aws_tests ? 1 : 0

  bucket = var.bootstrap_objectstorage_bucket_name

  tags = {
    Name        = var.bootstrap_objectstorage_bucket_name
    Environment = "Testing"
    Repo        = "terraform-cloud-userdata-launcher"
  }
}

resource "aws_s3_bucket_acl" "bootstrap" {
  count = var.aws_tests ? 1 : 0

  bucket = aws_s3_bucket.bootstrap[0].id
  acl    = "private"
}
