# Arena Docker App Deployment on AWS ECS

This repository contains a **Flask backend** and an **Express frontend** deployed on **AWS ECS** using **ECR**, **VPC**, and **Fargate**.  

---

**Tech Stack**

Backend: Python 3.8, Flask.
Frontend: Node.js 16, Express, EJS.
Containerization: Docker.
AWS: ECR, ECS Fargate, VPC, Security Groups, CloudWatch Logs.

## **Repository Structure**

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

**Steps to Deploy**

1️⃣ Dockerize Apps.

2️⃣ Build & Push Docker Images to ECR (Frontend & Backend).

3️⃣ Create ECS Cluster & Task Definitions
-Use Fargate launch type.
-Assign VPC & Subnets.
-Backend Task: port 8000.
-Frontend Task: port 3000, env BACKEND_URL=http://<backend-ip>:8000/api

4️⃣ Create ECS Services
-Backend: port 8000 open.
-Frontend: port 3000 open.

5️⃣ Test
-Backend: curl http://<backend-ip>:8000/api
-Frontend: http://<frontend-ip>:3000/