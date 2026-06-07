# Kubernetes кластер

Развертывание и настройка отказоустойчивого кластера Kubernetes для [devops](https://github.com/andrew-dibov/devops). Создание VM, установка и настройка ключевых компонентов, инициализация Control Plane, присоединение дополнительных узлов с последующим развертыванием Ingress NGINX, Prometheus Stack и Atlantis.

## Архитектура

> Проект опирается на [network](https://github.com/andrew-dibov/devops-network)

### Слой 1 : Инфраструктура : Terraform + Yandex Cloud

- **Сеть** : `outputs` из [network](https://github.com/andrew-dibov/devops-network)
- **VM Kubernetes** :
  - `ci--master-a` : `ru-central1-a`
  - `ci--master-b` : `ru-central1-b`
  - `ci--worker-a` : `ru-central1-a`
  - `ci--worker-b` : `ru-central1-b`
- **Группа безопасности** :
  - `SSH` : из публичных подсетей для бастиона
  - `HTTP/HTTPS` : из интернета для веб-трафика : `0.0.0.0/0`
  - `NodePort` : для Ingress : `30080` и `30443`
  - `K8s API` : из интернета для управления кластером : `6443`
  - Внутренний трафик для подсетей : `/16`
  - Исходящий трафик : `NAT`
- **Балансировка входящего трафика** :
  - **API Load Balancer** :
    - `TCP 6443` -> `master-a:6443`, `master-b:6443`
  - **Ingress Load Balancer** :
    - `TCP 80` -> `worker-a:30080`, `worker-b:30080`
    - `TCP 443` -> `worker-a:30443`, `worker-b:30443`

### Слой 2 : Bootstrap кластера : Bash + Ansible

| Плейбук | Назначение |
| :-- | :-- |
| `kubernetes-1` | Настройка `sysctl` и модулей ядра : `overlay`, `br_netfilter` и `nf_conntrack` |
| `kubernetes-2` | Установка `containerd`, `runc` и `CNI plugins` |
| `kubernetes-3` | Настройка `systemd`, установка : `kubeadm`, `kubelet` и `kubectl` |
| `kubernetes-4` | `master-a` : инициализация кластера, установка Flannel, копирование `kubeconfig` |
| `kubernetes-5` | `master-b` : подключение к Control Plane |
| `kubernetes-6` | `worker-a`, `worker-b` : подключение в кластер |
| `helm` | Развертывание : Ingress NGINX, Prometheus Stack и Atlantis |

### Слой 3 : Приложения : Ansible + Helm

| Приложение | Назначение |
| :-- | :-- |
| **Ingress NGINX** | Прием внешнего трафика |
| **Atlantis** | Автоматизация Terraform |
| **Prometheus Stack** | Observability |

## Технологии и навыки

| Категория | Технологии/Инструменты | Навыки |
| :-- | :-- | :-- |
| **Infrastructure as Code, IaC** | Terraform, Yandex Provider | Комплексная инфраструктура с межпроектными зависимостями |
| **Yandex Cloud, YC** | Compute Cloud, VPC, Load Balancer, Lockbox | Создание VM, настройка балансировки, интеграция с хранилищем секретов |
| **Configuration Management** | Ansible | Идемпотентное развертывание K8s и работа с Helm |
| **Kubernetes** | kubeadm, containerd, kubectl, flannel, Helm | Развертывание HA-кластера с балансировкой Control Plane и работа с чартами |
| **GitOps & CI/CD** | Atlantis + GitHub App | Настройка вебхуков, автоматическое планирование/применение PR |
| **Observability** | Prometheus, Grafana, Alertmanager | Развертывание и начальная конфигурация системы мониторинга |

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
