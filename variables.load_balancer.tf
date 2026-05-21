variable "lb__target_group_kubernetes_api_name" {
  type    = string
  default = "lb--kubernetes-masters"
}

variable "lb__target_group_kubernetes_api_region_id" {
  type    = string
  default = "ru-central1"
}

variable "lb__kubernetes_api_name" {
  type    = string
  default = "lb--kubernetes-api"
}

variable "lb__kubernetes_api_type" {
  type    = string
  default = "external"
}

variable "lb__kubernetes_api_listener_name" {
  type    = string
  default = "kubernetes-api"
}

variable "lb__kubernetes_api_healthcheck_name" {
  type    = string
  default = "lb--kubernetes-api-health"
}

variable "lb__target_group_kubernetes_ingress_name" {
  type    = string
  default = "lb--kubernetes-ingress"
}

variable "lb__target_group_kubernetes_ingress_region_id" {
  type    = string
  default = "ru-central1"
}

variable "lb__kubernetes_ingress_name" {
  type    = string
  default = "lb--kubernetes-ingress"
}

variable "lb__kubernetes_ingress_type" {
  type    = string
  default = "external"
}

variable "lb__kubernetes_ingress_listener_name_http" {
  type    = string
  default = "http-listener"
}

variable "lb__kubernetes_ingress_listener_name_https" {
  type    = string
  default = "https-listener"
}

variable "lb__kubernetes_ingress_healthcheck_name" {
  type    = string
  default = "lb--kubernetes-ingress-health"
}
