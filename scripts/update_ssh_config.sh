#!/bin/bash

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_FILE="$HOME/.ssh/config"
BACKUP_FILE="$HOME/.ssh/config.bak.$(date +%Y%m%d%H%M%S)"
KEY_PATH="$PROJECT_ROOT/terraform/acc-key.pem"
TERRAFORM_DIR="$PROJECT_ROOT/terraform"

cp "$CONFIG_FILE" "$BACKUP_FILE"
echo "기존 SSH config 백업: $BACKUP_FILE"

cd "$TERRAFORM_DIR"
echo "[DEBUG] terraform output -raw monitoring_private_ip 결과:"
terraform output -raw monitoring_private_ip 2>/dev/null > /tmp/monitoring_ip_raw.txt
cat /tmp/monitoring_ip_raw.txt

MONITORING_IP=$(cat /tmp/monitoring_ip_raw.txt | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n1)
cd - > /dev/null
APP_IP=$(bash "$PROJECT_ROOT/scripts/get_asg_private_ips.sh" | head -n1 | awk '{print $2}')
BASTION_IP=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=acc-bastion" "Name=instance-state-name,Values=running" \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text | head -n1)

echo "MONITORING_IP: $MONITORING_IP"
echo "APP_IP: $APP_IP"
echo "BASTION_IP: $BASTION_IP"

# 임시 파일 생성
tmpfile=$(mktemp)

awk -v bastion_ip="$BASTION_IP" -v app_ip="$APP_IP" -v monitoring_ip="$MONITORING_IP" '
BEGIN {host=""}
/^Host / {
  host=$2
}
{
  if (host=="bastion" && $1=="HostName") {
    print "  HostName " bastion_ip
    next
  }
  if (host=="acc-app" && $1=="HostName") {
    print "  HostName " app_ip
    next
  }
  if (host=="acc-monitoring" && $1=="HostName") {
    print "  HostName " monitoring_ip
    next
  }
  print $0
}
' "$CONFIG_FILE" > "$tmpfile"

mv "$tmpfile" "$CONFIG_FILE"
echo "SSH config의 HostName만 안전하게 갱신되었습니다." 