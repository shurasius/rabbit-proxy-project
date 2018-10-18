pipeline {
    agent { label 'ubuntu'} 

    environment {
        
        BUILD_VERSION = '37'
    }

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
        stage('Deploy Dev') {
            steps {
                sh 'sudo aws cloudformation create-stack --region us-west-2  --stack-name RabbitProxyProject_v${BUILD_NUMBER} --template-body file://rabbitt_project_optimized.yml --parameters ParameterKey=BuildVersion,ParameterValue=rabbit_artifact_${BUILD_NUMBER}.tar  ParameterKey=KeyName,ParameterValue=oregon_pair_1 ParameterKey=InstanceType,ParameterValue=t2.micro ParameterKey=SSHLocation,ParameterValue=0.0.0.0/0 ParameterKey=VPC,ParameterValue=vpc-8811e8f0 ParameterKey=Subnets,ParameterValue="subnet-2dd7f377\\,subnet-560a5f2f\\,subnet-f796e1bc" --capabilities CAPABILITY_NAMED_IAM'
            }
        }
    }
}