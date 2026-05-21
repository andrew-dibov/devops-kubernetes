terraform {
  required_version = ">= 1.14.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.174.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.1.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.6.1"
    }
  }
}

provider "yandex" {
  service_account_key_file = "terraform.key.json"
}
