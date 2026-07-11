variable "alb-name" {
  description = "Name of the ALB"
  type        = string
}

variable "security-group-id" {
  description = "Security group ID for the ALB"
  type        = string
}

variable "public-subnet-01-id" {
  description = "The ID of the first public subnet"
  type        = string
}

variable "public-subnet-02-id" {
  description = "The ID of the second public subnet"
  type        = string
}