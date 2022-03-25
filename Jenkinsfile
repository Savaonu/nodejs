pipeline {
    environment {
        image_name = "nodejs"
        container_name = "my_nodejs_app"
        dockerhub_image = "savaonu/${image_name}"
        prod_srv = "192.168.0.17"
    }
    agent {
            label "lin_node"
        }

    stages {
        stage('Fetch git'){
            steps {
                // Get some code from a GitHub repository
                git 'https://github.com/Savaonu/nodejs'

                    }
        } 
        stage('Cleanup old Containers'){
            steps {
                // Clean old containers
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
                }
            }
        }
        stage('Deploy to prod'){
            steps {
                // Transfer the image to prod env 
                
                withCredentials([usernamePassword(credentialsId: 'prod_user', passwordVariable: 'prod_passw', usernameVariable: 'prod_user')]) {
                    // Clean old containers
                    sh "sshpass -p ${prod_passw} ssh -o StrictHostKeyChecking=no ${prod_user}@${prod_srv} \"bash -s\" < ./cleanup.sh"
                    // Transfer a copy of the image to prod
                    sh "docker save ${image_name} | gzip| sshpass -p ${prod_passw} ssh ${prod_user}@${prod_srv} docker load"
                    // Start app on prod
                    sh "sshpass -p ${prod_passw} ssh -o StrictHostKeyChecking=no ${prod_user}@${prod_srv} docker run -p 3000:3000 -d --name ${container_name} ${image_name}"
                }
                

            }
        }
        stage('Parallel win/lin jobs') {
            parallel {   
                stage('Clean image pushed to Dockerhub'){
                    steps {
                        // Delete the image pushed to Dockehub
                        sh "docker rmi --force ${dockerhub_image}"
                    }
                }
                stage('Email'){
                    agent {
                        label "win_node"
                    }
                    steps {
                        // Info via email
                        emailext body: "<b>Project build successful</b><br>Project: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br> URL de build: ${env.BUILD_URL}", charset: 'UTF-8', from: 'jenkins@test.com', mimeType: 'text/html', replyTo: '', subject: "Successful CI: Project name -> ${env.JOB_NAME}", to: "alexandru.sava@accesa.eu";
                    }
                }
            }
        }

     }
     post {
         failed {
                // Info via email about failed job
            sendEmail("Failed"); 
         }
        unsuccessful {  
              // Info via email about unsuccessful job 
             sendEmail("Unsuccessful");  
        } 
    }
 }
 def sendEmail(status) {
    mail(
            to: "$EMAIL_RECIPIENTS",
            subject: "Build $BUILD_NUMBER - " + status + " (${currentBuild.fullDisplayName})",
            body: "Changes:\n " + getChangeString() + "\n\n Check console output at: $BUILD_URL/console" + "\n")
            mail body: "<b>Project build failed</b><br>Project: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br> URL de build: ${env.BUILD_URL}", charset: 'UTF-8', from: 'jenkins@test.com', mimeType: 'text/html', replyTo: '', subject: "FAILED CI: Project name -> ${env.JOB_NAME}", to: "alexandru.sava@accesa.eu";
