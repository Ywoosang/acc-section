variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_id" {
  description = "ID of the public subnet"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the bastion EC2 instance"
  type        = string
}

variable "key_name" {
  description = "Name of the key pair"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "instance_type" {
  description = "Bastion EC2 Instance Type"
  type        = string
}