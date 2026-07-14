resource "aws_alb_target_group" "this" {
  name     = var.alb-target-group-name
  port     = var.alb-target-group-port
  protocol = var.alb-target-group-protocol
  vpc_id   = var.vpc-id
  target_type = "ip"

  health_check {
    enabled = true
    path = "/health"
    port = "traffic-port"
    protocol = "HTTP"

    healthy_threshold = 2
    unhealthy_threshold = 3

    timeout = 5
    interval = 30

    matcher = "200-399"
  }
}