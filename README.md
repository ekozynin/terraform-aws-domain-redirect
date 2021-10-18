Terraform module to create a domain redirect, using Cloudfront and S3 bucket.

Example usage:

```hcl
module "domain-redirect" {
  source = "ekozynin/domain-redirect/aws"
  version = "~> 1.0.1"
  providers = {
    aws            = aws,
    aws.cloudfront = aws.cloudfront
  }

  from_domain_name   = "from.domain.com"
  target_domain_name = "to.domain.com"
  hosted_zone_id     = data.aws_route53_zone.zone.id

  logs_transition_ia      = 30
  logs_transition_glacier = 60
  logs_expiration         = 90
}
```
