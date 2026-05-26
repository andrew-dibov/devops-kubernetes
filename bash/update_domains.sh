#!/bin/bash

USERNAME=""
while [[ -z "$USERNAME" ]]; do
  printf "DNS service username [https://freedns.afraid.org] : "
  read USERNAME
  if [[ -z "$USERNAME" ]]; then
    printf "DNS service username can not be empty"
  fi
done

PASSWORD=""
while [[ -z "$PASSWORD" ]]; do
  printf "DNS service password [https://freedns.afraid.org] : "
  read PASSWORD
  if [[ -z "$PASSWORD" ]]; then
    printf "DNS service password can not be empty"
  fi
done

LB_IP=$(YC_CLI_INITIALIZATION_SILENCE=true yc load-balancer network-load-balancer get lb--kubernetes-ingress --format json | jq -r '.listeners[0].address')
if [[ -z "$LB_IP" ]]; then
    echo "Could not get LB IP" >&2
    exit 1
fi

response=$(curl -s --user "${USERNAME}:${PASSWORD}" "https://freedns.afraid.org/nic/update?hostname=catchmemobbin.strangled.net&myip=${LB_IP}")
echo "$domain : $response"

echo "application : http://catchmemobbin.strangled.net"
echo "grafana : http://grafana.catchmemobbin.strangled.net"
echo "prometheus : http://prometheus.catchmemobbin.strangled.net"
echo "atlantis : http://atlantis.catchmemobbin.strangled.net"
