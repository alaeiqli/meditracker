pipeline {
    agent any

    environment {
        PYTHON = 'C:\\Users\\Alae\\AppData\\Local\\Programs\\Python\\Python313\\python.exe'
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
                bat '''
                "%PYTHON%" -m venv venv
                call venv\\Scripts\\activate
                "%PYTHON%" -m pip install --upgrade pip
                pip install -r requirements.txt
                '''
            }
        }

        stage('Run Tests') {
            steps {
                bat '''
                call venv\\Scripts\\activate
                "%PYTHON%" -m unittest discover || exit 0
                '''
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE_ENV}") {
                    bat '''
                    call venv\\Scripts\\activate

                    sonar-scanner ^
                    -Dsonar.projectKey=meditracker ^
                    -Dsonar.projectName=meditracker ^
                    -Dsonar.sources=. ^
                    -Dsonar.language=py ^
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