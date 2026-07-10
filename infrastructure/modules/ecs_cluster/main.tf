resource "aws_ecs_cluster" "main-cluster" {
  name = var.ecs-cluster-name  
}