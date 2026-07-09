variable "repository_name" {
  description = "The name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "The mutability of the ECR repository images"
  type        = string
}

variable "scan_on_push" {
  description = "Whether to scan images on push"
  type        = bool
}
