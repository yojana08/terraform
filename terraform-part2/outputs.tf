# Flask Backend Outputs
output "flask_instance_id" {
  description = "Flask EC2 Instance ID"
  value       = aws_instance.flask_backend.id
}

output "flask_instance_public_ip" {
  description = "Flask Instance Public IP"
  value       = aws_instance.flask_backend.public_ip
}

output "flask_instance_private_ip" {
  description = "Flask Instance Private IP"
  value       = aws_instance.flask_backend.private_ip
}

output "flask_instance_public_dns" {
  description = "Flask Instance Public DNS"
  value       = aws_instance.flask_backend.public_dns
}

output "flask_api_url" {
  description = "Flask API URL"
  value       = "http://${aws_instance.flask_backend.public_ip}:${var.flask_port}/api"
}

# Express Frontend Outputs
output "express_instance_id" {
  description = "Express EC2 Instance ID"
  value       = aws_instance.express_frontend.id
}

output "express_instance_public_ip" {
  description = "Express Instance Public IP"
  value       = aws_instance.express_frontend.public_ip
}

output "express_instance_private_ip" {
  description = "Express Instance Private IP"
  value       = aws_instance.express_frontend.private_ip
}

output "express_instance_public_dns" {
  description = "Express Instance Public DNS"
  value       = aws_instance.express_frontend.public_dns
}

output "express_application_url" {
  description = "Express Frontend URL"
  value       = "http://${aws_instance.express_frontend.public_ip}:${var.express_port}"
}

# Summary Output
output "deployment_summary" {
  description = "Summary of deployed applications"
  value = {
    flask_backend = {
      instance_id  = aws_instance.flask_backend.id
      public_ip    = aws_instance.flask_backend.public_ip
      private_ip   = aws_instance.flask_backend.private_ip
      api_url      = "http://${aws_instance.flask_backend.public_ip}:${var.flask_port}/api"
    }
    express_frontend = {
      instance_id = aws_instance.express_frontend.id
      public_ip   = aws_instance.express_frontend.public_ip
      private_ip  = aws_instance.express_frontend.private_ip
      app_url     = "http://${aws_instance.express_frontend.public_ip}:${var.express_port}"
    }
  }
}
