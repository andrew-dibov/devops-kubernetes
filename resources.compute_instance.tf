resource "yandex_compute_instance" "ci__kubernetes" {
  for_each = local.ci__kubernetes_configs

  zone        = each.value.zone
  platform_id = var.ci__kubernetes_platform_id

  name        = each.key
  hostname    = each.key
  description = each.value.description

  allow_stopping_for_update = true

  resources {
    cores         = each.value.resources.cores
    memory        = each.value.resources.memory
    core_fraction = each.value.resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ci__debian.id
      size     = each.value.initialize_params.size
    }
  }

  network_interface {
    subnet_id          = each.value.network_interface.subnet_id
    nat                = each.value.network_interface.nat
    security_group_ids = each.value.network_interface.security_group_ids
  }

  scheduling_policy {
    preemptible = each.value.scheduling_policy.preemptible
  }

  metadata = {
    ssh-keys  = "debian:${tls_private_key.tls__kubernetes[each.key].public_key_openssh}"
    user-data = templatefile("${var.templates}/kubernetes.cloud-init.tftpl", { pkgs = ["python3"] })
  }

  labels = {
    role = each.value.role
  }
}
