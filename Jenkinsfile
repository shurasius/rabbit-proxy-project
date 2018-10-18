pipeline {
    agent none 

    stages {
        stage('Build') {
            agent { label 'ubuntu' }
            steps {
                git 'https://github.com/shurasius/rabbit-proxy-project.git'
                sh 'sudo chmod 755 create-or-update-stack.sh'
                sh 'tar -cf rabbit_artifact_1.${BUILD_NUMBER}.tar index.html images/'
                script{
                    try {
                        sh 'aws s3 cp rabbit_artifact_1.${BUILD_NUMBER}.tar s3://rabbit-builds-storage/rabbit_artifact_1.${BUILD_NUMBER}.tar'  
                    } catch (e) {
                        echo 'Something failed, I should sound the klaxons!' 
                    }
                }
                sh 'sudo cp rabbit_artifact_1.${BUILD_NUMBER}.tar /jbackup'

                 agent { label 'ubuntu' }
           
                sh './create-or-update-stack.sh us-west-2 RabbitProxyProject-v1-${BUILD_NUMBER} --template-body file://rabbitt_project_optimized.yml --parameters ParameterKey=BuildVersion,ParameterValue=rabbit_artifact_1.${BUILD_NUMBER}.tar  ParameterKey=KeyName,ParameterValue=oregon_pair_1 ParameterKey=InstanceType,ParameterValue=t2.micro ParameterKey=SSHLocation,ParameterValue=0.0.0.0/0 ParameterKey=VPC,ParameterValue=vpc-8811e8f0 ParameterKey=Subnets,ParameterValue="subnet-2dd7f377\\,subnet-560a5f2f\\,subnet-f796e1bc" --capabilities CAPABILITY_NAMED_IAM'

                  sh ''' export NGINXDNS=`aws cloudformation describe-stacks --stack-name rabbit-nginx-dev --query 'Stacks[0].Outputs[0].OutputValue' | cut -d'"' -f2`
                   echo $NGINXDNS 
                   if [[ `curl $NGINXDNS` && `curl $NGINXDNS/rabbit-mgmt` ]]; then exit 0; else exit 1; fi
                '''

                sh 'aws cloudformation delete-stack --region us-west-2  --stack-name RabbitProxyProject-v1-${BUILD_NUMBER}'
           
        }
        
        stage('Deploy Prod') {
            agent { label 'redhat'}
            steps {
                sh './create-or-update-stack.sh us-west-2 RabbitProxyProject-v1-${BUILD_NUMBER} --template-body file://rabbitt_project_optimized.yml --parameters ParameterKey=BuildVersion,ParameterValue=rabbit_artifact_1.${BUILD_NUMBER}.tar  ParameterKey=KeyName,ParameterValue=oregon_pair_1 ParameterKey=InstanceType,ParameterValue=t2.micro ParameterKey=SSHLocation,ParameterValue=0.0.0.0/0 ParameterKey=VPC,ParameterValue=vpc-8811e8f0 ParameterKey=Subnets,ParameterValue="subnet-2dd7f377\\,subnet-560a5f2f\\,subnet-f796e1bc" --capabilities CAPABILITY_NAMED_IAM'

                  sh ''' export NGINXDNS=`aws cloudformation describe-stacks --stack-name rabbit-nginx-dev --query 'Stacks[0].Outputs[0].OutputValue' | cut -d'"' -f2`
                   echo $NGINXDNS 
                   if [[ `curl $NGINXDNS` && `curl $NGINXDNS/rabbit-mgmt` ]]; then exit 0; else exit 1; fi
                '''

                sh 'aws cloudformation delete-stack --region us-west-2  --stack-name RabbitProxyProject-v1-${BUILD_NUMBER}'

            }
        }
    }
}
