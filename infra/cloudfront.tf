# 1. The "key card" that lets CloudFront read the private bucket
resource "aws_cloudfront_origin_access_control" "site" {
  name                              = "portfolio-oac"
  description                       = "Lets CloudFront read the private S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# 2. A ready-made AWS caching setting (good default for websites)
data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

# 3. The CloudFront distribution (your website on the internet)
resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  comment             = "Yasiru portfolio"
  default_root_object = "index.html"
  price_class         = "PriceClass_200"
  http_version        = "http2and3"

  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id                = "s3-site"
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
  }

  default_cache_behavior {
    target_origin_id       = "s3-site"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching_optimized.id
  }

  # React Router (BrowserRouter): unknown paths → load the React app
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
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

# 4. Bucket policy: allow ONLY this CloudFront distribution to read files
data "aws_iam_policy_document" "site_bucket" {
  statement {
    sid       = "AllowCloudFrontRead"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.site.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "site" {
  bucket     = aws_s3_bucket.site.id
  policy     = data.aws_iam_policy_document.site_bucket.json
  depends_on = [aws_s3_bucket_public_access_block.site]
}

output "website_url" {
  value = "https://${aws_cloudfront_distribution.site.domain_name}"
}

output "distribution_id" {
  value = aws_cloudfront_distribution.site.id
}