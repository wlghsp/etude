# Phase 8 구현 가이드 — 서버 배포 (OCI Free Tier)

명세: [specs/spec_phase8_deploy.md](../specs/spec_phase8_deploy.md)

---

## 전체 흐름

```
Step 1. OCI 콘솔 — 사전 준비 (API 키, compartment OCID 수집)
Step 2. Terraform — VM + 네트워크 프로비저닝
Step 3. setup.sh — 서버 초기 세팅 (Docker, k3d, kubectl)
Step 4. k3d — 클러스터 생성 + kubeconfig 구성
Step 5. 커스텀 이미지 빌드 (etude-k8s, etude-ssh)
Step 6. 소스 배포 + 환경변수 설정
Step 7. 프론트 빌드 + docker-compose 기동
Step 8. 접속 확인
```

---

## Step 1. OCI 콘솔 — 사전 준비

Terraform이 OCI API를 호출하려면 인증 정보가 필요하다.
OCI 콘솔에서 아래 값을 수집한다.

### 1-1. 필요한 값 목록

| 항목 | 수집 방법 |
|------|-----------|
| Tenancy OCID | 콘솔 우상단 프로필 → Tenancy |
| User OCID | 콘솔 우상단 프로필 → My profile |
| Compartment OCID | Identity & Security → Compartments → root compartment |
| Region | 콘솔 우상단 (예: `ap-seoul-1`) |
| API Key (fingerprint + pem) | 아래 참고 |

### 1-2. API 키 생성

```bash
# 로컬에서 RSA 키 생성
mkdir -p ~/.oci
openssl genrsa -out ~/.oci/oci_api_key.pem 2048
chmod 600 ~/.oci/oci_api_key.pem
openssl rsa -pubout -in ~/.oci/oci_api_key.pem -out ~/.oci/oci_api_key_public.pem
```

OCI 콘솔 → My profile → API keys → Add API key → Paste public key
→ 공개키(`oci_api_key_public.pem` 내용) 붙여넣기
→ fingerprint 값 저장

### 1-3. SSH 키 생성 (VM 접속용)

```bash
ssh-keygen -t ed25519 -f ~/.ssh/etude_oci -C "etude-deploy"
```

`~/.ssh/etude_oci.pub` 내용을 Terraform에서 VM에 주입한다.

---

## Step 2. Terraform — VM 프로비저닝

### 2-1. 파일 생성

프로젝트 루트에 `infra/terraform/` 디렉토리를 만들고 아래 3개 파일을 작성한다.

#### `infra/terraform/variables.tf`

```hcl
variable "tenancy_ocid"     {}
variable "user_ocid"        {}
variable "fingerprint"      {}
variable "private_key_path" {}
variable "region"           {}
variable "compartment_ocid" {}
variable "ssh_public_key"   {}
```

#### `infra/terraform/main.tf`

```hcl
terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

# VCN
resource "oci_core_vcn" "etude" {
  compartment_id = var.compartment_ocid
  cidr_block     = "10.0.0.0/16"
  display_name   = "etude-vcn"
}

# Internet Gateway
resource "oci_core_internet_gateway" "etude" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.etude.id
  display_name   = "etude-igw"
  enabled        = true
}

# Route Table
resource "oci_core_route_table" "etude" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.etude.id
  display_name   = "etude-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.etude.id
  }
}

# Security List (방화벽)
resource "oci_core_security_list" "etude" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.etude.id
  display_name   = "etude-sl"

  # SSH
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }

  # HTTP
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
  }

  # 아웃바운드 전체 허용
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

# Subnet
resource "oci_core_subnet" "etude" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.etude.id
  cidr_block        = "10.0.1.0/24"
  display_name      = "etude-subnet"
  route_table_id    = oci_core_route_table.etude.id
  security_list_ids = [oci_core_security_list.etude.id]
}

# ARM VM (Always Free)
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

# Ubuntu 22.04 ARM64 최신 이미지 자동 조회 (리전마다 OCID가 다르므로 하드코딩하지 않음)
data "oci_core_images" "ubuntu" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

resource "oci_core_instance" "etude" {
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  display_name        = "etude-server"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 4
    memory_in_gbs = 24
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu.images[0].id
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.etude.id
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}

# Reserved Public IP (고정 IP)
resource "oci_core_public_ip" "etude" {
  compartment_id = var.compartment_ocid
  lifetime       = "RESERVED"
  display_name   = "etude-ip"
  private_ip_id  = data.oci_core_private_ips.etude.private_ips[0].id
}

data "oci_core_private_ips" "etude" {
  subnet_id  = oci_core_subnet.etude.id
  ip_address = oci_core_instance.etude.private_ip
}
```

#### `infra/terraform/outputs.tf`

