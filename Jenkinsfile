pipeline {
    agent any
    
    stages {
        stage('Clone repository') {
            steps {
                git branch: 'main', url: 'https://github.com/RomanNft/qwqaz'
            }
        }

        stage('Build Docker Containers') {
            steps {
                // Build all images including the db
                sh 'docker-compose build --no-cache migration'
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
                
                // Очікування на успішне завершення контейнера migration
                script {
                    timeout(time: 5, unit: 'MINUTES') {
                        waitUntil {
                            def migrationStatus = sh(script: 'docker inspect --format="{{.State.Status}}" facebook-migration-1', returnStdout: true).trim()
                            return migrationStatus == 'exited'
                        }
                        def migrationExitCode = sh(script: 'docker inspect --format="{{.State.ExitCode}}" facebook-migration-1', returnStdout: true).trim()
                        if (migrationExitCode != '0') {
                            echo "Migration container failed with exit code ${migrationExitCode}"
                            // Продовжуємо виконання, навіть якщо контейнер завершився з помилкою
                        }
                    }
                }
            }
        }

        stage('Push Docker Images') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'my_service_', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    script {
                        sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                        // Push each image explicitly
                        sh 'docker push roman2447/facebook-client:latest'
                        sh 'docker push roman2447/facebook-server:latest'
                        sh 'docker push roman2447/db-facebook:latest'
                        sh 'docker push roman2447/migration:latest'
                    }
                }
            }
        }

        stage('Clean Up') {
            steps {
                sh 'docker-compose down'
            }
        }
    }
}
