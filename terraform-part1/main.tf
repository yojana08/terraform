terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Get latest Ubuntu 20.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# Security Group
resource "aws_security_group" "app_sg" {
  name_prefix = "flask-express-sg-"
  description = "Security group for Flask-Express application"

  # Express frontend port (main application access)
  ingress {
    description = "Express Frontend"
    from_port   = var.express_port
    to_port     = var.express_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Flask backend port (for direct API access)
  ingress {
    description = "Flask Backend API"
    from_port   = var.flask_port
    to_port     = var.flask_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict this to your IP for better security
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "flask-express-security-group"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# EC2 Instance
resource "aws_instance" "flask_express" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  # User data script
  user_data = file("${path.module}/user_data.sh")

  # Ensure the instance has enough time to initialize
  user_data_replace_on_change = true

  tags = {
    Name        = "flask-express-app"
    Environment = "development"
    Project     = "flask-express-deployment"
  }
}