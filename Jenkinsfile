pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS_ID = 'dockerhub-credentials'
        KUBECONFIG_ID            = 'kubeconfig'
        DOCKER_IMAGE_NAME        = "nandanajsreenivas/my-blue-green-app"
    }

    stages {
        stage('1. Checkout from Git') {
            steps {
                echo 'Checking out code from GitHub...'
                git 'https://github.com/nandana2123/jenkins-blue-green-lab.git' // e.g., 'https://github.com/user/repo.git'
            }
        }

        stage('2. Build & Push Docker Image') {
            steps {
                script {
                    echo "Building and pushing Docker image: ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"
                    docker.withRegistry('https://index.docker.io/v1/', DOCKERHUB_CREDENTIALS_ID) {
                        def img = docker.build("${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}", ".")
                        img.push()
                    }
                }
            }
        }

        stage('3. Blue-Green Deployment to Kubernetes') {
            steps {
                script {
                    withKubeConfig([credentialsId: KUBECONFIG_ID]) {
                        // --- 1. Determine current live color ---
                        echo "Checking live service color..."
                        def currentColor = sh(returnStdout: true, script: "kubectl get service my-app-service -o jsonpath='{.spec.selector.version}'").trim()
                        
                        // Handle initial deployment where service might not exist
                        if (!currentColor) {
                            echo "Service not found or no version set. Defaulting to blue."
                            sh 'kubectl apply -f service.yaml'
                            currentColor = 'blue'
                        }
                        
                        echo "Current live color is: ${currentColor}"
                        
                        // --- 2. Determine target deployment color ---
                        def targetColor = (currentColor == 'blue') ? 'green' : 'blue'
                        echo "Deploying new version to inactive color: ${targetColor}"

                        // --- 3. Deploy to the inactive environment ---
                        sh "kubectl apply -f deployment-${targetColor}.yaml"
                        sh "kubectl set image deployment/my-app-${targetColor} my-app-container=${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"
                        
                        echo "Waiting for ${targetColor} deployment to be ready..."
                        sh "kubectl rollout status deployment/my-app-${targetColor}"
                        
                        // --- 4. Switch service to the new color ---
                        echo "Switching live traffic to ${targetColor}"
                        sh "kubectl patch service my-app-service -p '{\"spec\":{\"selector\":{\"version\":\"${targetColor}\"}}}'"
                        
                        echo "Deployment successful! ${targetColor} is now live."
                    }
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}