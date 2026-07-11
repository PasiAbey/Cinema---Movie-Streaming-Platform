variable "alb-target-group-name" {
    description = "Name of the ALB target group"
    type        = string  
}

variable "alb-target-group-port" {
    description = "Port the desired container listens on"
    type        = number
}

variable "alb-target-group-protocol" {
    description = "Protocol for the ALB target group"
    type        = string
}

variable "vpc-id" {
    description = "ID of the VPC"
    type        = string
}