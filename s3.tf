resource "aws_s3_bucket" "redirect" {
  bucket        = "${var.from_domain_name}-redirect"
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_acl" "redirect_acl" {
  bucket = aws_s3_bucket.redirect.id
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

resource "aws_s3_bucket_policy" "redirect" {
  bucket = aws_s3_bucket.redirect.id
  policy = data.aws_iam_policy_document.redirect.json
}

data "aws_iam_policy_document" "redirect" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.redirect.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.cloudfront_oai.iam_arn]
    }
  }
}
