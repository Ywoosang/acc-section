variable "name_prefix" {
  description = "Prefix for naming AWS resources"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_id" {
  description = "Subnet ID to launch the monitoring instance into"
  type        = string
}

variable "bastion_sg_id" {
  description = "Security group ID of the bastion host"
  type        = string
}

variable "backend_sg_id" {
  description = "Security group ID of backend EC2 (for allowing Promtail push)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for monitoring server"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for the monitoring EC2 instance"
  type        = string
} 