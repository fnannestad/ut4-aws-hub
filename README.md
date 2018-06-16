# ut4-aws-hub
A project that builds and bootstraps an Unreal Tournament 4 hub in AWS.

## Setup
`./setup.sh <profile> <region> <VPC>`

## Why should I use this project?
You can run a hub for much cheaper on AWS than with a managed server provider. If your account has been created within the last 12 months, you are eligible for the AWS free tier. One of the benefits you get with this is the ability to run a t2.micro EC2 instance for free for a year. This should support a moderate sized UT4 hub (up to ~20 players simultaneously).

## Prerequisites
1. Existing AWS account with a non-default VPC
2. AWS CLI configured