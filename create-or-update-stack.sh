#!/usr/bin/env bash

usage="Usage: $(basename "$0") us-west-2 RabbitProject --template-body file://rabbitt_project_optimized.yml --parameters ParameterKey=BuildVersion,ParameterValue=rabbit_artifact_1.${BUILD_NUMBER}.tar  ParameterKey=KeyName,ParameterValue=oregon_pair_1 ParameterKey=InstanceType,ParameterValue=t2.micro ParameterKey=SSHLocation,ParameterValue=0.0.0.0/0 ParameterKey=VPC,ParameterValue=vpc-8811e8f0 ParameterKey=Subnets,ParameterValue="subnet-2dd7f377\\,subnet-560a5f2f\\,subnet-f796e1bc" --capabilities CAPABILITY_NAMED_IAM
where:
  region       - the AWS region
  stack-name   - the stack name
  aws-cli-opts - extra options passed directly to create-stack/update-stack
"

if [ "$1" == "-h" ] || [ "$1" == "--help" ] || [ "$1" == "help" ] || [ "$1" == "usage" ] ; then
  echo "$usage"
  exit -1
fi

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] ; then
  echo "$usage"
  exit -1
fi

shopt -s failglob
set -eu -o pipefail

echo "Checking if stack exists ..."

if ! aws cloudformation describe-stacks --region $1 --stack-name $2 ; then

  echo -e "\nStack does not exist, creating ..."
  aws cloudformation create-stack \
    --region $1 \
    --stack-name $2 \
    ${@:3}

  echo "Waiting for stack to be created ..."
  aws cloudformation wait stack-create-complete \
    --region $1 \
    --stack-name $2 \

else

  echo -e "\nStack exists, attempting update ..."

  set +e
  update_output=$( aws cloudformation update-stack \
    --region $1 \
    --stack-name $2 \
    ${@:3}  2>&1)
  status=$?
  set -e

  echo "$update_output"

  if [ $status -ne 0 ] ; then

    # Don't fail for no-op update
    if [[ $update_output == *"ValidationError"* && $update_output == *"No updates"* ]] ; then
      echo -e "\nFinished create/update - no updates to be performed"
      exit 0
    else
      exit $status
    fi

  fi

  echo "Waiting for stack update to complete ..."
  aws cloudformation wait stack-update-complete \
    --region $1 \
    --stack-name $2 \

fi

echo "Finished create/update successfully!"