```hcl
output "public_ip" {
  value = oci_core_public_ip.etude.ip_address
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/etude_oci ubuntu@${oci_core_public_ip.etude.ip_address}"
}
```

#### `infra/terraform/terraform.tfvars` (gitignore에 추가)

```hcl
tenancy_ocid     = "ocid1.tenancy.oc1..xxxxxx"
user_ocid        = "ocid1.user.oc1..xxxxxx"
fingerprint      = "xx:xx:xx:..."
private_key_path = "~/.oci/oci_api_key.pem"
region           = "ap-seoul-1"
compartment_ocid = "ocid1.compartment.oc1..xxxxxx"
ssh_public_key   = "ssh-ed25519 AAAA..."
```

> `compartment_ocid`는 별도로 compartment를 만들지 않았다면 root compartment를 쓰면 되고, root compartment의 OCID는 `tenancy_ocid`와 동일하다.
>
> Ubuntu 22.04 ARM64 이미지는 리전마다 OCID가 다르고 콘솔에서 찾기 번거로우므로, OCID를 직접 넣지 않고 `main.tf`의 `oci_core_images` data source로 자동 조회한다 (위 2-1 참고).

### 2-2. .gitignore 추가

`infra/terraform/terraform.tfvars`는 비밀 정보이므로 gitignore에 추가한다.

```
infra/terraform/terraform.tfvars
infra/terraform/.terraform/
infra/terraform/terraform.tfstate
infra/terraform/terraform.tfstate.backup
```

### 2-4. 실행

```bash
cd infra/terraform
terraform init
terraform plan
terraform apply
```

완료 후 출력:

```
public_ip   = "xxx.xxx.xxx.xxx"
ssh_command = "ssh -i ~/.ssh/etude_oci ubuntu@xxx.xxx.xxx.xxx"
```

---

## Step 3. setup.sh — 서버 초기 세팅

### 3-1. 파일 생성

`infra/scripts/setup.sh`:

```bash
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
```

### 3-2. 실행

```bash
# 로컬에서 스크립트 전송 후 실행
scp -i ~/.ssh/etude_oci infra/scripts/setup.sh ubuntu@{공인IP}:~/
ssh -i ~/.ssh/etude_oci ubuntu@{공인IP} "bash ~/setup.sh"

# docker 그룹 반영을 위해 재접속
ssh -i ~/.ssh/etude_oci ubuntu@{공인IP}
```

---

## Step 4. k3d 클러스터 생성 + kubeconfig 구성

서버에 SSH 접속 후 실행:

```bash
# 클러스터 생성
k3d cluster create etude --api-port 127.0.0.1:6443

# 정상 확인
kubectl get nodes

# config-etude 생성 (컨테이너 내부에서 접근 가능한 주소로 교체)
kubectl config view --raw | \
  sed 's|https://127.0.0.1:6443|https://k3d-etude-server-0:6443|g' \
  > ~/.kube/config-etude
```

---

## Step 5. 커스텀 이미지 빌드

서버에서 직접 빌드한다.

```bash
# 소스 먼저 받아야 Dockerfile 접근 가능 (Step 6 이후로 넘겨도 됨)
cd ~/etude/backend

# etude-k8s 빌드
docker build -f docker/Dockerfile.k8s -t etude-k8s .

# etude-ssh 빌드
docker build -f docker/Dockerfile.ssh -t etude-ssh .

# 확인
docker images | grep etude
```

---

## Step 6. 소스 배포 + 환경변수 설정

### 6-1. GitHub SSH 키 설정 (Private Repo)

```bash
# 서버에서 SSH 키 생성
ssh-keygen -t ed25519 -f ~/.ssh/github_etude -C "etude-server"
cat ~/.ssh/github_etude.pub
```

출력된 공개키를 GitHub → Settings → Deploy keys → Add deploy key에 등록.

`~/.ssh/config` 추가:

```
Host github.com
  IdentityFile ~/.ssh/github_etude
```

### 6-2. 소스 clone

```bash
git clone git@github.com:{org}/etude.git ~/etude
```

### 6-3. 환경변수 작성

```bash
cat > ~/etude/backend/.env.prod << 'EOF'
DB_HOST=db
DB_PORT=3306
DB_USER=etude
DB_PASSWORD={비밀번호 설정}
DB_NAME=etude
JWT_SECRET={랜덤 시크릿 설정}
KUBECONFIG_PATH=/root/.kube/config-etude
K3D_NETWORK=k3d-etude
EOF
```

> `JWT_SECRET`을 빠뜨리면 `backend/src/services/auth.ts`의 기본값(`dev-secret`)으로 fallback된다. 배포 시 반드시 설정한다.

---

## Step 7. 프로덕션 파일 작성 + 서비스 기동

### 7-1. deploy/docker-compose.prod.yml 작성 (로컬에서)

