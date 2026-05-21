data "yandex_lockbox_secret" "ls__bastion_ssh_key" {
  secret_id = data.terraform_remote_state.network.outputs.ls__bastion_ssh_key_id
}

data "yandex_lockbox_secret_version" "ls__bastion_ssh_key_version" {
  secret_id = data.yandex_lockbox_secret.ls__bastion_ssh_key.id
}
