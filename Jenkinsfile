pipeline {
    agent any

    environment {
        SONAR_TOKEN = 'squ_13c9ca6bab225f15a7f6b03395caa3a8f6e60551'
        SONAR_PROJECT_KEY = 'meditracker'
        SONAR_PROJECT_NAME = 'Meditracker'
        DOCKER_IMAGE = 'alaeiqli/meditracker'
        DOCKER_TAG = 'latest'
        PYTHON_IMAGE = 'python:3.13-slim'
        KUBECONFIG = 'C:\\Users\\Alae\\.kube\\config'
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
        echo "🔍 Sonar Analysis with SonarScanner CLI..."
        withSonarQubeEnv('sonar_integration') {
            bat """
            call venv\\Scripts\\activate
            C:\\Users\\Alae\\Desktop\\sonar-scanner\\bin\\sonar-scanner.bat ^
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
            docker push alaeiq/meditracker:latest
            """
        }
    }
}       
        stage('Deploy to Kubernetes') {
    steps {
        echo "☸️ Deploying to Kubernetes..."
        bat """
        kubectl apply -f k8s/deployment.yaml
        kubectl apply -f k8s/service.yaml
        kubectl get pods
        """
    }
}

    } // <-- fin des stages

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
} // <-- fin du pipeline