pipeline {
    agent any

    stages {
        stage('Fetch git') {
            steps {
                // Get some code from a GitHub repository
                git 'https://github.com/Savaonu/nodejs'

                    }
        } 
        stage('Cleanup'){
            steps {
                // Clean old images
                sh "chmod +x ./cleanup.sh && ./cleanup.sh "
                
            }
        }
        stage('Build') {
            steps {
                // Build Image
                sh "docker build -t $image_name ."
                // sh "docker build ."

                // Create container
                sh "docker run -p 3000:3000 -d --name $container_name $image_name"
            }
        }
        stage('Deploy') {
            steps {

                //sh "echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_ID" --password-stdin"
                sh "echo "tatabanilor123" | docker login -u "savaonu" --password-stdin"
                sh "docker tag nodejs_image:latest savaonu/nodejs"
                sh "savaonu/nodejs"
                // Push to DockerHub Repo
            }
        }
    }
}
