resource "aws_s3_bucket" "my-cdn-s3" {
  bucket = "ch4dwick-cdn"
  tags = {
    type = "ui"
  }
}

resource "aws_s3_bucket_public_access_block" "my-cdn-s3-block" {
  bucket = aws_s3_bucket.my-cdn-s3.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_control" "my-oac" {
  name                              = "My OAC"
  description                       = "For OAC to S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "no-override"
  signing_protocol                  = "sigv4"
}

resource "aws_s3_bucket_policy" "my-cdn-cf-policy" {
  bucket = aws_s3_bucket.my-cdn-s3.id
  policy = data.aws_iam_policy_document.my-cdn-cf-policy.json
}

data "aws_iam_policy_document" "my-cdn-cf-policy" {
  statement {
    sid = "1"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
      # This is needed to trigger a 404 from CloudFront. Otherwise, you'll need to catch the 403.
      "s3:ListBucket"
    ]

    resources = [
      "${aws_s3_bucket.my-cdn-s3.arn}/*",
      # This is needed to trigger a 404 from CloudFront. Otherwise, you'll need to catch the 403.
      "${aws_s3_bucket.my-cdn-s3.arn}"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.my-cdn-s3-distribution.arn]
    }
  }
}

locals {
  s3_origin_id = aws_s3_bucket.my-cdn-s3.bucket_regional_domain_name
}

resource "aws_cloudfront_distribution" "my-cdn-s3-distribution" {

  origin {
    domain_name              = aws_s3_bucket.my-cdn-s3.bucket_regional_domain_name
    origin_id                = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.my-oac.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "My CDN"
  default_root_object = "index.html"

  #   logging_config {
  #     include_cookies = false
  #     bucket          = "mylogs.s3.amazonaws.com"
  #     prefix          = "myprefix"
  #   }

  # You need an AWS Certificate Manager entry for your domain before you can set this.
  # aliases = ["my.domain.com"]

  default_cache_behavior {
    origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.my-cdn-origin.id
    cache_policy_id            = data.aws_cloudfront_cache_policy.my-cdn-cache.id
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.my-cdn-cors.id

    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  # VueJS Catch-all
  # Use this if you don't want to use the s3:ListBucket solution.
  # custom_error_response {
  #   error_code            = 403
  #   response_code         = 200
  #   response_page_path    = "/index.html"
  #   error_caching_min_ttl = 10
  # }

  # VueJS Catch-all
  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }

  # Cache behavior with precedence 0
  #   ordered_cache_behavior {
  #     path_pattern     = "/*"
  #     allowed_methods  = ["GET", "HEAD", "OPTIONS"]
  #     cached_methods   = ["GET", "HEAD", "OPTIONS"]
  #     target_origin_id = local.s3_origin_id

  #     forwarded_values {
  #       query_string = false
  #       headers      = ["Origin"]

  #       cookies {
  #         forward = "none"
  #       }
  #     }

  #     min_ttl     = 0
  #     default_ttl = 86400
  #     max_ttl     = 31536000
  #     compress    = true
  #     # viewer_protocol_policy = "redirect-to-https"
  #     viewer_protocol_policy = "allow-all"
  #   }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      # Yes! None is configured EXACTLY like this!
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    # Must be in us-east-1. Not changeable at the time of this writing.
    # acm_certificate_arn      = "arn:aws:acm:us-east-1:xxxxx:certificate/xxxxx"
    # ssl_support_method       = "sni-only"
    # minimum_protocol_version = "TLSv1.2_2021"

    # Comment below if you're using above
    cloudfront_default_certificate = true
  }
}

data "aws_cloudfront_origin_request_policy" "my-cdn-origin" {
  name = "Managed-CORS-S3Origin"
}

data "aws_cloudfront_cache_policy" "my-cdn-cache" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_response_headers_policy" "my-cdn-cors" {
  name = "Managed-CORS-with-preflight-and-SecurityHeadersPolicy"
}
