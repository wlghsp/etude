#!/bin/bash
set -e

# Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker ubuntu
sudo systemctl enable docker

# Docker Compose
sudo apt-get install -y docker-compose-plugin

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl

# k3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# k3d 이미지 사전 pull (클러스터 최초 기동 시 pull 대기시간 제거)
docker pull rancher/k3s:latest
docker pull rancher/k3d-proxy:latest

# Node.js 20 (프론트 빌드용)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# k3d 재부팅 자동 시작 (systemd 서비스)
sudo tee /etc/systemd/system/k3d-etude.service > /dev/null << 'EOF'
[Unit]
Description=k3d etude cluster
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/bin/k3d cluster start etude
ExecStop=/usr/local/bin/k3d cluster stop etude
User=ubuntu

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable k3d-etude

echo "Setup complete. Log out and back in for docker group to take effect."