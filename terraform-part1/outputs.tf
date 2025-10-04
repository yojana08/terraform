

output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.flask_express.id
}

output "instance_public_ip" {
  description = "EC2 Instance Public IP"
  value       = aws_instance.flask_express.public_ip
}

output "instance_public_dns" {
  description = "EC2 Instance Public DNS"
  value       = aws_instance.flask_express.public_dns
}

output "express_application_url" {
  description = "Express Frontend URL"
  value       = "http://${aws_instance.flask_express.public_ip}:${var.express_port}"
}

output "flask_api_url" {
  description = "Flask API URL"
  value       = "http://${aws_instance.flask_express.public_ip}:${var.flask_port}/api"
}
