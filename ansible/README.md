```bash
ansible -i inventory.terraform.yml all -m ping

ansible-playbook -i inventory.terraform.yml kubernetes-*
ansible-playbook -i inventory.terraform.yml helm
```