variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "vpc-name" {
    description = "Name of the VPC"
    type = string
}




variable "availability-zone-01" {
  description = "The availability zone for the first subnet"
  type        = string
}

variable "public-subnet-01-cidr-block" {
  description = "The CIDR block for the AZ 01 public subnet"
  type        = string
}

variable "public-subnet-01-name" {
  description = "The name for the AZ 01 public subnet"
  type        = string
}

variable "private-subnet-01-cidr-block" {
  description = "The CIDR block for the AZ 01 private subnet"
  type        = string
}

variable "private-subnet-01-name" {
  description = "The name for the AZ 01 private subnet"
  type        = string
}





variable "availability-zone-02" {
  description = "The availability zone for the second subnet"
  type        = string
}

variable "public-subnet-02-cidr-block" {
  description = "The CIDR block for the Z 02 public subnet"
  type        = string
}

variable "public-subnet-02-name" {
  description = "The name for the AZ 02 public subnet"
  type        = string
}

variable "private-subnet-02-cidr-block" {
  description = "The CIDR block for the AZ 02 private subnet"
  type        = string
}

variable "private-subnet-02-name" {
  description = "The name for the AZ 02 private subnet"
  type        = string
}