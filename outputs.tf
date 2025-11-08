# outputs.tf
output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.web_instance.id
}

output "public_ip" {
  description = "EC2 Public IP Address"
  value       = aws_instance.web_instance.public_ip
}
