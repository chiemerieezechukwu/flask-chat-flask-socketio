data "aws_route53_zone" "hosted_zone" {
  name         = "chiemerie.com."
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = "chatrrr.chiemerie.com"
  type    = "A"
  records = [aws_lb.web-prod-lb.dns_name]
}