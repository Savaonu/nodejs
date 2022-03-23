pipeline {
    agent any

    stages {
        stage('Fetch git'){
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
        stage('Build'){
            steps {
                // Build Image
                sh "docker build -t $image_name ."
                // sh "docker build ."

                // Create container
                sh "docker run -p 3000:3000 -d --name $container_name $image_name"
            }
        }
        stage('Deploy'){
            steps {
                // Push to DockerHub Repo
                withCredentials([usernamePassword(credentialsId: 'ae4a797f-6a03-4dc7-874f-c6683cc2fcba', passwordVariable: 'repo_passw', usernameVariable: 'repo_username')]) {
                    sh "chmod +x ./deploy.sh && ./deploy.sh ${repo_username} ${repo_passw}"
                 // some block
                }
            }
        }
        //stage('Email'){
        //    steps {
                // Info via email
        //        mail body: 'project build successful',
        //            from: 'jenkins@test.com',
        //            subject: 'project build successful',
        //            to: 'alexandru.sava@acccesa.eu'
        //    }
        //}

     }
}
