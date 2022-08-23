resource "aws_s3_bucket" "redirect" {
  bucket        = "${var.from_domain_name}-redirect"
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_acl" "redirect_acl" {
  bucket = "${var.from_domain_name}-redirect"
  acl    = "private"
}

resource "aws_s3_bucket_logging" "redirect_logging" {
  bucket        = "${var.from_domain_name}-redirect"
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "s3-www/"
}


resource "aws_s3_bucket_website_configuration" "redirect_website" {
  bucket = "${var.from_domain_name}-redirect"
  redirect_all_requests_to {
    host_name = var.target_domain_name
  }
}