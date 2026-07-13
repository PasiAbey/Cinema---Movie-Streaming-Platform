# Task Definition Variables

variable "ecs-task-family-name" {
  description = "The family name for the ECS task definition"
  type        = string
}

variable "cpu-size" {
  description = "The CPU size for the ECS task definition"
  type        = string
  default = "256"
}

variable "memory-size" {
  description = "The memory size for the ECS task definition"
  type        = string
  default = "512"
}

variable "container-port" {
  description = "The port on which the container will listen"
  type        = number
  default     = 80
}

variable "container-environment-variables" {
  description = "A list of environment variables for the container"
  type        = list(object({
    name  = string
    value = string
  }))
  default     = []
}






# Service Variables

variable "ecs-service-name" {
  description = "The name of the ECS service"
  type        = string
}

variable "ecs-cluster-id" {
  description = "The ID of the ECS cluster"
  type        = string
}

variable "desired-count" {
  description = "The desired number of tasks for the ECS service"
  type        = number
  default     = 1
}

variable "public-subnet-01-id" {
  description = "The ID of the first public subnet"
  type        = string
}

variable "public-subnet-02-id" {
  description = "The ID of the second public subnet"
  type        = string
}

variable "security-group-id" {
  description = "The ID of the security group for the ECS service"
  type        = string
}

variable "alb_tar_grp_arn" {
  description = "The ARN of the ALB target group"
  type        = string
  default     = null
}