variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_id" {
  description = "ID of the public subnet for NAT Gateway"
  type        = string
}

variable "private_a_id" {
  description = "ID of the private subnet in AZ A"
  type        = string
}

variable "private_c_id" {
  description = "ID of the private subnet in AZ C"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
} 