#!/bin/bash
sudo mkdir -p /home/ubuntu/logs
sudo chown ubuntu:ubuntu /home/ubuntu/logs
exec > /home/ubuntu/logs/user-data.log 2>&1
set -x

until curl -sf http://archive.ubuntu.com > /dev/null; do
  echo "[cloud-init] Waiting for network to be ready..."
  sleep 10
done

sudo apt-get update -y
sudo apt-get install -y docker.io unzip curl

# 도커 서비스 시작 및 권한 설정
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ubuntu
#  Linux에서 그룹 변경은 다음 로그인부터 반영되므로, 현재 세션에서 docker 그룹 권한 즉시 반영
newgrp docker

# aws cli v2 설치
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -o awscliv2.zip
sudo ./aws/install

# Promtail 설치
cd /opt
sudo curl -L -o /tmp/promtail-linux-amd64.zip https://github.com/grafana/loki/releases/download/v2.9.3/promtail-linux-amd64.zip
sudo unzip /tmp/promtail-linux-amd64.zip -d /opt
sudo mv /opt/promtail-linux-amd64 /usr/local/bin/promtail
sudo chmod +x /usr/local/bin/promtail

# ECR 로그인
sudo aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${ecr_repository_url}

# 도커 이미지 실행
docker pull ${ecr_repository_url}:latest
docker run -d -p 8080:8080 --name acc-app ${ecr_repository_url}:latest

# 헬스체크
until curl -sf http://localhost:8080/health | grep -q "OK"; do
  sleep 1
done

# 로그 디렉토리 생성 및 심볼릭 링크 설정
sudo mkdir -p /home/ubuntu/logs
container_id=$(docker inspect --format='{{.Id}}' acc-app)
docker_log_path="/var/lib/docker/containers/$container_id/$container_id-json.log"
symlink_path="/home/ubuntu/logs/acc.log"
sudo ln -sf "$docker_log_path" "$symlink_path"

# Promtail 설정 디렉토리 생성
sudo mkdir -p /opt/promtail

# Promtail 설정 파일 생성
sudo cat > /opt/promtail/promtail-config.yaml <<EOF
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://${monitoring_instance_private_ip}:3100/loki/api/v1/push

scrape_configs:
  - job_name: acc-app
    static_configs:
      - targets:
          - localhost
        labels:
          job: acc-app
          __path__: /home/ubuntu/logs/acc.log

    pipeline_stages:
      - json:
          expressions:
            log: log
      - output:
          source: log
EOF

# 디렉토리 및 내부 파일 소유자 변경
sudo chown -R ubuntu:ubuntu /home/ubuntu/logs

# Promtail 실행
sudo nohup promtail -config.file=/opt/promtail/promtail-config.yaml > /home/ubuntu/logs/promtail.log 2>&1 &
