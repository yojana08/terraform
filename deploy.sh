#!/bin/bash

# Deploy script for Docker images only (without Terraform)
# Run this AFTER Terraform infrastructure is already deployed

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
AWS_REGION=${AWS_REGION:-ap-south-1}
PROJECT_NAME=${PROJECT_NAME:-flask-express-app}
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# ECR Repository URLs
BACKEND_ECR_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PROJECT_NAME}-backend"
FRONTEND_ECR_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PROJECT_NAME}-frontend"

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}Deploying Docker Images to AWS ECS${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""
echo -e "${BLUE}Configuration:${NC}"
echo -e "  AWS Region: ${YELLOW}${AWS_REGION}${NC}"
echo -e "  AWS Account ID: ${YELLOW}${AWS_ACCOUNT_ID}${NC}"
echo -e "  Project Name: ${YELLOW}${PROJECT_NAME}${NC}"
echo -e "  Backend ECR: ${YELLOW}${BACKEND_ECR_URL}${NC}"
echo -e "  Frontend ECR: ${YELLOW}${FRONTEND_ECR_URL}${NC}"
echo ""

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}Error: AWS CLI is not installed${NC}"
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed${NC}"
    exit 1
fi

# Check if AWS credentials are configured
echo -e "${YELLOW}Checking AWS credentials...${NC}"
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}Error: AWS credentials are not configured${NC}"
    echo -e "${YELLOW}Run: aws configure${NC}"
    exit 1
fi
echo -e "${GREEN}✓ AWS credentials verified${NC}"
echo ""

# Check if ECR repositories exist
echo -e "${YELLOW}Checking ECR repositories...${NC}"
if ! aws ecr describe-repositories --repository-names ${PROJECT_NAME}-backend --region ${AWS_REGION} &> /dev/null; then
    echo -e "${RED}Error: Backend ECR repository does not exist${NC}"
    echo -e "${YELLOW}Please run Terraform first to create the infrastructure${NC}"
    exit 1
fi

if ! aws ecr describe-repositories --repository-names ${PROJECT_NAME}-frontend --region ${AWS_REGION} &> /dev/null; then
    echo -e "${RED}Error: Frontend ECR repository does not exist${NC}"
    echo -e "${YELLOW}Please run Terraform first to create the infrastructure${NC}"
    exit 1
fi
echo -e "${GREEN}✓ ECR repositories found${NC}"
echo ""

# Check if ECS cluster exists
echo -e "${YELLOW}Checking ECS cluster...${NC}"
if ! aws ecs describe-clusters --clusters ${PROJECT_NAME}-cluster --region ${AWS_REGION} --query 'clusters[0].status' --output text 2>/dev/null | grep -q "ACTIVE"; then
    echo -e "${RED}Error: ECS cluster does not exist or is not active${NC}"
    echo -e "${YELLOW}Please run Terraform first to create the infrastructure${NC}"
    exit 1
fi
echo -e "${GREEN}✓ ECS cluster is active${NC}"
echo ""

