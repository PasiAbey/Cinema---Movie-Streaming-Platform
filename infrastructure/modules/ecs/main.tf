resource "aws_ecs_cluster" "main-cluster" {
  name = var.ecs-cluster-name  
}


resource "aws_ecs_task_definition" "task-definition" {
  family                   = var.ecs-task-family-name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu-size
  memory                   = var.memory-size

  task_role_arn = data.aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "cinema-frontend"
      image     = "578209356011.dkr.ecr.eu-north-1.amazonaws.com/cinema_frontend:2d67c7f256cdbf4ffdc31de020ec0b43c56e41f7"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
  
}