resource "aws_s3_bucket" "redirect" {
  bucket        = "${var.from_domain_name}-redirect"
  acl           = "private"
  force_destroy = var.force_destroy

  website {
    redirect_all_requests_to = var.target_domain_name
  }

  logging {
    target_bucket = aws_s3_bucket.logs.id
    target_prefix = "s3-redirect/"
  }
}
