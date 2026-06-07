#!/bin/bash
set -e

# Configuration Variables
REGION="us-east-1"
TAG_NAME="JustAuthInstance"
KEY_NAME="just-auth-key"
SECURITY_GROUP_NAME="just-auth-sg"

echo "Starting teardown of Just-Auth resources..."

# 1. Find and terminate the EC2 instance
INSTANCE_ID=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=$TAG_NAME" "Name=instance-state-name,Values=pending,running,stopping,stopped" \
    --region "$REGION" \
    --output text --query 'Reservations[0].Instances[0].InstanceId')

if [ -n "$INSTANCE_ID" ] && [ "$INSTANCE_ID" != "None" ]; then
    echo "Terminating instance: $INSTANCE_ID"
    aws ec2 terminate-instances --instance-ids "$INSTANCE_ID" --region "$REGION" > /dev/null
    echo "Waiting for termination to complete..."
    aws ec2 wait instance-terminated --instance-ids "$INSTANCE_ID" --region "$REGION"
else
    echo "No running/stopped instance with tag Name=$TAG_NAME found – skipping termination."
fi


# 2. Delete the security group (only if no instances are using it)
SG_ID=$(aws ec2 describe-security-groups \
    --filters "Name=group-name,Values=$SECURITY_GROUP_NAME" \
    --region "$REGION" \
    --output text --query 'SecurityGroups[0].GroupId')

if [ -n "$SG_ID" ] && [ "$SG_ID" != "None" ]; then
    echo "Deleting security group: $SG_ID"
    aws ec2 delete-security-group --group-id "$SG_ID" --region "$REGION" 2>/dev/null || \
        echo "Security group already deleted or in use – skipping."
else
    echo "Security group $SECURITY_GROUP_NAME not found – skipping."
fi


# 3. Delete the key pair (if it exists)
if aws ec2 describe-key-pairs --key-names "$KEY_NAME" --region "$REGION" &>/dev/null; then
    echo "Deleting key pair: $KEY_NAME"
    aws ec2 delete-key-pair --key-name "$KEY_NAME" --region "$REGION"
else
    echo "Key pair $KEY_NAME not found – skipping."
fi


# 4. Remove local inventory file (if present)
if [ -f inventory.yml ]; then
    rm -f inventory.yml
    echo "Removed local inventory.yml"
fi

echo "✅ Teardown of JustAuth infrastructure and runtime is complete."