# Create a Task Definition
resource "aws_ecs_task_definition" "task-definition" {
  family                   = var.ecs-task-family-name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu-size
  memory                   = var.memory-size

  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "${var.ecs-task-family-name}-container"
      image     = "nginx:latest"
      essential = true
      portMappings = [
        {
          containerPort = var.container-port
          hostPort      = var.container-port
        }
      ]

      environment = var.container-environment-variables
    }
  ])
  
}


# Create a Service
resource "aws_ecs_service" "ecs-service" {
  name            = var.ecs-service-name
  cluster         = var.ecs-cluster-id
  task_definition = aws_ecs_task_definition.task-definition.arn
  desired_count   = var.desired-count
  launch_type     = "FARGATE"
  availability_zone_rebalancing = "ENABLED"

  network_configuration {
    subnets          = [var.public-subnet-01-id, var.public-subnet-02-id]
    security_groups  = [var.security-group-id]
    assign_public_ip = true
  }
  
  load_balancer {
    target_group_arn = var.alb_tar_grp_arn
    container_name   = "${var.ecs-task-family-name}-container"
    container_port   = var.container-port
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
  
}