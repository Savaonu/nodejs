pipeline {
    environment {
        DOCKER_HUB_CRED = credentials('ae4a797f-6a03-4dc7-874f-c6683cc2fcba')
    }
    parameters {
        string(name: 'image_name', defaultValue: 'nodejs', description: 'Name of the image')
        string(name: 'container_name', defaultValue: 'my_nodejs_app', description: 'Name of the container')
        string(name: 'prod_srv', defaultValue: '192.168.0.17', description: "Productive environment")

    }
    agent {
            label "lin_node"
        }

    stages {
        stage('Fetch git'){
            steps {
                // Get code from GitHub repository
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
                sh "docker build -t ${params.image_name} ."
                // sh "docker build ."

                // Create container
                sh "docker run -p 3000:3000 -d --name ${params.container_name} ${params.image_name}"
            }
        }
        stage('Deploy to Dockerhub'){
            steps {
                script {
                    try {
                        // Push to Dockerhub repo
                        withCredentials([usernamePassword(credentialsId: 'ae4a797f-6a03-4dc7-874f-c6683cc2fcba', passwordVariable: 'repo_passw', usernameVariable: 'repo_username')]) {
                            sh "chmod +x ./deploy.sh && sh -x ./deploy.sh ${repo_username} ${repo_passw} ${params.image_name} ${repo_username}/${params.image_name}"
                            echo "Deployed successfully on Dockerhub"
                        } 
                     } 
                    catch(error) {
                        retry(2) {
                            echo "Retry deploy"
                            // Push to Dockerhub repo
                            withCredentials([usernamePassword(credentialsId: 'ae4a797f-6a03-4dc7-874f-c6683cc2fcba', passwordVariable: 'repo_passw', usernameVariable: 'repo_username')]) {
                            sh "chmod +x ./deploy.sh && sh -x ./deploy.sh ${repo_username} ${repo_passw} ${params.image_name} ${repo_username}/${params.image_name}"
                            }

                        }
                        echo "Deploy failed"
                        //currentBuild.result = 'FAILURE'

                        }
                    }
                }
                
            }
            post {
                failure {
                     // Info 
                    echo "Deployed failed after retries also"
                  }


            }
            
        }
        stage('Deploy to prod'){
            steps {
                // Transfer the image to prod env 
                withCredentials([usernamePassword(credentialsId: 'prod_user', passwordVariable: 'prod_passw', usernameVariable: 'prod_user')]) {
                    // Clean old containers
                    sh "sshpass -p ${prod_passw} ssh -o StrictHostKeyChecking=no ${prod_user}@${params.prod_srv} \"bash -s\" < ./cleanup.sh"
                    // Copy the image to 'prod'
                    sh "docker save ${params.image_name} | gzip| sshpass -p ${prod_passw} ssh ${prod_user}@${params.prod_srv} docker load"
                    // Start app on 'prod'
                    sh "sshpass -p ${prod_passw} ssh -o StrictHostKeyChecking=no ${prod_user}@${params.prod_srv} docker run -p 3000:3000 -d --name ${params.container_name} ${params.image_name}"
                }
                

            }
        }
        
        stage('Check containers') {
            parallel {
                stage('Check containers test ') {
                    steps {
                        script {
                            sh "docker ps -f status=running  -f name=my_nodejs_app | wc -l > docker_running"
                            result = readFile('docker_running').trim()
                            int res = result as int
                            if (res == 2) {
                                println "The nodejs container is up and running"
                            }
                            else if (res > 2) {
                                println "ERROR: please the env. There are more containers running "
                                currentBuild.result = 'FAILED'
                            }
                            else {
                                println "ERROR: the container is not running"
                                currentBuild.result = 'FAILED'
                            }
                        }

                    }
                }
            
        
                
                stage('Check containers prod') {
                    steps {
                        script {
                            withCredentials([usernamePassword(credentialsId: 'prod_user', passwordVariable: 'prod_passw', usernameVariable: 'prod_user')]) {
                                // Clean old containers
                                sh "\$(sshpass -p ${prod_passw} ssh -o StrictHostKeyChecking=no ${prod_user}@${params.prod_srv} docker ps -f status=running  -f name=my_nodejs_app | wc -l > docker_running_prod)"
                                result = readFile('docker_running_prod').trim()
                                int res = result as int
                                if (res == 2) {
                                    println "The nodejs container is up and running"
                                }
                                else if (res > 2) {
                                    println "ERROR: please the env. There are more containers running "
                                    currentBuild.result = 'FAILED'
                                }
                                else {
                                    println "ERROR: the container is not running"
                                    currentBuild.result = 'FAILED'
                            }
                            }
                        }

                    }
                }
            }
        }
        
        stage('Parallel win/lin jobs') {
            parallel {   
                stage('Clean image pushed to Dockerhub'){
                    steps {
                        // Delete the image pushed to Dockehub
                        sh "docker rmi --force ${DOCKER_HUB_CRED_USR}/${params.image_name}"
                    }
                }
                stage('Email'){
                    agent {
                        // Run on windows node 
                        label "win_node"
                    }
                    steps {
                        // Info via email from windows node
                        emailext body: "<b>Project build successful</b><br>Project: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br> URL de build: ${env.BUILD_URL}", from: 'jenkins@test.com', mimeType: 'text/html', replyTo: '', subject: "SUCCESSFUL CI: Project name -> ${env.JOB_NAME}", to: "alexandru.sava@accesa.eu";
                    }
                }
            }
        }

     }
     post {
         failure {
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
    mail body: "<b>Project build </b>" + "<b>$status</b>"   + "<br>Project: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br> URL de build: ${env.BUILD_URL}", charset: 'UTF-8', from: 'jenkins@test.com', mimeType: 'text/html', replyTo: '', subject: status + "  CI: Project name -> ${env.JOB_NAME}", to: "alexandru.sava@accesa.eu";
} 