```yaml
services:
  db:
    image: mariadb:11
    container_name: etude-db
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: etude
      MYSQL_USER: etude
      MYSQL_PASSWORD: ${DB_PASSWORD}
    volumes:
      - etude-db-data:/var/lib/mysql
      - ./backend/db/init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - etude

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: etude-backend
    restart: unless-stopped
    env_file: ./backend/.env.prod
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ${HOME}/.kube/config-etude:/root/.kube/config-etude:ro
    depends_on:
      - db
    networks:
      - etude
      - k3d-etude

  nginx:
    image: nginx:alpine
    container_name: etude-nginx
    restart: unless-stopped
    ports:
      - "80:80"
    volumes:
      - ./frontend/dist:/usr/share/nginx/html:ro
      - ./deploy/nginx.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      - backend
    networks:
      - etude

volumes:
  etude-db-data:

networks:
  etude:
    driver: bridge
  k3d-etude:
    external: true
```

### 7-2. deploy/nginx.conf 작성 (로컬에서)

```nginx
server {
    listen 80;

    # 프론트엔드 (정적 파일)
    location / {
        root /usr/share/nginx/html;
        index index.html;
        try_files $uri $uri/ /index.html;
    }

    # 백엔드 API
    location /api/ {
        proxy_pass http://backend:3001/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # WebSocket
    location /ws/ {
        proxy_pass http://backend:3001/ws/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_read_timeout 3600s;
    }
}
```

### 7-3. backend/Dockerfile 작성 (로컬에서)

```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
EXPOSE 3001
CMD ["node", "dist/index.js"]
```

### 7-4. 코드 수정 — tsconfig

**`backend/tsconfig.json` — outDir 주석 해제**

현재 `outDir`이 주석 처리되어 있어 `npm run build`를 해도 `dist/`가 생성되지 않는다.

```json
// 변경 전
// "rootDir": "./src",
// "outDir": "./dist",

// 변경 후
"rootDir": "./src",
"outDir": "./dist",
```

> 프론트엔드 API/WebSocket URL의 포트 처리는 [guide_phase7e_deploy_api_url.md](guide_phase7e_deploy_api_url.md)에서 이미 `VITE_API_BASE`/`VITE_WS_BASE` 환경변수로 구현되어 있다. `frontend/.env.production`은 빈 값(같은 origin, 포트 생략)으로 이미 존재하므로 이 단계에서 별도 코드 수정은 불필요하다. 배포 전 `frontend/.env.production`의 두 값이 비어 있는지만 확인한다.

### 7-5. git push 후 서버에서 실행

```bash
# 서버에서
cd ~/etude
git pull

# 프론트 빌드
cd frontend
npm ci
npm run build
cd ..

# 서비스 기동
docker compose -f deploy/docker-compose.prod.yml up -d --build
```

---

## Step 8. 접속 확인

```bash
# 서비스 상태
docker compose -f deploy/docker-compose.prod.yml ps

# 로그 확인
docker compose -f deploy/docker-compose.prod.yml logs -f backend

# 브라우저 접속
open http://{공인IP}
```

### 검증 순서

1. 세트 선택 화면 로드 확인
2. 리눅스 퀘스트 — 터미널 연결 + 명령어 실행 + 채점
3. 도커 퀘스트 — DinD 터미널 연결 + 채점
4. k8s 퀘스트 — `kubectl get nodes` 실행 확인 + 채점

---

## 재배포 절차

코드 변경 후 서버 반영:

```bash
cd ~/etude
git pull

# 프론트 변경 시
cd frontend && npm run build && cd ..

# 서비스 재시작
docker compose -f deploy/docker-compose.prod.yml up -d --build backend
```

---

## 유용한 운영 명령어

```bash
# 전체 서비스 중지
docker compose -f deploy/docker-compose.prod.yml down

# DB 초기화 (주의: 데이터 삭제)
docker compose -f deploy/docker-compose.prod.yml down -v

# k3d 클러스터 중지/재시작
k3d cluster stop etude
k3d cluster start etude

# 고아 컨테이너 정리 (etude- prefix)
docker ps -a --filter "name=etude-" --format "{{.ID}}" | xargs docker rm -f
```

---

## 주의사항

- `terraform.tfvars`는 절대 git에 올리지 않는다. `.gitignore`에 포함 확인 필수.
- `backend/.env.prod`는 서버에만 존재한다. git에 올리지 않는다.
- Docker socket(`/var/run/docker.sock`) 마운트는 샌드박스 컨테이너 제어에 필수다.
- k3d 클러스터가 내려간 상태에서 서비스를 올리면 k8s 세트만 연결 실패한다. 다른 세트는 영향 없음.
- VM 재부팅 시 k3d 클러스터가 자동으로 올라오지 않는다. `k3d cluster start etude` 후 `docker compose up -d` 순서로 실행한다.
