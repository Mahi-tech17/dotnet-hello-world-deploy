pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'helloworld-api'
        DOCKER_USER = 'mahi421'
        AWS_SERVER = 'ec2-user@3.234.209.248'
        SSH_KEY = '/var/lib/jenkins/.ssh/id_rsa'
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
                    sh "docker build -t ${DOCKER_IMAGE}:latest ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sh """
                            echo $PASSWORD | docker login -u $USERNAME --password-stdin
                            docker tag ${DOCKER_IMAGE}:latest ${DOCKER_USER}/${DOCKER_IMAGE}:latest
                            docker push ${DOCKER_USER}/${DOCKER_IMAGE}:latest
                        """
                    }
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {
                    sh """
                        ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ${AWS_SERVER} '
                            docker pull ${DOCKER_USER}/${DOCKER_IMAGE}:latest
                            docker stop ${DOCKER_IMAGE} || true
                            docker rm ${DOCKER_IMAGE} || true
                            docker run -d -p 8080:80 --name ${DOCKER_IMAGE} ${DOCKER_USER}/${DOCKER_IMAGE}:latest
                        '
                    """
                }
            }
        }
    }

    post {
        success { echo " Deployment Successful!" }
        failure { echo " Deployment Failed!" }
    }
}
