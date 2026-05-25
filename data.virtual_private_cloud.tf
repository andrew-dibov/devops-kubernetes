data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = var.bucket
    region = "ru-central1"
    key    = "network/terraform.tfstate"

    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }

    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_region_validation      = true
    use_path_style              = true
  }
}