# Step 1: Login to ECR
echo -e "${YELLOW}Step 1: Logging into Amazon ECR...${NC}"
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to login to ECR${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Successfully logged into ECR${NC}"
echo ""

# Step 2: Build and Push Backend Docker Image
echo -e "${YELLOW}Step 2: Building Backend Docker image...${NC}"
cd backend

if [ ! -f "Dockerfile" ]; then
    echo -e "${RED}Error: Dockerfile not found in backend directory${NC}"
    exit 1
fi

docker build -t ${PROJECT_NAME}-backend:latest .

if [ $? -ne 0 ]; then
    echo -e "${RED}Backend Docker build failed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Backend image built successfully${NC}"

echo -e "${YELLOW}Tagging Backend image...${NC}"
docker tag ${PROJECT_NAME}-backend:latest ${BACKEND_ECR_URL}:latest
docker tag ${PROJECT_NAME}-backend:latest ${BACKEND_ECR_URL}:$(date +%Y%m%d-%H%M%S)

echo -e "${YELLOW}Pushing Backend image to ECR...${NC}"
docker push ${BACKEND_ECR_URL}:latest

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to push backend image to ECR${NC}"
    exit 1
fi

docker push ${BACKEND_ECR_URL}:$(date +%Y%m%d-%H%M%S) 2>/dev/null

echo -e "${GREEN}✓ Backend image pushed to ECR successfully${NC}"
cd ..
echo ""

# Step 3: Build and Push Frontend Docker Image
echo -e "${YELLOW}Step 3: Building Frontend Docker image...${NC}"
cd frontend

if [ ! -f "Dockerfile" ]; then
    echo -e "${RED}Error: Dockerfile not found in frontend directory${NC}"
    exit 1
fi

docker build -t ${PROJECT_NAME}-frontend:latest .

if [ $? -ne 0 ]; then
    echo -e "${RED}Frontend Docker build failed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Frontend image built successfully${NC}"

echo -e "${YELLOW}Tagging Frontend image...${NC}"
docker tag ${PROJECT_NAME}-frontend:latest ${FRONTEND_ECR_URL}:latest
docker tag ${PROJECT_NAME}-frontend:latest ${FRONTEND_ECR_URL}:$(date +%Y%m%d-%H%M%S)

echo -e "${YELLOW}Pushing Frontend image to ECR...${NC}"
docker push ${FRONTEND_ECR_URL}:latest

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to push frontend image to ECR${NC}"
    exit 1
fi

docker push ${FRONTEND_ECR_URL}:$(date +%Y%m%d-%H%M%S) 2>/dev/null

echo -e "${GREEN}✓ Frontend image pushed to ECR successfully${NC}"
cd ..
echo ""

# Step 4: Update ECS Services
echo -e "${YELLOW}Step 4: Updating ECS services...${NC}"

echo -e "${YELLOW}Updating Backend service...${NC}"
aws ecs update-service \
    --cluster ${PROJECT_NAME}-cluster \
    --service ${PROJECT_NAME}-backend-service \
    --force-new-deployment \
    --region ${AWS_REGION} > /dev/null

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to update backend service${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Backend service update initiated${NC}"

echo -e "${YELLOW}Updating Frontend service...${NC}"
aws ecs update-service \
    --cluster ${PROJECT_NAME}-cluster \
    --service ${PROJECT_NAME}-frontend-service \
    --force-new-deployment \
    --region ${AWS_REGION} > /dev/null

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to update frontend service${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Frontend service update initiated${NC}"
echo ""

# Step 5: Wait for services to stabilize (optional)
echo -e "${YELLOW}Step 5: Waiting for services to stabilize...${NC}"
echo -e "${BLUE}This may take 3-5 minutes. Press Ctrl+C to skip waiting.${NC}"
echo ""

aws ecs wait services-stable \
    --cluster ${PROJECT_NAME}-cluster \
    --services ${PROJECT_NAME}-backend-service ${PROJECT_NAME}-frontend-service \
    --region ${AWS_REGION}

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Services are stable and running${NC}"
else
    echo -e "${YELLOW}⚠ Wait timed out or was interrupted. Services may still be deploying.${NC}"
fi
echo ""

# Step 6: Get Application URL
echo -e "${YELLOW}Step 6: Getting Application URL...${NC}"
ALB_DNS=$(aws elbv2 describe-load-balancers \
    --names ${PROJECT_NAME}-alb \
    --region ${AWS_REGION} \
    --query 'LoadBalancers[0].DNSName' \
    --output text 2>/dev/null)

if [ ! -z "$ALB_DNS" ] && [ "$ALB_DNS" != "None" ]; then
    ALB_URL="http://${ALB_DNS}"
else
    ALB_URL="Unable to retrieve URL"
fi

echo ""
echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}Deployment Complete!${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""
echo -e "${GREEN}Application URLs:${NC}"
echo -e "  Frontend: ${BLUE}${ALB_URL}${NC}"
echo -e "  Backend API: ${BLUE}${ALB_URL}/api${NC}"
echo -e "  Backend Health: ${BLUE}${ALB_URL}/health${NC}"
echo ""
echo -e "${YELLOW}Note: It may take 1-2 minutes for the new containers to become healthy.${NC}"
echo ""
echo -e "${BLUE}Useful commands:${NC}"
echo -e "  View backend logs: ${YELLOW}aws logs tail /ecs/${PROJECT_NAME}-backend --follow${NC}"
echo -e "  View frontend logs: ${YELLOW}aws logs tail /ecs/${PROJECT_NAME}-frontend --follow${NC}"
echo -e "  Check service status: ${YELLOW}aws ecs describe-services --cluster ${PROJECT_NAME}-cluster --services ${PROJECT_NAME}-backend-service${NC}"
echo ""