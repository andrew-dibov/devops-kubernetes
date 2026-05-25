echo "Lockbox terraform secret name [ls--terraform-key] :"
read TF_SECRET_NAME
TF_SECRET_NAME=${TF_KEY_SECRET_NAME:-"ls--terraform-key"}

echo "Lockbox terraform secret key [ls__terraform_key] :"
read TF_SECRET_KEY
TF_SECRET_KEY=${TF_SECRET_KEY:-"ls__terraform_key"}

echo "Lockbox bucket secret name [ls--terraform-state] :"
read S3_SECRET_NAME
S3_SECRET_NAME=${S3_SECRET_NAME:-"ls--terraform-state"}

echo "Lockbox bucket access key entry [sa__terraform_static_access_key] :"
read S3_ACCESS_KEY_ENTRY
S3_ACCESS_KEY_ENTRY=${S3_ACCESS_KEY_ENTRY:-"sa__terraform_static_access_key"}

echo "Lockbox bucket secret key entry [sa__terraform_static_secret_key] :"
read S3_SECRET_KEY_ENTRY
S3_SECRET_KEY_ENTRY=${S3_SECRET_KEY_ENTRY:-"sa__terraform_static_secret_key"}

YC_CLI_INITIALIZATION_SILENCE=true yc storage bucket list
S3_BUCKET_NAME=""

while [[ -z "$S3_BUCKET_NAME" ]]; do
  echo "S3 terraform state bucket name :"
  read S3_BUCKET_NAME

  if [[ -z "$S3_BUCKET_NAME" ]]; then
    YC_CLI_INITIALIZATION_SILENCE=true yc storage bucket list
  fi
done

YC_CLI_INITIALIZATION_SILENCE=true yc lockbox payload get --name "$TF_SECRET_NAME" --key "$TF_SECRET_KEY" > terraform.key.json

export AWS_ACCESS_KEY_ID=$(YC_CLI_INITIALIZATION_SILENCE=true yc lockbox payload get --name $S3_SECRET_NAME --format json | jq -r --arg key "$S3_ACCESS_KEY_ENTRY" '.entries[] | select(.key == $key) | .text_value')
export AWS_SECRET_ACCESS_KEY=$(YC_CLI_INITIALIZATION_SILENCE=true yc lockbox payload get --name $S3_SECRET_NAME --format json | jq -r --arg key "$S3_SECRET_KEY_ENTRY" '.entries[] | select(.key == $key) | .text_value')

cat > backend.s3.tf <<EOF
terraform {
  backend "s3" {
    bucket   = "$S3_BUCKET_NAME"
    key      = "kubernetes/terraform.tfstate"
    region   = "ru-central1"

    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }

    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_region_validation      = true
    use_path_style              = true
  }
}
EOF

cat > data.virtual_private_cloud.tf <<EOF
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket   = "$S3_BUCKET_NAME"
    region   = "ru-central1"
    key      = "network/terraform.tfstate"
    
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }

    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_region_validation      = true
    use_path_style              = true
  }
}
EOF

export YC_SERVICE_ACCOUNT_KEY_FILE="terraform.key.json"

terraform init && terraform apply -auto-approve

echo "export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" > aws.env
echo "export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" >> aws.env