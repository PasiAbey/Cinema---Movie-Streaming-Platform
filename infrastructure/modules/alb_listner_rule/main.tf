resource "aws_alb_listener_rule" "this" {
  listener_arn = var.alb_listener-arn
  priority     = var.priority
  action {
    type             = "forward"
    target_group_arn = var.target-group-arn
  }

  condition {
    path_pattern {
      values = var.path-pattern
    }
  }
}