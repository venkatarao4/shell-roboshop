#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0f5a4423ccb46e300" #replace with you security group id 

for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-0f5a4423ccb46e300 --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=test}]' --query 'Instances[0].InstanceId' --output text)


    if [ $instance != "frontend" ]; then 
        IP=$(aws ec2 describe-instances --instance-ids i-047b13611cebb9fb4 --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
    else
        IP=$(aws ec2 describe-instances --instance-ids i-047b13611cebb9fb4 --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    fi

    echo "$instance: $IP"
done