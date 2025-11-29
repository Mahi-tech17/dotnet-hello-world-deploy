pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-cred')  
        DOCKER_IMAGE = 'helloworld-api'
        AWS_EC2_UAT = 'ec2-user@3.234.209.248'
        SSH_KEY = '/var/lib/jenkins/.ssh/id_rsa'
        DOCKERHUB_USER = 'mahi421'
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Mahi-tech17/dotnet-hello-world-deploy.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image..."
                    sh "docker build -t ${DOCKER_IMAGE}:latest ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    echo "Logging in to Docker Hub..."
                    sh """
                        echo ${DOCKERHUB_CREDENTIALS_PSW} | docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin
                        docker tag ${DOCKER_IMAGE}:latest ${DOCKERHUB_USER}/${DOCKER_IMAGE}:latest
                        docker push ${DOCKERHUB_USER}/${DOCKER_IMAGE}:latest
                    """
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {
                    echo "Deploying to EC2..."
                    sh """
                        ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ${AWS_EC2_UAT} '
                            docker pull ${DOCKERHUB_USER}/${DOCKER_IMAGE}:latest
                            docker stop ${DOCKER_IMAGE} || true
                            docker rm ${DOCKER_IMAGE} || true
                            docker run -d -p 8080:80 --name ${DOCKER_IMAGE} ${DOCKERHUB_USER}/${DOCKER_IMAGE}:latest
                        '
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Deployment Successful to ${params.ENV}!"
        }
        failure {
            echo "Deployment Failed!"
        }
    }
}
