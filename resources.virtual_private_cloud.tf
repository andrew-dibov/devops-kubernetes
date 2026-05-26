resource "yandex_vpc_security_group" "sg__kubernetes" {
  network_id = data.terraform_remote_state.network.outputs.vpc__network_id

  name        = var.sg__kubernetes_name
  description = var.sg__kubernetes_description

  ingress {
    protocol    = "TCP"
    description = "Ingress SSH ATLANTIS CHANGE"
    v4_cidr_blocks = [
      data.terraform_remote_state.network.outputs.vpc__subnet_public_a_v4_cidr_blocks[0],
      data.terraform_remote_state.network.outputs.vpc__subnet_public_b_v4_cidr_blocks[0],
    ]
    port = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "Ingress HTTP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "Ingress HTTPS"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  ingress {
    protocol       = "TCP"
    description    = "Ingress K8s API"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 6443
  }

  ingress {
    protocol       = "TCP"
    description    = "Ingress nodeport"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 30080
  }

  ingress {
    protocol       = "TCP"
    description    = "Ingress nodeport"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 30443
  }

  ingress {
    protocol    = "ANY"
    description = "Ingress internal"
    v4_cidr_blocks = [
      data.terraform_remote_state.network.outputs.vpc__subnet_private_a_v4_cidr_blocks[0],
      data.terraform_remote_state.network.outputs.vpc__subnet_private_b_v4_cidr_blocks[0],
    ]
  }

  egress {
    protocol       = "ANY"
    description    = "Egress NAT"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "ANY"
    description = "Egress internal"
    v4_cidr_blocks = [
      data.terraform_remote_state.network.outputs.vpc__subnet_private_a_v4_cidr_blocks[0],
      data.terraform_remote_state.network.outputs.vpc__subnet_private_b_v4_cidr_blocks[0],
    ]
  }
}
