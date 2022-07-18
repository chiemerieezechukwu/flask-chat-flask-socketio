data "aws_route53_zone" "hosted_zone" {
  name = "chiemerie.com."
}

resource "aws_route53_record" "chatrrr_www" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = "chatrrr.chiemerie.com"
  type    = "A"

  alias {
    name                   = aws_lb.web-prod-lb.dns_name
    zone_id                = aws_lb.web-prod-lb.zone_id
    evaluate_target_health = true
  }
}
