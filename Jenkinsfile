pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                // Get some code from a GitHub repository
                git 'https://github.com/Savaonu/nodejs'

                // Clean old images
                sh "chmod +x ./cleanup.sh && ./cleanup.sh "
                
            }
        }
        stage('Deploy') {
            steps {
                // Build Image
                sh "docker build -t $image_name ."
                // sh "docker build ."

                // Create container
                sh "docker run -p 3000:3000 --name $container_name $image_name"
            }
        }
    }
}
