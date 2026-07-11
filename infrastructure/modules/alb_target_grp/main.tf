resource "aws_alb_target_group" "this" {
  name     = var.alb-target-group-name
  port     = var.alb-target-group-port
  protocol = var.alb-target-group-protocol
  vpc_id   = var.vpc-id
  target_type = "ip"
}