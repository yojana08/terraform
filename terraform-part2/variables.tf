# AWS region for deployment
variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "ap-south-1"
}

# EC2 instance type for both Flask and Express servers
variable "instance_type" {
  description = "EC2 instance type to use for deployment"
  type        = string
  default     = "t2.micro"

  validation {
    condition = contains([
      "t2.nano", "t2.micro", "t2.small", "t2.medium",
      "t3.nano", "t3.micro", "t3.small", "t3.medium"
    ], var.instance_type)
    error_message = "Instance type must be a valid t2 or t3 instance type."
  }
}

# SSH Key Pair for EC2 access
variable "key_name" {
  description = "Name of the existing EC2 Key Pair for SSH access"
  type        = string
  default     = "arena-key"
}

# Flask backend port
variable "flask_port" {
  description = "Port where Flask backend application will run"
  type        = number
  default     = 5000

  validation {
    condition     = var.flask_port > 0 && var.flask_port < 65536
    error_message = "Flask port must be between 1 and 65535."
  }
}

# Express frontend port
variable "express_port" {
  description = "Port where Express frontend application will run"
  type        = number
  default     = 3000

  validation {
    condition     = var.express_port > 0 && var.express_port < 65536
    error_message = "Express port must be between 1 and 65535."
  }
}
