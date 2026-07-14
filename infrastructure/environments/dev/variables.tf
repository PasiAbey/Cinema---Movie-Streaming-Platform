variable "firebase-api-key" {
  description = "Firebase API Key"
  type        = string
  sensitive = true
}

variable "firebase-auth-domain" {
  description = "Firebase Auth Domain"
  type        = string
  sensitive = true

}

variable "firebase-project-id" {
  description = "Firebase Project ID"
  type        = string
  sensitive = true
}

variable "firebase-storage-bucket" {
  description = "Firebase Storage Bucket"
  type        = string
  sensitive = true
}

variable "firebase-messaging-sender-id" {
  description = "Firebase Messaging Sender ID"
  type        = string
  sensitive = true
}

variable "firebase-app-id" {
  description = "Firebase App ID"
  type        = string
  sensitive = true
}