resource "aws_route53_zone" "my-route-dns-dev" {
  name    = "mydomain.com"
  comment = "Hosted Domain"
  tags = {
    env = "dev"
  }
}

# DNS A wildcard record
resource "aws_route53_record" "wildcard-record-dev" {
  zone_id = aws_route53_zone.my-route-dns-dev.zone_id
  name    = "*"
  type    = "A"
  ttl     = "300"
  records = ["1.1.1.1"]
}

# DNS A domain to IP record
resource "aws_route53_record" "my-route-api-record-dev" {
  zone_id = aws_route53_zone.my-route-dns-dev.zone_id
  name    = "sub.mydomain.com"
  type    = "A"
  ttl     = "300"
  records = ["1.0.0.1"]
}

# DNS CNAME to Cloudfront. Probably comment this out first.
resource "aws_route53_record" "my-route-cname-cdn" {
  zone_id = aws_route53_zone.my-route-dns-dev.zone_id
  name    = "cdn.mydomain.com"
  type    = "CNAME"
  ttl     = "300"
  # For existing CloudFront
#   records = ["xxxxx.cloudfront.net"]
  records = [aws_cloudfront_distribution.my-cdn-s3-distribution.domain_name]
}