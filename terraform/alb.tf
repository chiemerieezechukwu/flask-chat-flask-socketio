resource "aws_lb" "web-prod-lb" {
  name               = "web-prod-lb"
  subnets            = [aws_subnet.web-prod-subnet-public-1.id, aws_subnet.web-prod-subnet-public-2.id, aws_subnet.web-prod-subnet-public-3.id]
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web-prod-lb-sg.id]
}

resource "aws_lb_listener" "web-prod-lb-http-forward" {
  load_balancer_arn = aws_lb.web-prod-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-prod-lb-tg.arn
  }
}

resource "aws_lb_target_group" "web-prod-lb-tg" {
  name        = "web-prod-lb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.web-prod-vpc.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "10"
    protocol            = "HTTP"
    matcher             = "200-399"
    timeout             = "5"
    path                = "/"
    unhealthy_threshold = "2"
  }
}