output "private_ip" {
  description = "Private IP address of the monitoring instance"
  value       = aws_instance.monitoring.private_ip
}

output "security_group_id" {
  value = aws_security_group.monitoring.id
}