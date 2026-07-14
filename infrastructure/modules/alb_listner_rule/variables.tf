variable "alb_listener-arn" {
  description = "ARN of the ALB listener"
  type        = string
}

variable "priority" {
  description = "Priority of the listener rule"
  type        = number
}

variable "target-group-arn" {
  description = "ARN of the target group"
  type        = string
}

variable "path-pattern" {
  description = "Path pattern for the listener rule"
  type        = list(string)
}