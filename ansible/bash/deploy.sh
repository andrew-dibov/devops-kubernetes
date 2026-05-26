printf "Github application ID [default : 3818613] : "
read GH_APP_ID
GH_APP_ID=${GH_APP_ID:-"3818613"}

printf "Github application webhook secret [default : create new] : "
read -r GH_APP_WH_SECRET

if [ -z "$GH_APP_WH_SECRET" ]; then
    GH_APP_WH_SECRET=$(openssl rand -hex 32)
    echo "New webhook secret : $GH_APP_WH_SECRET"
fi

printf "Github application key [multiline paste] : "
read -p "Save webhook secret and press ENTER to continue"

TMP_FILE=$(mktemp)
${EDITOR:-nano} "$TMP_FILE"
GH_APP_KEY=$(awk '{print "  " $0}' "$TMP_FILE")
rm -f "$TMP_FILE"

S3_BUCKET_NAME=$(YC_CLI_INITIALIZATION_SILENCE=true yc storage bucket list --format json | jq -r '.[] | select(.name | startswith("sb--terraform-state-")) | .name')
YC_SA_KEY=$(cat ../terraform.key.json | jq '.' | sed 's/^/  /')

cat > variables/variables.vault.yml <<EOF
github_app_id: "$GH_APP_ID"
github_app_secret: "$GH_APP_WH_SECRET"
github_app_key: |
$GH_APP_KEY

atlantis_yc_key: |
$YC_SA_KEY

aws_access_key_id: "$(grep 'export AWS_ACCESS_KEY_ID=' ../.env | cut -d '=' -f2)"
aws_secret_access_key: "$(grep 'export AWS_SECRET_ACCESS_KEY' ../.env | cut -d '=' -f2)"
terraform_backend: "$S3_BUCKET_NAME"
EOF

ansible all -m ping && ansible-playbook kubernetes-*
ansible all -m ping && ansible-playbook helm.yml
