resource "aws_lb" "main" {
  name               = "${local.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = local.public_subnet_ids
}

resource "aws_alb_listener" "listener" {
  load_balancer_arn = aws_lb.main.arn

  port     = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.target_group.arn
    type             = "forward"
  }
}

resource "aws_alb_target_group" "target_group" {
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = local.vpc_id
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }
}
