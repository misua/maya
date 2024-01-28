#!/bin/bash

set -e

SPOT_FLEET_REQUEST_ID=$1
TARGET_GROUP_ARN=$2

echo "Spot Fleet Request ID: $SPOT_FLEET_REQUEST_ID"
echo "Target Group ARN: $TARGET_GROUP_ARN"

INSTANCE_IDS=$(aws ec2 describe-spot-fleet-instances --spot-fleet-request-id $SPOT_FLEET_REQUEST_ID --query 'ActiveInstances[*].InstanceId' --output text | awk '{print "Id="$1}')

echo "Instance IDs: $INSTANCE_IDS"

for ID in $INSTANCE_IDS
do
  echo "Waiting for instance $ID to be in a running state"
  aws ec2 wait instance-running --instance-ids ${ID#*=}
done

echo "Registering targets"
aws elbv2 register-targets --target-group-arn $TARGET_GROUP_ARN --targets $INSTANCE_IDS