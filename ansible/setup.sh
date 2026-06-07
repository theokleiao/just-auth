#!/bin/bash
set -e

# Configuration variables
KEY_NAME="just-auth-key"                 # Name of your AWS EC2 key pair
PUBLIC_KEY_PATH="~/.ssh/id_rsa.pub"      # Path to the public key file
PRIVATE_KEY_PATH="~/.ssh/id_rsa"
INSTANCE_TYPE="t2.micro"
AMI_ID="ami-05cf1e9f73fbad2e2"           # Ubuntu 22.04 LTS (us-east-1)
REGION="us-east-1"
SECURITY_GROUP_NAME="just-auth-sg"
TAG_NAME="JustAuthInstance"

# Create Security Group
echo "Creating security group: $SECURITY_GROUP_NAME"
SG_ID=$(aws ec2 create-security-group \
    --group-name "$SECURITY_GROUP_NAME" \
    --description "Allow SSH and frontend port 8888" \
    --region "$REGION" \
    --output text --query 'GroupId')

# Add inbound rule for SSH
aws ec2 authorize-security-group-ingress \
    --group-id "$SG_ID" \
    --protocol tcp --port 22 --cidr 0.0.0.0/0 \
    --region "$REGION"

# Add inbound rule for frontend
aws ec2 authorize-security-group-ingress \
    --group-id "$SG_ID" \
    --protocol tcp --port 8888 --cidr 0.0.0.0/0 \
    --region "$REGION"

echo "Security group created: $SG_ID"

# Setup SSH Key Pair
echo "Setting up SSH key pair..."
aws ec2 import-key-pair \
    --key-name "$KEY_NAME" \
    --public-key-material fileb://"$PUBLIC_KEY_PATH"

# Launch EC2 Instance
echo "Launching EC2 instance..."
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id "$AMI_ID" \
    --instance-type "$INSTANCE_TYPE" \
    --key-name "$KEY_NAME" \
    --security-group-ids "$SG_ID" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$TAG_NAME}]" \
    --region "$REGION" \
    --output text --query 'Instances[0].InstanceId')

echo "Instance launched: $INSTANCE_ID"

# Wait for instance to be running
echo "Waiting for instance to enter 'running' state..."
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID" --region "$REGION"
echo "Instance is now running!!!"

# Get public IP
PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --region "$REGION" \
    --output text --query 'Reservations[0].Instances[0].PublicIpAddress')

echo "JustAuth EC2 Instance is now running. Public IP: $PUBLIC_IP"

# Wait for SSH to be ready
echo "Waiting for SSH to be available on $PUBLIC_IP..."
while ! nc -z "$PUBLIC_IP" 22; do
    sleep 2
done
sleep 5   # extra delay for cloud-init

# --- Generate inventory.yml for Ansible ---
cat > inventory.yml <<EOF
all:
  hosts:
    just-auth-host:
      ansible_host: $PUBLIC_IP
      ansible_user: ubuntu
      ansible_ssh_private_key_file: $PRIVATE_KEY_PATH
      ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
EOF

echo "Inventory file created: inventory.yml"

echo "✅ JustAuth Infrastructure and Runtime setup completed. Instance IP is $PUBLIC_IP."
