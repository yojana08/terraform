# Flask-Express Single EC2 Terraform Deployment

This Terraform configuration deploys both a Flask backend and an Express frontend on a single EC2 instance in AWS.

## Architecture

- **Flask Backend**: Python Flask API running on EC2
- **Express Frontend**: Node.js Express server running on the same EC2 instance
- **Communication**: Frontend communicates with backend via localhost
- **Security**: Security group allows access to both Flask and Express ports

## Prerequisites

1. **AWS CLI configured** with appropriate credentials
2. **Terraform installed** (version >= 1.0)
3. **EC2 Key Pair created** in your target AWS region
4. **Git repository** with your application code


## Project Structure
.
├── main.tf                 # Main Terraform configuration
├── variables.tf            # Variable definitions
├── outputs.tf              # Output definitions
├── terraform.tfvars        # Variable values (customize this)
├── user_data.sh            # Instance initialization script (Flask + Express)
├── backend/
│   ├── app.py              # Flask application
│   └── requirements.txt    # Python dependencies
├── frontend/
│   ├── app.js              # Express application
│   └── package.json        # Node.js dependencies
└── README.md               # This file

## Quick Start

### 1. Clone and Setup

```bash
git clone https://github.com/yojana08/terraform.git
cd terraform
```

### 2. Configure Variables

Edit `terraform.tfvars`:

```hcl
aws_region    = "ap-south-1"          # Your preferred region
instance_type = "t2.micro"            # Instance size
key_name      = "your-key-pair-name"  # Your EC2 key pair
flask_port    = 5000                  # Flask backend port
express_port  = 3000                  # Express frontend port
```

### 3. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply changes
terraform apply
```

### 4. Access Applications

After deployment, Terraform will output the URLs:

- **Express Frontend**: `http://<express-public-ip>:3000`
- **Flask API**: `http://<flask-public-ip>:5000/api`


## Configuration Details

### Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `aws_region` | AWS region for deployment | `ap-south-1` | No |
| `instance_type` | EC2 instance type | `t2.micro` | No |
| `key_name` | EC2 key pair name | `arena-key` | Yes |
| `flask_port` | Flask backend port | `5000` | No |
| `express_port` | Express frontend port | `3000` | No |

### Security Groups

- **Flask SG**: Allows inbound traffic on Flask port (5000) and SSH (22)
- **Express SG**: Allows inbound traffic on Express port (3000) and SSH (22)
- **Inter-service**: Express can communicate with Flask on port 5000