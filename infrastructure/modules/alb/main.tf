resource "aws_alb" "alb" {
  name               = var.alb-name
  internal           = false
  security_groups    = [var.security-group-id]
  subnets            = [var.public-subnet-01-id, var.public-subnet-02-id]
  load_balancer_type = "application"

  tags = {
    Name = var.alb-name
  }
}