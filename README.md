# Arena Docker App Deployment on AWS ECS

This repository contains a **Flask backend** and an **Express frontend** deployed on **AWS ECS** using **ECR**, **VPC**, and **Fargate**.

---

## **Tech Stack**

- **Backend**: Python 3.8, Flask
- **Frontend**: Node.js 16, Express, EJS
- **Containerization**: Docker
- **AWS Services**: ECR, ECS Fargate, VPC, Security Groups, CloudWatch Logs

---

## **Repository Structure**

```
arena-dockerapp/
├── backend/
│   ├── app.py
│   ├── business.py
│   ├── requirements.txt
│   ├── Dockerfile
│   ├── names.txt
│   └── templates/
├── frontend/
│   ├── app.js
│   ├── package.json
│   ├── package-lock.json
│   ├── Dockerfile
│   └── views/
│       └── index.ejs
├── docker-compose.yaml
├── README.md
└── .gitignore
```

---

## **Deployment Steps**

### **1️⃣ Dockerize Applications**

Ensure both backend and frontend have their respective `Dockerfile` configurations ready for containerization.

### **2️⃣ Build & Push Docker Images to ECR**

Build and push both frontend and backend Docker images to Amazon Elastic Container Registry (ECR).

**Backend:**
```bash
aws ecr create-repository --repository-name arena-backend
docker build -t arena-backend ./backend
docker tag arena-backend:latest <aws-account-id>.dkr.ecr.<region>.amazonaws.com/arena-backend:latest
docker push <aws-account-id>.dkr.ecr.<region>.amazonaws.com/arena-backend:latest
```

**Frontend:**
```bash
aws ecr create-repository --repository-name arena-frontend
docker build -t arena-frontend ./frontend
docker tag arena-frontend:latest <aws-account-id>.dkr.ecr.<region>.amazonaws.com/arena-frontend:latest
docker push <aws-account-id>.dkr.ecr.<region>.amazonaws.com/arena-frontend:latest
```

### **3️⃣ Create ECS Cluster & Task Definitions**

- Use **Fargate** launch type
- Assign **VPC** & **Subnets**
- **Backend Task**: Expose port `8000`
- **Frontend Task**: Expose port `3000`
  - Set environment variable: `BACKEND_URL=http://<backend-ip>:8000/api`

Create task definitions via AWS Console or CLI with the appropriate container images from ECR.

### **4️⃣ Create ECS Services**

**Backend Service:**
- Port `8000` open
- Configure security group to allow inbound traffic on port 8000

**Frontend Service:**
- Port `3000` open
- Configure security group to allow inbound traffic on port 3000
- Ensure `BACKEND_URL` environment variable points to backend service

### **5️⃣ Test the Deployment**

**Backend Health Check:**
```bash
curl http://<backend-ip>:8000/api
```

**Frontend Access:**
```
http://<frontend-ip>:3000/
```

---

## **Notes**

- Ensure your AWS credentials are configured properly
- Security groups must allow the required ports (3000 for frontend, 8000 for backend)
- Use CloudWatch Logs for monitoring application logs
- For production deployments, consider using Application Load Balancers (ALB) for better traffic management

---

## **Prerequisites**

- AWS Account with appropriate permissions
- AWS CLI installed and configured
- Docker installed locally
- Basic understanding of AWS ECS, ECR, and VPC

