source aws.env

export YC_CLOUD_ID=$(YC_CLI_INITIALIZATION_SILENCE=true yc config get cloud-id)
export YC_FOLDER_ID=$(YC_CLI_INITIALIZATION_SILENCE=true yc config get folder-id)

terraform apply -auto-approve
