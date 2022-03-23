pipeline {
    agent any

    try {
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
                    sh "chmod +x ./deploy.sh && ./deploy.sh"
                    
                }
            }
            stage('Email'){
                steps {
                    // Info via email
                    mail body: 'project build successful',
                        from: 'jenkins@test.com',
                        subject: 'project build successful',
                        to: 'alexandru.sava@acccesa.eu'
                }
            }

         }
    }
    catch (err){

        currentBuild.result = "FAILURE"

            mail body: "project build error is here: ${env.BUILD_URL}" ,
            from: 'jenkins@test.com',
            subject: 'project build failed',
            to: 'alexandru.sava@acccesa.eu'

        throw err
    }
}
