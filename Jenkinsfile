pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-cred') // Add in Jenkins
        AWS_CREDENTIALS = credentials('aws-cred') // Add in Jenkins
    }

    parameters {
        choice(name: 'ENV', choices: ['UAT', 'PROD'], description: 'Select Deployment Environment')
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/YOUR_GITHUB_ACCOUNT/dotnet-hello-world.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("yourdockerhubusername/hello-world-api:${params.ENV}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'DOCKER_HUB_CREDENTIALS') {
                        dockerImage.push()
                    }
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {
                    def ec2_ip = params.ENV == 'UAT' ? 'UAT_EC2_IP' : 'PROD_EC2_IP'
                    def ssh_user = 'ec2-user' // or your user

                    sh """
                    ssh -o StrictHostKeyChecking=no ${ssh_user}@${ec2_ip} '
                        docker pull yourdockerhubusername/hello-world-api:${params.ENV}
                        docker stop hello-world-api || true
                        docker rm hello-world-api || true
                        docker run -d -p 5000:5000 --name hello-world-api yourdockerhubusername/hello-world-api:${params.ENV}
                    '
                    """
                }
            }
        }
    }
}


