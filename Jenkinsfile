pipeline {
    agent { label 'ubuntu'} 
    stages {
        stage('Build') {
            steps {
                git 'https://github.com/shurasius/rabbit-proxy-project.git'
                sh 'tar -cf rabbit_artifact_${BUILD_NUMBER}.tar index.html images/'
                script{
                    try {
                        sh 'aws s3 cp rabbit_artifact_${BUILD_NUMBER}.tar s3://rabbit-project-storage/rabbit_artifact_${BUILD_NUMBER}.tar'  
                    } catch (e) {
                        echo 'Something failed, I should sound the klaxons!' 
                    }
                }
                sh 'sudo cp rabbit_artifact_${BUILD_NUMBER}.tar /jbackup'
            }
        }
    }
}