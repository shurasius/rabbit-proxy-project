pipeline {
    agent { label 'redhat'} 

    stages {
        stage('Build') {
            steps {
                git 'https://github.com/shurasius/rabbit-proxy-project.git'
                sh 'tar -cf rabbit_artifact_1.${BUILD_NUMBER}.tar index.html images/'
                script{
                    try {
                        sh 'aws s3 cp rabbit_artifact_1.${BUILD_NUMBER}.tar s3://rabbit-builds-storage/rabbit_artifact_1.${BUILD_NUMBER}.tar'  
                    } catch (e) {
                        echo 'Something failed, I should sound the klaxons!' 
                    }
                }
                sh 'sudo cp rabbit_artifact_1.${BUILD_NUMBER}.tar /jbackup'
            }
        }
        stage('Deploy Dev') {
            steps {
                sh 'sh create-or-update-stack.sh'
            }
        }
    }
}
