LB_IP=$(YC_CLI_INITIALIZATION_SILENCE=true yc load-balancer network-load-balancer get lb--kubernetes-ingress --format json | jq -r '.listeners[0].address')
if [[ -z "$LB_IP" ]]; then
    echo "Could not get LB IP" >&2
    exit 1
fi

echo "application : http://catchmemobbin.strangled.net : $LB_IP"
echo "grafana : http://grafana.catchmemobbin.strangled.net : $LB_IP"
echo "prometheus : http://prometheus.catchmemobbin.strangled.net : $LB_IP"
echo "atlantis : http://atlantis.catchmemobbin.strangled.net : $LB_IP"
