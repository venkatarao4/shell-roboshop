#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0f5a4423ccb46e300" #replace with you security group id 
ZONE_ID="Z0358867T36L0L2AAO3E"
DOMAIN_NMAE="venkatr.fun"

for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)


    if [ $instance != "frontend" ]; then 
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
        RECORD_NAME="$instance.$DOMAIN_NMAE" #mongodb.venkatr.fun

    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    fi

    echo "$instance: $IP"
    
    # Creates route 53 records based on env name

    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Testing creating a record set"
        ,"Changes": [{
         "Action"              : "CREATE"
        ,"ResourceRecordSet"  : {
         "Name"              : "'$RECORD_NAME'"
         ,"Type"             : "A"
         ,"TTL"              : 1
            ,"ResourceRecords"  : [{
            "Value"         : "'$IP'"
            }]
        }
        }]
    }
    '
done