#!/bin/bash

TF_SECRET_NAME="ls--terraform-key"
TF_SECRET_KEY="ls__terraform_key"
S3_SECRET_NAME="ls--terraform-state"
S3_ACCESS_KEY_ENTRY="sa__terraform_static_access_key"
S3_SECRET_KEY_ENTRY="sa__terraform_static_secret_key"
S3_BUCKET_NAME=$(YC_CLI_INITIALIZATION_SILENCE=true yc storage bucket list --format json | jq -r '.[] | select(.name | startswith("sb--terraform-state-")) | .name')

echo "Initializing tfstate to : $S3_BUCKET_NAME"

AWS_ACCESS_KEY_ID=$(YC_CLI_INITIALIZATION_SILENCE=true yc lockbox payload get --name $S3_SECRET_NAME --format json | jq -r --arg key "$S3_ACCESS_KEY_ENTRY" '.entries[] | select(.key == $key) | .text_value')
AWS_SECRET_ACCESS_KEY=$(YC_CLI_INITIALIZATION_SILENCE=true yc lockbox payload get --name $S3_SECRET_NAME --format json | jq -r --arg key "$S3_SECRET_KEY_ENTRY" '.entries[] | select(.key == $key) | .text_value')

cat > .env <<EOF
export YC_SERVICE_ACCOUNT_KEY_FILE=terraform.key.json
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
export TF_VAR_bucket=$S3_BUCKET_NAME
EOF
source .env

YC_CLI_INITIALIZATION_SILENCE=true yc lockbox payload get --name "$TF_SECRET_NAME" --key "$TF_SECRET_KEY" > terraform.key.json
terraform init -backend-config=bucket="$S3_BUCKET_NAME" && terraform apply -auto-approve
