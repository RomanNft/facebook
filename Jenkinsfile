pipeline {
    agent any

    stages {
        stage('Clone repository') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Containers') {
            steps {
                // Build all images including the db
                sh 'docker-compose build'
            }
        }

        stage('List Docker Images') {
            steps {
                sh 'docker images'
            }
        }

        stage('Run Containers') {
            steps {
                sh 'docker-compose up -d'
            }
        }

        stage('Push Docker Images') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'my_service_', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    script {
                        sh 'docker login -u $DOCKER_USER -p $DOCKER_PASS'
                        sh 'docker push roman2447/facebook-client:latest'
                        sh 'docker push roman2447/facebook-server:latest'
                        sh 'docker push roman2447/db-facebook:latest'
                    }
                }
            }
        }

        stage('Clean Up') {
            steps {
                sh 'docker-compose down'
                sh 'docker system prune -f'
            }
        }
    }

    post {
        failure {
            echo 'Pipeline failed, cleaning up...'
            sh 'docker-compose down || true'
            sh 'docker system prune -f || true'
        }
    }
}
