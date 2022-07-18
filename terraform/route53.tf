data "aws_route53_zone" "hosted_zone" {
  name         = "chiemerie.com."
}

resource "aws_route53_record" "chatrrr_www" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = "chatrrr.chiemerie.com"
  type    = "A"
  ttl = "300"
  records = [aws_lb.web-prod-lb.dns_name]
}