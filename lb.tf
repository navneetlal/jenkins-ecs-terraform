resource "aws_lb" "load_balancer" {
  name               = "jenkins-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 80
  protocol          = "HTTP"
  #   ssl_policy        = "ELBSecurityPolicy-2016-08"
  #   certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }
}

resource "aws_lb_target_group" "lb_tg" {
  name                 = "JenkinsTargetGroup"
  port                 = 8080
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = module.vpc.vpc_id
  deregistration_delay = 10
  health_check {
    path = "/login"
  }
}
