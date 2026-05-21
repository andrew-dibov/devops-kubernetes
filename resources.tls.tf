resource "tls_private_key" "tls__kubernetes" {
  for_each  = toset(values(local.ci__kubernetes_names))
  algorithm = "ED25519"
}

