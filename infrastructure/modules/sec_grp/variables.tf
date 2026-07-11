variable "sg-name" {
  description = "Name of the security group"
  type        = string
}

variable "vpc-id" {
  description = "ID of the VPC"
  type        = string
}

variable "security-group-id" {
  description = "ID of the security group to allow access from"
  type        = string
}

variable "container-port" {
  description = "Port on which the container is listening"
  type        = number
}