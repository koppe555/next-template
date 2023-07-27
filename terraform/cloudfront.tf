resource "aws_cloudfront_distribution" "sample_next_app_distribution" {
  provider = aws

  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_api_gateway_rest_api.sample_api_gateway.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

  tags = {
    Name        = "sample CloudFront Distribution"
    Environment = "dev"
  }

   // api-gateway
  origin {
    origin_id   = aws_api_gateway_rest_api.sample_api_gateway.id
    domain_name = "${aws_api_gateway_rest_api.sample_api_gateway.id}.execute-api.ap-northeast-1.amazonaws.com"
    origin_path = "/${aws_api_gateway_stage.sample_next_api.stage_name}"

    custom_origin_config {
      http_port  = 80
      https_port = 443

      origin_protocol_policy = "https-only"
      origin_ssl_protocols = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2"
      ]
    }
  }
}