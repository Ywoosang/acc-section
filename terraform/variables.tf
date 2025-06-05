variable "key_name" {
  type        = string
}

variable "ami_id" {
  type        = string
}

variable "ecr_repository_name" {
  type        = string
}

variable "bastion_instance_type" {
  type = string
}

variable "app_instance_type" {
  type = string
}

variable "monitoring_instance_type" {
  type = string
}

variable "name_prefix" {
  type        = string
} 