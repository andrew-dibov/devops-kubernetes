locals {
  ci__kubernetes_names = {
    ci__master_a = "ci--master-a"
    ci__master_b = "ci--master-b"
    ci__worker_a = "ci--worker-a"
    ci__worker_b = "ci--worker-b"
  }
  ci__kubernetes_configs = {
    (local.ci__kubernetes_names.ci__master_a) = {
      zone        = "ru-central1-a"
      description = "Kubernetes Master A"

      resources = {
        cores         = 4
        memory        = 4
        core_fraction = 20
      }

      initialize_params = {
        size = 40
      }

      network_interface = {
        subnet_id          = data.terraform_remote_state.network.outputs.vpc__subnet_private_a_id
        nat                = false
        security_group_ids = [yandex_vpc_security_group.sg__kubernetes.id]
      }

      scheduling_policy = {
        preemptible = false
      }

      role = "master-a"
    }
    (local.ci__kubernetes_names.ci__master_b) = {
      zone        = "ru-central1-b"
      description = "Kubernetes Master B"

      resources = {
        cores         = 4
        memory        = 4
        core_fraction = 20
      }

      initialize_params = {
        size = 40
      }

      network_interface = {
        subnet_id          = data.terraform_remote_state.network.outputs.vpc__subnet_private_b_id
        nat                = false
        security_group_ids = [yandex_vpc_security_group.sg__kubernetes.id]
      }

      scheduling_policy = {
        preemptible = true
      }

      role = "master-b"
    }
    (local.ci__kubernetes_names.ci__worker_a) = {
      zone        = "ru-central1-a"
      description = "Kubernetes Worker A"

      resources = {
        cores         = 4
        memory        = 4
        core_fraction = 20
      }

      initialize_params = {
        size = 40
      }

      network_interface = {
        subnet_id          = data.terraform_remote_state.network.outputs.vpc__subnet_private_a_id
        nat                = false
        security_group_ids = [yandex_vpc_security_group.sg__kubernetes.id]
      }

      scheduling_policy = {
        preemptible = true
      }

      role = "worker-a"
    }
    (local.ci__kubernetes_names.ci__worker_b) = {
      zone        = "ru-central1-b"
      description = "Kubernetes Worker B"

      resources = {
        cores         = 4
        memory        = 4
        core_fraction = 20
      }

      initialize_params = {
        size = 40
      }

      network_interface = {
        subnet_id          = data.terraform_remote_state.network.outputs.vpc__subnet_private_b_id
        nat                = false
        security_group_ids = [yandex_vpc_security_group.sg__kubernetes.id]
      }

      scheduling_policy = {
        preemptible = true
      }

      role = "worker-b"
    }
  }
}
