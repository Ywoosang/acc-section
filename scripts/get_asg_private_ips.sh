#!/bin/bash

# ASG 이름을 환경변수로 지정하거나, 기본값 사용
ASG_NAME=${1:-acc-backend-asg}

INSTANCE_IDS=$(aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-name "$ASG_NAME" \
  --query "AutoScalingGroups[0].Instances[*].InstanceId" \
  --output text)

if [ -z "$INSTANCE_IDS" ]; then
  echo "[ERROR] ASG에 인스턴스가 없습니다. (ASG 이름: $ASG_NAME)"
  exit 1
fi

aws ec2 describe-instances \
  --instance-ids $INSTANCE_IDS \
  --query "Reservations[*].Instances[*].[PrivateIpAddress, Placement.AvailabilityZone]" \
  --output text | while read ip az; do
    echo "IP: $ip   AZ: $az"
done 