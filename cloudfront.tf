resource "aws_cloudfront_distribution" "redirect" {
  enabled         = true
  is_ipv6_enabled = true
  http_version    = "http2and3"
  price_class     = var.price_class

  aliases = [var.from_domain_name]

  viewer_certificate {
    acm_certificate_arn      = module.www_certificate.arn
    minimum_protocol_version = "TLSv1"
    ssl_support_method       = "sni-only"
  }

  origin {
    domain_name = aws_s3_bucket_website_configuration.redirect_website.website_endpoint
    origin_id   = "s3-bucket-redirect"

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "DELETE", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "s3-bucket-redirect"

    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    default_ttl = var.cache_ttl
    min_ttl     = (var.cache_ttl / 4) < 60 ? 0 : floor(var.cache_ttl / 4)
    max_ttl     = floor(var.cache_ttl * 24)

    forwarded_values {
      query_string = true
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.logs.bucket_domain_name
    prefix          = "cloudfront-redirect/"
  }
}

resource "aws_route53_record" "redirect-a_record" {
  zone_id = var.hosted_zone_id
  name    = var.from_domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.redirect.domain_name
    zone_id                = aws_cloudfront_distribution.redirect.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_cloudfront_origin_access_identity" "cloudfront_oai" {
  comment = "CloudFront OAI for ${aws_s3_bucket.redirect.bucket}"
}