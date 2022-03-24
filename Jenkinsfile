pipeline {
    environment {
        image_name = "nodejs"
        container_name = "my_nodejs_app"
        dockerhub_image = "savaonu/${image_name}"
        prod_srv = "192.168.0.17"
    }
    agent any

    stages {
        stage('Fetch git'){
            steps {
                // Get some code from a GitHub repository
                git 'https://github.com/Savaonu/nodejs'

                    }
        } 
        stage('Cleanup old Containers'){
            steps {
                // Clean old images
                sh "chmod +x ./cleanup.sh && ./cleanup.sh "
                
            }
        }
        stage('Build Docker image and create container'){
            steps {
                // Build Image
                sh "docker build -t ${image_name} ."
                // sh "docker build ."

                // Create container
                sh "docker run -p 3000:3000 -d --name ${container_name} ${image_name}"
            }
        }
        stage('Deploy to Dockerhub'){
            steps {
                // Push to Dockerhub repo
                withCredentials([usernamePassword(credentialsId: 'ae4a797f-6a03-4dc7-874f-c6683cc2fcba', passwordVariable: 'repo_passw', usernameVariable: 'repo_username')]) {
                    sh "chmod +x ./deploy.sh && sh -x ./deploy.sh ${repo_username} ${repo_passw} ${image_name} ${dockerhub_image}"
                 // some block
                }
            }
        }
        stage('Deploy to prod'){
            steps {
                // Transfer the image to prod env 
                
                withCredentials([usernamePassword(credentialsId: 'prod_user', passwordVariable: 'prod_passw', usernameVariable: 'prod_user')]) {
                    sh " echo ${prod_user} ${prod_passw} "
                    sh "sshpass -p ${prod_passw} ssh -o StrictHostKeyChecking=no ${prod_user}@${prod_srv} \"bash -s\" < ./cleanup.sh"
                    sh "docker save ${image_name} | gzip| sshpass -p ${prod_passw} ssh ${prod_user}@${prod_srv} docker load"
                    sh "sshpass -p ${prod_passw} ssh -o StrictHostKeyChecking=no ${prod_user}@${prod_srv} docker run -p 3000:3000 -d --name ${container_name} ${image_name}"
                }
                

            }
        }
        stage('Parallel test') {
            parallel {   
                stage('Email'){
                    steps {
                        // Info via email
                    mail body: 'project build successful',
                            from: 'jenkins@test.com',
                        subject: 'project build successful',
                            to: 'alexandru.sava@accesa.eu'
                    }
                }
                stage('Clean image pushed to Dockerhub'){
                    steps {
                        // Delete the image pushed to Dockehub
                        sh "docker rmi --force ${dockerhub_image}"
                    }
                }
            }
        }

     }
}
