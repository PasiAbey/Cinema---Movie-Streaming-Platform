variable "ecs-cluster-name" {
  description = "The name of the ECS cluster"
  type        = string  
}

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



