#!/usr/bin/env bash

if [ "$#" -ne 3 ]; then
    printf "Usage: $0 <profile> <region> <VPC>
    <profile>:   AWS profile name, as configured in AWS CLI
    <region>:    AWS region, e.g., 'ap-southeast-2'
    <VPC>:       VPC ID to launch resources in, e.g., vpc-061356a281e59shf33\n"
    exit 1
fi

timestamp=$(date +%s%3)

# Append timestamp to avoid conflicting bucket names
aws s3api create-bucket --bucket ut4-hub-maps-$timestamp --region $2
aws s3api create-bucket --bucket ut4-hub-files-$timestamp --region $2
aws cloudformation create-stack --template-url cloudformation/ut4-aws-hub.json --parameters VPCID=$3 --profile $1 --region $2
