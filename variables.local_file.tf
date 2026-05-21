variable "lf__ssh_config_filename" {
  type    = string
  default = "ssh-config"
}

variable "lf__ansible_config_filename" {
  type    = string
  default = "ansible.cfg"
}

variable "lf__ansible_inventory_filename" {
  type    = string
  default = "inventory.terraform.yml"
}

variable "lf__ansible_variables_filename" {
  type    = string
  default = "variables.terraform.yml"
}
