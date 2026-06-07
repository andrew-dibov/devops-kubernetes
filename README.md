# Kubernetes

Создание отказоустойчивого кластера Kubernetes. Создание VM, настройка безопасности, установка K8s, инициализация control plane, подключение дополнительных узлов с последующим развертыванием : Ingress NGINX, Prometheus Stack и Atlantis.

## Архитектура

> Проект опирается на [network](https://github.com/andrew-dibov/devops-network)

### Слой 1 : Инфраструктура : Terraform + Yandex Cloud

- **Сеть** : outputs из [network](https://github.com/andrew-dibov/devops-network)
- **VM Kubernetes** :
  - `ci--master-a` : `ru-central1-a`
  - `ci--master-b` : `ru-central1-b`
  - `ci--worker-a` : `ru-central1-a`
  - `ci--worker-b` : `ru-central1-b`
- **Группа безопасности** :
  - `SSH` : из публичных подсетей
  - `HTTP/HTTPS` : из интернета : `0.0.0.0/0`
  - `K8s API` : из интернета : `6443`
  - `NodePort` : для ingress : `30080` и `30443`
  - Внутренний трафик подсетей `/16`
  - Исходящий трафик : `NAT`
- **Балансировка входящего трафика** :
  - **API Load Balancer** :
    - `TCP 6443` -> `master-a:6443`, `master-b:6443`
  - **Ingress Load Balancer** :
    - `TCP 80` -> `worker-a:30080`, `worker-b:30080`
    - `TCP 443` -> `worker-a:30443`, `worker-b:30443`

### Слой 2 : Bootstrap кластера : Bash + Ansible

Ansible-плейбуки :

| Плейбук | Назначение |
| :-- | :-- |
| `kubernetes-1` | Установка пакетов, настройка `sysctl` и модулей ядра : `overlay`, `br_netfilter` и `nf_conntrack` |
| `kubernetes-2` | Установка `containerd`, `runc` и `CNI plugins` |
| `kubernetes-3` | Настройка `systemd` и установка : `kubeadm`, `kubelet` и `kubectl` |
| `kubernetes-4` | `master-a` : инициализация кластера, установка `Flannel`, экспорт join-команд, копирование `kubeconfig` |
| `kubernetes-5` | `master-b` : подключение к control plane |
| `kubernetes-6` | `worker-a`, `worker-b` : добавление в кластер |
| `helm` | Установка и развертывание : Ingress NGINX, Prometheus Stack и Atlantis |

### Слой 3 : Приложения : Ansible + Helm

| Приложение | Назначение |
| :-- | :-- |
| Ingress NGINX | Получение трафика с внешнего балансировщика |
| Prometheus Stack | Prometheus, Grafana, Alertmanager |
| Atlantis | Автоматизация Terraform |

## Технологии и навыки

| Категория | Технологии/Инструменты | Навыки |
| :-- | :-- | :-- |
| **Infrastructure as Code, IaC** | Terraform, Yandex Provider | Инфраструктура с зависимостями между проектами |
| **Yandex Cloud, YC** | Compute Cloud, VPC, Load Balancer, Lockbox | Создание VM, настройка балансировки, интеграция с хранилищем секретов |
| **Configuration Management** | Ansible | Идемпотентное развертывание K8s, установка компонентов, работа с Helm |
| **Kubernetes** | kubeadm, containerd, runc, flannel, kubectl, helm | Развертывание HA-кластера с балансировкой control plane, установка чартов |
| **GitOps & CI/CD** | Atlantis + GitHub App | Настройка вебхуков, автоматический план/применение PR |
| **Observability** | Prometheus, Grafana, Alertmanager | Развертывание и начальная конфигурация |

## Развертывание

```bash
# скопировать и перейти
git clone git@github.com:andrew-dibov/devops-kubernetes.git && cd devops-kubernetes

# запустить скрипт инициализации
sudo chmod +x bash/* && ./bash/init.sh

# обновить домены
./bash/update_domains.sh

# если планируешь работать дальше
source .env

# запустить ansible-плейбуки
(cd ansible && sudo chmod +x bash/* && ./bash/deploy.sh)
```
