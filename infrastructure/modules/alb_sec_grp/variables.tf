variable "sg-name" {
  description = "Name of the security group"
  type        = string
}

variable "vpc-id" {
  description = "ID of the VPC"
  type        = string
}

variable "alb-port" {
  description = "Port for the ALB"
  type        = number
}