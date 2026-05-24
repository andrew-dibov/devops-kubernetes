resource "local_file" "tls__kubernetes_private_key" {
  for_each = tls_private_key.tls__kubernetes

  filename        = "${var.ansible}/${var.keys}/${each.key}"
  file_permission = 0600
  content         = each.value.private_key_openssh
}

resource "local_file" "tls__kubernetes_public_key" {
  for_each = tls_private_key.tls__kubernetes

  filename        = "${var.ansible}/${var.keys}/${each.key}.pub"
  file_permission = 0644
  content         = each.value.public_key_openssh
}

resource "local_file" "tls__bastion_private_key" {
  filename        = "${var.ansible}/${var.keys}/${data.terraform_remote_state.network.outputs.ci__bastion_name}"
  file_permission = 0600
  content         = data.yandex_lockbox_secret_version.ls__bastion_ssh_key_version.entries[0].text_value
}

resource "local_file" "lf__ssh_config" {
  filename        = "${var.ansible}/${var.lf__ssh_config_filename}"
  file_permission = 0600

  content = templatefile("${var.templates}/ansible.ssh-config.tftpl", {
    bastion_ip            = data.terraform_remote_state.network.outputs.ci__bastion_public_ip
    bastion_user          = "debian"
    bastion_identity_file = "${var.keys}/${data.terraform_remote_state.network.outputs.ci__bastion_name}"

    instances = {
      for name, vm in yandex_compute_instance.ci__kubernetes :
      name => {
        hostname      = vm.network_interface[0].ip_address
        user          = "debian"
        identity_file = "${var.keys}/${name}"
      }
    }
  })
}

resource "local_file" "lf__ansible_config" {
  filename = "${var.ansible}/${var.lf__ansible_config_filename}"
  content  = templatefile("${var.templates}/ansible.config.tftpl", {})
}

resource "local_file" "lf__ansible_inventory" {
  filename = "${var.ansible}/inventories/${var.lf__ansible_inventory_filename}"
  content = templatefile("${var.templates}/ansible.inventory.tftpl", {
    hosts = yandex_compute_instance.ci__kubernetes
  })
}

resource "local_file" "lf__ansible_variables" {
  filename = "${var.ansible}/variables/${var.lf__ansible_variables_filename}"
  content = templatefile("${var.templates}/ansible.variables.tftpl", {
    master_a = yandex_compute_instance.ci__kubernetes["${local.ci__kubernetes_names.ci__master_a}"].network_interface[0].ip_address
    master_b = yandex_compute_instance.ci__kubernetes["${local.ci__kubernetes_names.ci__master_b}"].network_interface[0].ip_address
    worker_a = yandex_compute_instance.ci__kubernetes["${local.ci__kubernetes_names.ci__worker_a}"].network_interface[0].ip_address
    worker_b = yandex_compute_instance.ci__kubernetes["${local.ci__kubernetes_names.ci__worker_b}"].network_interface[0].ip_address

    api_endpoint = tolist([
      for l in yandex_lb_network_load_balancer.lb__kubernetes_api.listener :
      tolist(l.external_address_spec)[0].address
    ])[0]

    ingress_endpoint = tolist([
      for l in yandex_lb_network_load_balancer.lb__kubernetes_ingress.listener :
      tolist(l.external_address_spec)[0].address
    ])[0]

    atlantis_node = local.ci__kubernetes_names.ci__worker_a
  })
}

