# [DevOps](https://github.com/andrew-dibov/devops) : Kubernetes кластер

## Архитектура

### Слой 1 : Инфраструктура

- **Сеть** : использование outputs из [проекта сетевой инфраструктуры](https://github.com/andrew-dibov/devops-network)
- **VM Kubernetes** :
  - `ci--master-a` : `ru-central1-a`
  - `ci--master-b` : `ru-central1-b`
  - `ci--worker-a` : `ru-central1-a`
  - `ci--worker-a` : `ru-central1-b`
- **Безопасность** : группа безопасности, разрешающая :
  - `SSH` : только из публичных подсетей : Бастион
  - `HTTP/HTTPS` : из интернета : `0.0.0.0/0`
  - `K8s API` : из интернета : `6443`
  - `NodePort` : для ingress : `30080`, `30443`
  - Весь внутренний трафик между подсетями `/16`
  - Весь исходящий трафик : NAT-шлюз
- **Балансировка нагрузки** :
  - **API Load Balancer** :
    - `TCP 6443` -> `master-a:6443`, `master-b:6443`
  - **Ingress Load Balancer** :
    - `TCP 80` -> `worker-a:30080`, `worker-b:30080`
    - `TCP 443` -> `worker-a:30443`, `worker-b:30443`
- **Ansible** : автоматическая генерация артефактов : инвентари и переменные

### Слой 2 : Bootstrap кластера K8s

Ansible-плейбуки последовательно выполняются Bash-скриптом :

| Плейбук | Назначение |
| :-- | :-- |
| `kubernetes-1.yml` | Настройка ОС : модули ядра (`overlay`, `br_netfilter`, `nf_conntrack`), параметры `sysctl`, установка базовых пакетов |
| `kubernetes-2.yml` | Установка `containerd`, `runc`, `CNI plugins` из официальных релизов GitHub |
| `kubernetes-3.yml` | Установка `kubeadm`, `kubelet`, `kubectl` и настройка `systemd` |
| `kubernetes-4.yml` | `master-a` : инициализация кластера с `podCIDR` `10.244.0.0/16`, установка `CNI flannel`, генерация join-команд, копирование `kubeconfig` |
| `kubernetes-5.yml` | `master-b` : подключение к `control-plane` |
| `kubernetes-6.yml` | `worker-a`, `worker-b` : подключение в кластер |
| `helm.yml` | Установка `helm`, добавление репозиториев, установка чартов : `ingress nginx`, `kube-prometheus-stack`, `atlantis` |

### Слой 3 : Приложения

- **Ingress Nginx** : прием трафика с внешнего балансировщика нагрузки
- **Prometheus Stack** : Prometheus, Grafana, Alertmanager
- **Atlantis** : проверка и применение Terraform

## Технологии и навыки

| Категория | Технологии/Инструменты | Навыки |
| :-- | :-- | :-- |
|

## Развертывание

```bash
# скопировать и перейти
git clone git@github.com:andrew-dibov/devops-kubernetes.git && cd devops-kubernetes

# запустить скрипт инициализации
sudo chmod +x bash/* && ./bash/init.sh

# запустить скрипт обновления доменов
./bash/update_domains.sh

# если планируешь работать дальше
source .env

# перейти к следующему этапу развертывания
cd ansible

# запустить ansible-плейбуки
sudo chmod +x bash/* && ./bash/deploy.sh
```