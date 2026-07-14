variable "alb-arn" {
    description = "ARN of the ALB"
    type        = string
}

variable "alb-port" {
    description = "Port for the ALB listener"
    type        = number
}

variable "alb-protocol" {
    description = "Protocol for the ALB listener"
    type        = string
}

variable "target-group-arn" {
    description = "ARN of the target group"
    type        = string
}
