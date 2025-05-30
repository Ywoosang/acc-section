output "backend_asg_name" {
  value = aws_autoscaling_group.backend.name
}

output "asg_name" {
  value = aws_autoscaling_group.backend.name
}