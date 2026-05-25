terraform {
  backend "s3" {
    key    = "kubernetes/terraform.tfstate"
    region = "ru-central1"

    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }

    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_region_validation      = true
    use_path_style              = true
  }
}
