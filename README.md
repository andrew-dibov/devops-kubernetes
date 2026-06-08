# Kubernetes

Создание облачной инфраструктуры с последующим развертыванием и настройкой отказоустойчивого Kubernetes-кластера [проекта](https://github.com/andrew-dibov/devops). Создание сети виртуальных машин, отдельной группы безопасности и балансировщиков нагрузки под control plane и ingress трафик. Автоматическая установка и конфигурация ключевых компонентов Kubernetes, инициализация control plane, подключение worker-узлов и развертывание Ingress NGINX, Prometheus Stack и Atlantis.

> Kubernetes-кластер подразумевает готовность [bootstrap](https://github.com/andrew-dibov/devops-bootstrap) и [network](https://github.com/andrew-dibov/devops-network)

## Архитектура

### Слой 1 : Инициализация : Bash

1. Создание .env-файла с авторизационными данными
2. Получение и экспорт JSON-ключа сервисного аккаунта
3. Инициализация удаленного бэкенда и развертывание инфраструктуры

### Слой 2 : Облачная инфраструктуры : Terraform

Виртуальные машины располагаются в приватных подсетях и нескольких зонах доступности :

| Виртуальная машина | Роль в кластере | Зона доступности | Подсеть |
| :-- | :-- | :-- | :-- |
| **`ci--master-a`** | Control plane | `ru-central1-a` | `vpc--subnet-private-a` |
| **`ci--master-b`** | Control plane | `ru-central1-b` | `vpc--subnet-private-b` |
| **`ci--worker-a`** | Worker node | `ru-central1-a` | `vpc--subnet-private-a` |
| **`ci--worker-b`** | Worker node | `ru-central1-b` | `vpc--subnet-private-b` |

Группа безопасности предоставляет минимально необходимые разрешения :

| Направление трафика | Протокол | Порт | CIDR | Назначение |
| :-- | :-- | :-- | :-- | :-- |
| **Ingress** | `TCP` | `22` | Входящий трафик из публичных подсетей | Администрирование и конфигурация через бастион |
| **Ingress** | `TCP` | `80` | `0.0.0.0/0` | Входящий HTTP трафик веб-приложения |
| **Ingress** | `TCP` | `443` | `0.0.0.0/0` | Входящий HTTPS трафик веб-приложения |
| **Ingress** | `TCP` | `6443` | `0.0.0.0/0` | Входящий трафик для Kubernetes API |
| **Ingress** | `TCP` | `30080` | `0.0.0.0/0` | NodePort для Ingress по HTTP |
| **Ingress** | `TCP` | `30443` | `0.0.0.0/0` | NodePort для Ingress по HTTPS |
| **Ingress** | `ANY` | `ANY` | Входящий трафик из приватных подсетей | Коммуникация кластера |
| **Egress** | `ANY` | `ANY` | `0.0.0.0/0` | Доступ в интернет через NAT |
| **Egress** | `ANY` | `ANY` | Исходящий трафик в приватные подсети | Коммуникация кластера |

Балансировщики нагрузки работают по следующим правилам :

| Балансировщик | Протокол | Порт | Назначение |
| :-- | :-- | :-- | :-- |
| **`lb--kubernetes-api`** | `TCP` | `6443` | `master-a:6443`, `master-b:6443` |
| **`lb--kubernetes-ingress`** | `TCP` | `80` | `worker-a:30080`, `worker-b:30080` |
| **`lb--kubernetes-ingress`** | `TCP` | `443` | `worker-a:30443`, `worker-b:30443` |

### Слой 3 : Развертывание кластера и чартов : Ansible + Helm

Bash-скрипт запрашивает авторизационные данных и выполняет серию Ansible-плейбуков :

| # |Плейбук | Назначение | 
| :-- | :-- | :-- |
| 1 | `kubernetes-1` | Настройка операционной системы и модулей ядра : `overlay`, `br_netfilter` и `nf_conntrack` |
| 2 | `kubernetes-2` | Установка основных компонентов : `runc`, `containerd` и `CNI plugins` |
| 3 | `kubernetes-3` | Настройка системы инициализации и установка пакетов : `kubeadm`, `kubelet` и `kubectl` |
| 4 | `kubernetes-4` | Конфигурация `master-a` : инициализация кластера и установка Flannel |
| 5 | `kubernetes-5` | Конфигурация `master-b` : инициализация high availability control plane |
| 6 | `kubernetes-6` | Конфигурация `worker-a` и `worker-b` : подключение worker-узлов |
| 7 | `helm` | Развертывание чартов : Ingress NGINX, Prometheus Stack и Atlantis |

- Комплексная инфраструктура с межпроектными зависимостями
- Создание ВМ
- Настройка балансировки
- Интеграция с хранилищем секретов
- Идемпотентное развертывание кубов и работы с хельм
- Развертывание хай авайлабилити кластера с балансировкой control plane и работа с чартами
- Настройка вебхуков
- Автоматическое планирование и применение PR
- Развертывание и начальная конфигурация системы мониторинга

## Технологии и навыки

| Категория | Технологии/Инструменты | Навыки |
| :-- | :-- | :-- |
| **Infrastructure as Code, IaC** | Terraform, Yandex Provider | Управление сложной инфраструктурой с зависимостями между проектами |
| **Yandex Cloud** | Virtual Private Cloud, Compute Instance, Load Balancer | Проектирование high availability кластера с балансировкой нагрузки |
| **Configuration Management** | Ansible, Helm | Идемпотентное развертывание и настройка Kubernetes, автоматическое применение чартов  |
| **Kubernetes** | runc, containerd, kubeadm, kubelet, kubectl, Flannel | Проектирование кластера с балансировкой control plane |
| **GitOps & CI/CD** | Atlantis + GitHub App | Реализация автоматического планирования/применения PR через вебкухи к GitHub App |
| **Observability** | Prometheus, Grafana, Alertmanager | Развертывание и начальная конфигурация системы мониторинга |

## Развертывание

```bash
# скопировать и перейти в репозиторий
git clone git@github.com:andrew-dibov/devops-kubernetes.git && cd devops-kubernetes

# запустить скрипт инициализации и экспортировать переменные окружения
sudo chmod +x bash/* && ./bash/init.sh

# обновить домены
./bash/update_domains.sh
source .env

# запустить ansible-плейбуки
(cd ansible && sudo chmod +x bash/* && ./bash/deploy.sh)
```
