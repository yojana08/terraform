variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
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

variable "key_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
  default     = "arena-key"
}

variable "flask_port" {
  description = "Port for Flask backend application"
  type        = number
  default     = 5000
  
  validation {
    condition     = var.flask_port > 1024 && var.flask_port < 65536
    error_message = "Flask port must be between 1024 and 65535."
  }
}

variable "express_port" {
  description = "Port for Express frontend application"
  type        = number
  default     = 3000
  
  validation {
    condition     = var.express_port > 1024 && var.express_port < 65536
    error_message = "Express port must be between 1024 and 65535."
  }
}