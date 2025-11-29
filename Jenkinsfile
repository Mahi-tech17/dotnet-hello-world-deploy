pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-cred')  
        DOCKER_IMAGE = 'helloworld-api'
        AWS_EC2_UAT = 'ec2-user@3.234.209.248'
        SSH_KEY = '/var/lib/jenkins/.ssh/id_rsa' 
    }

    parameters {
        choice(name: 'ENV', choices: ['UAT'], description: 'Select Deployment Environment')
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
                    docker.build("${DOCKER_IMAGE}:latest")
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-cred') {
                        docker.image("${DOCKER_IMAGE}:latest").push()
                    }
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {
                    def ec2_target = AWS_EC2_UAT
                    sh """
                    ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ${ec2_target} '
                        docker pull mahi421/${DOCKER_IMAGE}:latest
                        docker stop ${DOCKER_IMAGE} || true
                        docker rm ${DOCKER_IMAGE} || true
                        docker run -d -p 8080:80 --name ${DOCKER_IMAGE} mahi421/${DOCKER_IMAGE}:latest
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
