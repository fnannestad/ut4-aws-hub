#!/usr/bin/env bash

if [ "$#" -ne 3 ]; then
    printf "Usage: $0 <profile> <region> <VPC>
    <profile>:   AWS profile name, as configured in AWS CLI
    <region>:    AWS region, e.g., 'ap-southeast-2'
    <VPC>:       VPC ID to launch resources in, e.g., vpc-061356a281e59shf33\n"
    exit 1
fi

# Defaults
CURRENT_TIME=$(date +%s%3)
AVAILABILIY_ZONE="ap-southeast-2a"
PRIVATE_BUCKET="ut4-hub-config"
AMI="ami-0c24c2b222474a63b"
VPC=""
INSTANCE_TYPE="t2.micro"
CONFIG_BUCKET_NAME="ut4-aws-hub-config-$CURRENT_TIME"
FILES_BUCKET_NAME="ut4-aws-hub-files-$CURRENT_TIME"
SUBNET="subnet-0e00ca65cad0745c6"

sed -e s/#AVAILABILITY_ZONE#/$AVAILABILITY_ZONE/g \
    -e s/#CONFIG_BUCKET#/$CONFIG_BUCKET/g \
    -e s/#AMI#/$AMI/g \
    -e s/#VPC#/$VPC/g \
    -e s/#INSTANCE_TYPE#/$INSTANCE_TYPE/g \
    -e s/#CONFIG_BUCKET_NAME#/$CONFIG_BUCKET_NAME/g \
    -e s/#FILES_BUCKET_NAME#/$FILES_BUCKET_NAME/g \
    ut4-aws-hub-params.json > ut4-aws-hub-params-run.json 

# Append CURRENT_TIME to avoid conflicting bucket names
aws s3api create-bucket --bucket ut4-hub-maps-$CURRENT_TIME --region $2
aws s3api create-bucket --bucket ut4-hub-files-$CURRENT_TIME --region $2
aws cloudformation create-stack \
    --template-body file://cloudformation/ut4-aws-hub.json \
    --parameters file://cloudformation/ut4-aws-hub-params-run.json \
    --profile $1 --region $2
