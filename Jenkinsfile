pipeline {
    agent {
        docker {
            image 'python:3.13-slim'   // image officielle Python Linux
            args '-u root:root'        // pour pouvoir installer des packages
        }
    }

    environment {
        SONARQUBE_ENV = 'SonarQubeServer'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Setup Python') {
            steps {
                sh '''
                python -m venv venv
                . venv/bin/activate
                python -m pip install --upgrade pip setuptools wheel
                pip install -r requirements.txt
                '''
            }
        }

        stage('Run Tests') {
            steps {
                sh '''
                . venv/bin/activate
                python -m unittest discover || true
                '''
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE_ENV}") {
                    sh '''
                    . venv/bin/activate
                    sonar-scanner \
                        -Dsonar.projectKey=meditracker \
                        -Dsonar.projectName=meditracker \
                        -Dsonar.sources=. \
                        -Dsonar.language=py \
                        -Dsonar.sourceEncoding=UTF-8
                    '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build') {
            steps {
                echo "Build terminé ✅"
            }
        }
    }

    post {
        success {
            echo "Pipeline réussi 🎉"
        }

        failure {
            echo "Pipeline échoué ❌"
        }
    }
}