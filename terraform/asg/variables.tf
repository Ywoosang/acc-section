variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name for EC2 instances"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the backend security group"
  type        = string
}

variable "bastion_sg_id" {
  description = "Security group ID of the bastion host"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the ASG"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ARN of the ALB target group"
  type        = string
}

variable "ecr_repository_url" {
  description = "URL of the ECR repository"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "monitoring_instance_private_ip" {
  description = "Private IP address of the monitoring instance"
  type        = string
} 