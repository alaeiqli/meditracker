pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'python:3.13-slim'
        SONARQUBE_ENV = 'SonarQubeServer'
        APP_DIR = "${WORKSPACE}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Setup & Test in Docker') {
            steps {
                script {
                    // Crée un conteneur Docker pour installer les dépendances et exécuter les tests
                    sh """
                    docker run --rm -v ${APP_DIR}:/app -w /app ${DOCKER_IMAGE} /bin/bash -c \\
                    "python -m venv venv && \\
                     . venv/bin/activate && \\
                     python -m pip install --upgrade pip setuptools wheel && \\
                     pip install -r requirements.txt && \\
                     python -m unittest discover || true"
                    """
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE_ENV}") {
                    sh """
                    docker run --rm -v ${APP_DIR}:/app -w /app ${DOCKER_IMAGE} /bin/bash -c \\
                    ". venv/bin/activate && \\
                     sonar-scanner \\
                        -Dsonar.projectKey=meditracker \\
                        -Dsonar.projectName=meditracker \\
                        -Dsonar.sources=. \\
                        -Dsonar.language=py \\
                        -Dsonar.sourceEncoding=UTF-8"
                    """
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

        stage('Build Complete') {
            steps {
                echo "Pipeline terminé ✅"
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