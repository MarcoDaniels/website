terraform {
  backend "remote" {
    organization = "MarcoDaniels"

    workspaces {
      name = "website"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.70.0"
    }

    dhall = {
      source  = "awakesecurity/dhall"
      version = "0.0.2"
    }
  }
}

data "dhall" "config" {
  entrypoint = "./config.dhall"
}

locals {
  config   = jsondecode(data.dhall.config.result)
  aws      = local.config.aws
  project  = local.config.project
  assetAPI = local.config.assetAPI
  origins  = {
    website = "static-website"
    assets  = "assets-api"
  }
}

provider "aws" {
  region     = local.aws.region
  access_key = local.aws.accessKey
  secret_key = local.aws.secretKey
}

// S3
resource "aws_s3_bucket" "bucket" {
  bucket_prefix = local.aws.bucketPrefix
  acl           = "private"
}

data "aws_iam_policy_document" "bucket-policy" {
  statement {
    sid       = "OAIRead"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.bucket.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.bucket-policy.json
}

resource "aws_iam_user" "bucket-write" {
  name = "${local.project.name}-bucket-write"
}

resource "aws_iam_access_key" "bucket-write" {
  user = aws_iam_user.bucket-write.name
}

data "aws_iam_policy_document" "bucket-write" {
  statement {
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.bucket.arn, "${aws_s3_bucket.bucket.arn}/*"]
  }
  statement {
    actions   = ["cloudfront:CreateInvalidation"]
    resources = [aws_cloudfront_distribution.distribution.arn]
  }
}

resource "aws_iam_user_policy" "bucket-write" {
  name   = "${local.project.name}-bucket-write-policy"
  policy = data.aws_iam_policy_document.bucket-write.json
  user   = aws_iam_user.bucket-write.name
}

output "bucket" {
  value     = aws_s3_bucket.bucket.bucket
  sensitive = true
}

output "bucket-keys" {
  value = {
    access_key_id     = aws_iam_access_key.bucket-write.id
    secret_access_key = aws_iam_access_key.bucket-write.secret
  }
  sensitive = true
}

// CloudFront
resource "aws_cloudfront_origin_access_identity" "oai" {}

resource "aws_cloudfront_distribution" "distribution" {
  enabled         = true
  is_ipv6_enabled = true

  comment     = "Distribution for ${local.project.description}"
  price_class = "PriceClass_100"

  aliases = [local.project.domain]

  default_cache_behavior {
    target_origin_id = local.origins.website

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]

    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
      event_type = "origin-request"
      lambda_arn = module.website-request.qualified-arn
    }

    lambda_function_association {
      event_type = "origin-response"
      lambda_arn = module.website-response.qualified-arn
    }

    min_ttl     = 60
    default_ttl = 3600
    max_ttl     = 86400
  }

  ordered_cache_behavior {
    path_pattern     = "image/api/*"
    target_origin_id = local.origins.assets

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]

    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
      event_type = "origin-request"
      lambda_arn = module.asset-request.qualified-arn
    }

    min_ttl     = 60
    default_ttl = 3600
    max_ttl     = 86400
  }

  origin {
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = local.origins.website

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  origin {
    domain_name = local.assetAPI.domain
    origin_id   = local.origins.assets

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.website-certificate.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
}

output "cloudfront-domain" {
  value = "https://${aws_cloudfront_distribution.distribution.domain_name}"
}

// lambda@edge
module "website-request" {
  source       = "./lambda"
  lambda-name  = "WebsiteRequest"
  project-name = local.project.name
}

module "website-response" {
  source       = "./lambda"
  lambda-name  = "WebsiteResponse"
  project-name = local.project.name
}

module "asset-request" {
  source       = "./lambda"
  lambda-name  = "AssetRequest"
  project-name = local.project.name

  replacements = {
    token  = local.assetAPI.token
    domain = local.assetAPI.domain
  }
}

// route53
resource "aws_route53_zone" "website-zone" {
  name = local.project.domain
}

resource "aws_route53_record" "website-record" {
  zone_id = aws_route53_zone.website-zone.id
  name    = local.project.domain
  type    = "A"

  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
  }
}

resource "aws_route53_record" "website-record-certificate" {
  name            = tolist(aws_acm_certificate.website-certificate.domain_validation_options)[0].resource_record_name
  type            = tolist(aws_acm_certificate.website-certificate.domain_validation_options)[0].resource_record_type
  records         = [tolist(aws_acm_certificate.website-certificate.domain_validation_options)[0].resource_record_value]
  zone_id         = aws_route53_zone.website-zone.id
  allow_overwrite = true
  ttl             = 60
}

// acm
resource "aws_acm_certificate" "website-certificate" {
  domain_name       = local.project.domain
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "website-certificate-validation" {
  certificate_arn         = aws_acm_certificate.website-certificate.arn
  validation_record_fqdns = [aws_route53_record.website-record-certificate.fqdn]
}

output "website" {
  value = "https://${local.project.domain}"
}