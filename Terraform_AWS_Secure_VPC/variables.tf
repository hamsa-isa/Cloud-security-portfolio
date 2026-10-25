variable "region" {
  description = "AWS region to build in"
  type        = string
  default     = "eu-west-2"
}

variable "project" {
  description = "Name prefix for all resources"
  type        = string
  default     = "hamsa-vpc-lab"
}

variable "vpc_cidr" {
  description = "IP range for the whole VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Public subnets: AZ letter = CIDR"
  type        = map(string)
  default = {
    a = "10.0.1.0/24"
    b = "10.0.2.0/24"
  }
}

variable "private_subnets" {
  description = "Private subnets: AZ letter = CIDR"
  type        = map(string)
  default = {
    a = "10.0.11.0/24"
    b = "10.0.12.0/24"
  }
}
