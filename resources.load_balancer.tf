resource "yandex_lb_target_group" "lb__target_group_kubernetes_api" {
  name      = var.lb__target_group_kubernetes_api_name
  region_id = var.lb__target_group_kubernetes_api_region_id

  target {
    subnet_id = data.terraform_remote_state.network.outputs.vpc__subnet_private_a_id
    address   = yandex_compute_instance.ci__kubernetes[local.ci__kubernetes_names.ci__master_a].network_interface[0].ip_address
  }

  target {
    subnet_id = data.terraform_remote_state.network.outputs.vpc__subnet_private_b_id
    address   = yandex_compute_instance.ci__kubernetes[local.ci__kubernetes_names.ci__master_b].network_interface[0].ip_address
  }
}

resource "yandex_lb_network_load_balancer" "lb__kubernetes_api" {
  name = var.lb__kubernetes_api_name
  type = var.lb__kubernetes_api_type

  listener {
    name        = var.lb__kubernetes_api_listener_name
    protocol    = "tcp"
    port        = 6443
    target_port = 6443

    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.lb__target_group_kubernetes_api.id

    healthcheck {
      name                = var.lb__kubernetes_api_healthcheck_name
      interval            = 2
      timeout             = 1
      unhealthy_threshold = 2
      healthy_threshold   = 2

      tcp_options {
        port = 6443
      }
    }
  }
}

resource "yandex_lb_target_group" "lb__target_group_kubernetes_ingress" {
  name      = var.lb__target_group_kubernetes_ingress_name
  region_id = var.lb__target_group_kubernetes_ingress_region_id

  target {
    subnet_id = data.terraform_remote_state.network.outputs.vpc__subnet_private_a_id
    address   = yandex_compute_instance.ci__kubernetes[local.ci__kubernetes_names.ci__worker_a].network_interface[0].ip_address
  }

  target {
    subnet_id = data.terraform_remote_state.network.outputs.vpc__subnet_private_b_id
    address   = yandex_compute_instance.ci__kubernetes[local.ci__kubernetes_names.ci__worker_b].network_interface[0].ip_address
  }
}

resource "yandex_lb_network_load_balancer" "lb__kubernetes_ingress" {
  name = var.lb__kubernetes_ingress_name
  type = var.lb__kubernetes_ingress_type

  listener {
    name        = var.lb__kubernetes_ingress_listener_name_http
    protocol    = "tcp"
    port        = 80
    target_port = 30080

    external_address_spec {
      ip_version = "ipv4"
    }
  }

  listener {
    name        = var.lb__kubernetes_ingress_listener_name_https
    protocol    = "tcp"
    port        = 443
    target_port = 30443

    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.lb__target_group_kubernetes_ingress.id

    healthcheck {
      name                = var.lb__kubernetes_ingress_healthcheck_name
      interval            = 2
      timeout             = 1
      unhealthy_threshold = 2
      healthy_threshold   = 2

      tcp_options {
        port = 30080
      }
    }
  }
}
