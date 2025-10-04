# Flask-Express Application Deployment on AWS ECS

Complete guide for deploying a Flask backend and Express frontend application using Docker containers on AWS ECS with Terraform infrastructure as code.

### Infrastructure Components

- **VPC**: Custom VPC with public and private subnets across 2 availability zones
- **ECR**: Two repositories for storing backend and frontend Docker images
- **ECS Fargate**: Serverless container orchestration
- **Application Load Balancer**: Routes traffic to frontend and backend services
- **NAT Gateways**: Enable private subnets to access the internet
- **Security Groups**: Network-level security controls
- **CloudWatch**: Centralized logging for containers

### Traffic Flow

```
Internet → ALB → Frontend (Port 3000)
              → Backend (Port 5000)
                ↓
             Names API
```

## ✅ Prerequisites

### Required Tools

1. **AWS CLI** (v2.x or later)
2. **Terraform** (v1.0 or later)
3. **Docker** (v20.x or later)


### AWS Setup

1. **Create IAM User** with these permissions:
   - AmazonEC2FullAccess
   - AmazonECS_FullAccess
   - AmazonVPCFullAccess
   - AmazonEC2ContainerRegistryFullAccess
   - ElasticLoadBalancingFullAccess
   - IAMFullAccess
   - CloudWatchLogsFullAccess

2. **Configure AWS Credentials**

3. **Verify Configuration**:
   ```bash
   aws sts get-caller-identity
   ```

## 📁 Project Structure

```
terraform/
├── backend/                          
│   ├── Dockerfile                    
│   ├── app.py                        
│   ├── business.py                 
│   ├── names.txt                     
│   ├── requirements.txt            
│   └── templates/
│       └── index.html              
│
├── frontend/                       
│   ├── Dockerfile                   
│   ├── app.js                       
│   ├── package.json                  
│   ├── package-lock.json             
│   └── views/
│       └── index.ejs                
│
├── terraform/                        
│   ├── main.tf                      
│   ├── variables.tf                  
│   ├── outputs.tf                
│   ├── vpc.tf                        
│   ├── ecr.tf           
│   ├── ecs.tf                     
│   ├── alb.tf                
│   └── security_groups.tf  
│   └── README.md     
└── deploy.sh                                        

```

## Quick Start

### 1. Clone and Setup

```bash
# Navigate to your project directory
cd your-project

# Make scripts executable
chmod +x deploy-only.sh 
```

### 2. Deploy Infrastructure

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

Type `yes` when prompted to confirm.

### 3. Deploy Application Containers

```bash
cd ..
./deploy-docker-only.sh
```

### 4. Access Your Application

The script will output URLs like:
```
Application URLs:
  Frontend: http://flask-express-app-alb-123456789.us-east-1.elb.amazonaws.com
  Backend API: http://flask-express-app-alb-123456789.us-east-1.elb.amazonaws.com/api
  Backend Health: http://flask-express-app-alb-123456789.us-east-1.elb.amazonaws.com/health
```

## 📊 Monitoring and Troubleshooting

### View Container Logs

#### Real-time logs:
```bash
# Backend logs
aws logs tail /ecs/flask-express-app-backend --follow --region us-east-1

# Frontend logs
aws logs tail /ecs/flask-express-app-frontend --follow --region us-east-1
```

#### Recent logs:
```bash
# Last 10 minutes of backend logs
aws logs tail /ecs/flask-express-app-backend --since 10m --region us-east-1

# Last hour of frontend logs
aws logs tail /ecs/flask-express-app-frontend --since 1h --region us-east-1
```
