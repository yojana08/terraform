# Flask-Express Multi-Instance Terraform Deployment

This Terraform configuration deploys a Flask backend and Express frontend on separate EC2 instances in AWS.

## Architecture

- **Flask Backend**: Python Flask API running on a dedicated EC2 instance
- **Express Frontend**: Node.js Express server running on a separate EC2 instance
- **Communication**: Express frontend communicates with Flask backend via private IP
- **Security**: Proper security groups for inter-service communication

## Prerequisites

1. **AWS CLI configured** with appropriate credentials
2. **Terraform installed** (version >= 1.0)
3. **EC2 Key Pair created** in your target AWS region
4. **Git repository** with your application code

## Project Structure

```
.
├── main.tf                 # Main Terraform configuration
├── variables.tf            # Variable definitions
├── outputs.tf             # Output definitions
├── terraform.tfvars       # Variable values (customize this)
├── user_data/
│   ├── flask.sh           # Flask instance initialization script
│   └── express.sh         # Express instance initialization script
├── backend/
│   ├── app.py             # Flask application
│   └── requirements.txt   # Python dependencies
├── frontend/
│   ├── app.js             # Express application
│   └── package.json       # Node.js dependencies
└── README.md              # This file
```

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

### Networking

- **VPC**: 10.0.0.0/16
- **Subnet**: 10.0.1.0/24 (public subnet)
- **Internet Gateway**: For public access
- **Route Table**: Routes traffic to internet gateway

## Application Details

### Flask Backend (`backend/app.py`)

**Endpoints:**
- `GET /api` - API root information

### Express Frontend (`frontend/app.js`)

### Check Instance Status

```bash
# Get deployment information
terraform output

# SSH into instances
ssh -i your-key.pem ubuntu@<public-ip>
```

### View Application Logs

**Flask logs:**
```bash
ssh -i your-key.pem ubuntu@<flask-public-ip>
sudo tail -f /var/log/user-data.log
cd /home/ubuntu/terraform/backend && tail -f flask.log
```

**Express logs:**
```bash
ssh -i your-key.pem ubuntu@<express-public-ip>
sudo tail -f /var/log/user-data.log
cd /home/ubuntu/terraform/frontend && tail -f express.log
```

## Troubleshooting

### Common Issues

1. **Key Pair Not Found**
   - Ensure the key pair exists in your target region
   - Update `key_name` in `terraform.tfvars`

2. **Applications Not Starting**
   - Check user data logs: `sudo tail -f /var/log/user-data.log`
   - Verify security groups allow required ports

3. **Express Can't Connect to Flask**
   - Ensure Flask instance is running and healthy
   - Check security group rules for inter-instance communication

4. **Permission Errors**
   - Ensure your AWS credentials have necessary permissions
   - Check IAM policies for EC2, VPC operations

### Verification Steps

1. **Infrastructure**: `terraform plan` should show no changes after apply
2. **Flask Health**: `curl http://<flask-ip>:5000/health`
3. **Express Health**: `curl http://<express-ip>:3000/health`
4. **End-to-end**: Open Express frontend URL in browser

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

## Security Considerations

- Security groups are configured for development/testing
- For production, consider:
  - Using private subnets for backend
  - Implementing Application Load Balancer
  - Using AWS Systems Manager for instance access
  - Enabling VPC Flow Logs
  - Using AWS Certificate Manager for HTTPS

