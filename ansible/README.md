```bash
ansible all -m ping
ansible-playbook kubernetes-*

cat > variables/variables.vault.yml <<EOF # заполни авторизацию atlantis
github_app_id: "<github-app-id>"
github_app_secret: "<github-app-webhook-secret>"

github_app_key: |
  -----BEGIN RSA PRIVATE KEY-----
  <rsa-private-key>
  -----END RSA PRIVATE KEY-----

yc_sa_key: '<terraform-sa-key>'
EOF

ansible-vault encrypt variables/variables.vault.yml
ansible-playbook helm.yml --ask-vault-pass
```