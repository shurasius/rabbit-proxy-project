pipeline {
    agent { label 'ubuntu' }

    stages {
        stage('Build') {
            steps {

                //script {
                //    currentBuild.displayName = "RabbitProxyProject-v1-${Version}"
                //}
                script {
                    if (params.Version == 'new') {
                            params.Version=env.BUILD_NUMBER
                    } 
                }
                
                git 'https://github.com/shurasius/rabbit-proxy-project.git'
                sh 'sudo chmod 755 create-or-update-stack.sh'
                sh 'tar -cf rabbit_artifact_1.${Version}.tar index.html images/'
                script{
                    try {
                        sh 'aws s3 cp rabbit_artifact_1.${Version}.tar s3://rabbit-builds-storage/rabbit_artifact_1.${Version}.tar'  
                    } catch (e) {
                        echo 'Something failed, I should sound the klaxons!' 
                    }
                }
                sh 'sudo cp rabbit_artifact_1.${Version}.tar /jbackup'
            }
        }
        stage('Deploy Dev') {
            steps {
                sh './create-or-update-stack.sh us-west-2 RabbitProxyProject-v1-${Version}-DEV --template-body file://rabbitt_project_optimized.yml --parameters ParameterKey=Environment,ParameterValue=1-${Version}-DEV ParameterKey=BuildVersion,ParameterValue=rabbit_artifact_1.${Version}.tar  ParameterKey=KeyName,ParameterValue=oregon_pair_1 ParameterKey=InstanceType,ParameterValue=t2.micro ParameterKey=SSHLocation,ParameterValue=0.0.0.0/0 ParameterKey=VPC,ParameterValue=vpc-8811e8f0 ParameterKey=Subnets,ParameterValue="subnet-2dd7f377\\,subnet-560a5f2f\\,subnet-f796e1bc" --capabilities CAPABILITY_NAMED_IAM'

                sh 'sleep 60'

                sh ''' export NGINXDNS=`aws cloudformation describe-stacks --region us-west-2 --stack-name RabbitProxyProject-v1-${Version}-DEV --query 'Stacks[0].Outputs[0].OutputValue' | cut -d'"' -f2`
                       set +e
                       export CVAR="`curl $NGINXDNS`" 
                       set -e
                       if [ -n "$CVAR" ]; then exit 0; else exit 1; fi
                '''
            }
        }
        stage('Deploy Prod') {
            steps {
                sh './create-or-update-stack.sh us-west-2 RabbitProxyProject-v1-${Version}-PROD --template-body file://rabbitt_project_optimized.yml --parameters ParameterKey=Environment,ParameterValue=1-${Version}-PROD ParameterKey=BuildVersion,ParameterValue=rabbit_artifact_1.${BUILD_NUMBER}.tar  ParameterKey=KeyName,ParameterValue=oregon_pair_1 ParameterKey=InstanceType,ParameterValue=t2.micro ParameterKey=SSHLocation,ParameterValue=0.0.0.0/0 ParameterKey=VPC,ParameterValue=vpc-8811e8f0 ParameterKey=Subnets,ParameterValue="subnet-2dd7f377\\,subnet-560a5f2f\\,subnet-f796e1bc" --capabilities CAPABILITY_NAMED_IAM'

                sh 'sleep 60'

                sh ''' export NGINXDNS=`aws cloudformation describe-stacks --region us-west-2 --stack-name RabbitProxyProject-v1-${Version}-PROD --query 'Stacks[0].Outputs[0].OutputValue' | cut -d'"' -f2`
                        set +e
                        export CVAR="`curl $NGINXDNS`" 
                        set -e 
                        if [ -n "$CVAR" ]; then exit 0; else exit 1; fi
                '''
            }
        }
    }
}
