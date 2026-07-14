variable "secret-name" {
  description = "Name of the secret"
  type        = string
  sensitive   = true
}

variable "secret-value" {
  description = "Value of the secret"
  type        = string
  sensitive   = true
}