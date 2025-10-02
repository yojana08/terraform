pipeline {
    agent any

    environment {
        // AWS Settings
        AWS_DEFAULT_REGION = 'ap-south-1'               
        AWS_CREDENTIALS = 'aws-jenkins-credentials'    // ID of AWS credentials in Jenkins

        // ECR Repositories
        ECR_BACKEND = '214863335760.dkr.ecr.ap-south-1.amazonaws.com/arena-backend'
        ECR_FRONTEND = '214863335760.dkr.ecr.ap-south-1.amazonaws.com/arena-frontend'

        // ECS Cluster and Services
        ECS_CLUSTER = 'arena-1'
        ECS_BACKEND_SERVICE = 'arena-backend-task-service'
        ECS_FRONTEND_SERVICE = 'arena-frontend-task-service'
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Cloning Git repository..."
                git branch: 'main', url: 'https://github.com/yojana08/aws.git'
            }
        }

        stage('Login to ECR') {
            steps {
                echo "Logging into AWS ECR..."
                withAWS(credentials: "${AWS_CREDENTIALS}", region: "${AWS_DEFAULT_REGION}") {
                    sh 'aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $ECR_BACKEND'
                    sh 'aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $ECR_FRONTEND'
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                echo "Building Docker images..."
                sh 'docker build -t arena-backend ./backend'   // Adjust path if needed
                sh 'docker build -t arena-frontend ./frontend' // Adjust path if needed
            }
        }

        stage('Tag & Push to ECR') {
            steps {
                echo "Tagging and pushing Docker images to ECR..."
                sh 'docker tag arena-backend:latest $ECR_BACKEND:latest'
                sh 'docker tag arena-frontend:latest $ECR_FRONTEND:latest'
                sh 'docker push $ECR_BACKEND:latest'
                sh 'docker push $ECR_FRONTEND:latest'
            }
        }

        stage('Deploy to ECS') {
            steps {
                echo "Deploying new images to ECS..."
                withAWS(credentials: "${AWS_CREDENTIALS}", region: "${AWS_DEFAULT_REGION}") {
                    sh '''
                    aws ecs update-service --cluster $ECS_CLUSTER --service $ECS_BACKEND_SERVICE --force-new-deployment
                    aws ecs update-service --cluster $ECS_CLUSTER --service $ECS_FRONTEND_SERVICE --force-new-deployment
                    '''
                }
            }
        }
    }

    post {
        success { echo 'CI/CD pipeline completed successfully!' }
        failure { echo 'Pipeline failed. Check Jenkins logs.' }
    }
}


