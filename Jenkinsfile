pipeline {
    agent any

    environment {
        PATH = "${env.PATH}:/usr/local/bin" // Ensure Docker is in PATH
        DOCKER_LOGIN_SUCCESS = false
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/RomanNft/qwqaz.git'
            }
        }

        stage('Docker Login') {
            steps {
                script {
                    sh 'docker --version' // Check if Docker is available

                    withCredentials([usernamePassword(credentialsId: 'my_service_', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        sh '''
                            echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                            if [ $? -eq 0 ]; then
                                echo "Docker login successful"
                                env.DOCKER_LOGIN_SUCCESS = true
                            else
                                echo "Docker login failed"
                                env.DOCKER_LOGIN_SUCCESS = false
                            fi
                        '''
                    }
                }
            }
        }

        stage('Build and Push facebook-client') {
            when {
                expression { return env.DOCKER_LOGIN_SUCCESS.toBoolean() }
            }
            steps {
                script {
                    echo "DOCKER_LOGIN_SUCCESS: ${env.DOCKER_LOGIN_SUCCESS}"
                    sh 'docker build -t roman2447/facebook-client:latest ./facebook-client'
                    sh 'docker push roman2447/facebook-client:latest'
                }
            }
        }

        stage('Build and Push facebook-server') {
            when {
                expression { return env.DOCKER_LOGIN_SUCCESS.toBoolean() }
            }
            steps {
                script {
                    echo "DOCKER_LOGIN_SUCCESS: ${env.DOCKER_LOGIN_SUCCESS}"
                    sh 'docker build -t roman2447/facebook-server:latest ./facebook-server'
                    sh 'docker push roman2447/facebook-server:latest'
                }
            }
        }
    }

    post {
        failure {
            echo 'The build failed. Please check the logs for details.'
        }
    }
}
