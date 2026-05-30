#!/bin/bash

# This script is used to create a new S3 bucket for Terraform state management and lock.

BUCKET_NAME="justauth-tfstate-$(date +%s)"
REGION="us-east-1"
echo "Creating remote state bucket $BUCKET_NAME in  $REGION AWS region"

# Create bucket
aws s3api create-bucket --bucket $BUCKET_NAME --region $REGION

# Enable versioning
aws s3api put-bucket-versioning --bucket $BUCKET_NAME --versioning-configuration Status=Enabled

# Disable public access
aws s3api put-public-access-block --bucket $BUCKET_NAME --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

# Enable default encryption (SSE-S3)
aws s3api put-bucket-encryption --bucket $BUCKET_NAME \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'

echo "Bucket $BUCKET_NAME has been created in $REGION AWS Region."
