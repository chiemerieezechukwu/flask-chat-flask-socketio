output "alb_app_dns" {
  value = aws_lb.web-prod-lb.dns_name
}
