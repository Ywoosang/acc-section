#!/bin/bash

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KEY_PATH="$PROJECT_ROOT/terraform/acc-key.pem"
TERRAFORM_DIR="$PROJECT_ROOT/terraform"

cd "$TERRAFORM_DIR" || exit 1
MONITORING_IP=$(terraform output -raw monitoring_private_ip)
BASTION_IP=$(terraform output -raw bastion_public_ip)

echo "Bastion IP: $BASTION_IP"
echo "Monitoring Private IP: $MONITORING_IP"

echo "Loki (3100) + Grafana (3000)"
ssh -i "$KEY_PATH" \
    -L 3000:$MONITORING_IP:3000 \
    -L 3100:$MONITORING_IP:3100 \
    ubuntu@$BASTION_IP