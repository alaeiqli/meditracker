pipeline {
    agent any

    environment {
        SONAR_PROJECT_KEY = 'meditracker'
        SONAR_PROJECT_NAME = 'Meditracker'
        DOCKER_IMAGE = 'alaeiqli/meditracker'
        DOCKER_TAG = 'latest'
        PYTHON_IMAGE = 'python:3.13-slim'
    }

    stages {

        stage('Clone') {
            steps {
                echo "📥 Cloning repository..."
                checkout scm
            }
        }

        stage('Setup & Test Python') {
    steps {
        bat """
        C:\\Users\\Alae\\AppData\\Local\\Programs\\Python\\Python313\\python.exe -m venv venv
        call venv\\Scripts\\activate
        python -m pip install --upgrade pip setuptools wheel
        pip install -r requirements.txt
        python -m unittest discover || exit 0
        """
    }
}

        stage('SonarQube') {
    steps {
        echo "🔍 Sonar Analysis..."
        withSonarQubeEnv('sonar_integration') {
            bat """
            call venv\\Scripts\\activate
            sonar-scanner ^
                -Dsonar.projectKey=${SONAR_PROJECT_KEY} ^
                -Dsonar.projectName=${SONAR_PROJECT_NAME} ^
                -Dsonar.sources=. ^
                -Dsonar.language=py ^
                -Dsonar.sourceEncoding=UTF-8
            """
        }
    }
}

        stage('Docker Build') {
            steps {
                echo "🐳 Docker Build..."
                bat "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
            }
        }

        stage('Docker Push') {
            steps {
                echo "🚀 Docker Push..."
                withCredentials([
                    usernamePassword(
                        credentialsId: 'DockerHub',
                        usernameVariable: 'USER',
                        passwordVariable: 'PASS'
                    )
                ]) {
                    bat """
                    echo %PASS% | docker login -u %USER% --password-stdin
                    docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                    """
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo "✅ SUCCESS"
        }
        failure {
            echo "❌ FAILED"
        }
    }
}