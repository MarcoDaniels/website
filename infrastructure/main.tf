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
  config  = jsondecode(data.dhall.config.result)
  aws     = local.config.aws
  project = local.config.project
  origins = {
    website = "static-website"
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

// CloudFront
resource "aws_cloudfront_origin_access_identity" "oai" {}

resource "aws_cloudfront_distribution" "distribution" {
  enabled         = true
  is_ipv6_enabled = true

  comment     = "Distribution for ${local.project.description}"
  price_class = "PriceClass_100"

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

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

output "cloudfront-domain" {
  value = "https://${aws_cloudfront_distribution.distribution.domain_name}"
}