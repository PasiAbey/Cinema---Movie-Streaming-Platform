resource "aws_alb_listener" "this" {
  load_balancer_arn = var.alb-arn
  port              = var.alb-port
  protocol          = var.alb-protocol

  default_action {
    type             = "forward"
    target_group_arn = var.target-group-arn
  }
}