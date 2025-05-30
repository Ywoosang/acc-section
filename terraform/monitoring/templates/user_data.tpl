#!/bin/bash

sudo mkdir -p /home/ubuntu/logs
sudo chown ubuntu:ubuntu /home/ubuntu/logs
exec > /home/ubuntu/logs/user-data.log 2>&1
set -x

until curl -sf http://archive.ubuntu.com > /dev/null; do
  echo "[cloud-init] Waiting for network to be ready..."
  sleep 10
done

# 필수 패키지 설치
sudo apt-get update
sudo apt-get install -y docker.io docker-compose

# Docker 서비스 시작 및 자동 시작 설정
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ubuntu

# 작업 디렉토리 생성

sudo mkdir -p /opt/monitoring/loki  # 최상위만 만들고
sudo chown -R 10001:10001 /opt/monitoring/loki  # 권한만 맞춰주기
cd /opt/monitoring

sudo cat <<EOF > docker-compose.yml
version: "3.8"
services:
  loki:
    image: grafana/loki:2.9.3
    container_name: loki
    ports:
      - "3100:3100"
    command: -config.file=/etc/loki/loki-config.yaml
    volumes:
      - ./loki-config.yaml:/etc/loki/loki-config.yaml
      - ./loki:/loki

  grafana:
    image: grafana/grafana:10.4.1
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana-storage:/var/lib/grafana

volumes:
  grafana-storage:
EOF

sudo cat <<EOF > loki-config.yaml
auth_enabled: false

server:
  http_listen_port: 3100

common:
  instance_addr: 127.0.0.1
  path_prefix: /loki
  storage:
    filesystem:
      chunks_directory: /loki/chunks
      rules_directory: /loki/rules
  replication_factor: 1
  ring:
    kvstore:
      store: inmemory

schema_config:
  configs:
    - from: 2020-10-24
      store: tsdb
      object_store: filesystem
      schema: v13
      index:
        prefix: index_
        period: 24h

ruler:
  alertmanager_url: http://localhost:9093
EOF

sudo docker-compose up -d

# ec2 의 user_data 는 nat_gateway 가 public ip 에 연결된 이후로 실행되는가?
#