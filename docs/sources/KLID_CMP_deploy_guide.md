# KLID CMP 배포 가이드

작성자: 양기영

## 목차

- [설치 패키지 다운로드](#설치-패키지-다운로드)
- [패키지 구조](#패키지-구조)
- [테스트 환경](#테스트-환경)
- [순서](#순서)
  - [레포지토리 이미지 업로드](#레포지토리-이미지-업로드-02images)
  - [인증서 생성](#인증서-생성-01certs)
  - [TLS Secret 생성](#tls-secret-생성-01certs)
  - [cmp-gateway 생성](#cmp-gateway-생성-03cmp-helm--01cmp-gateway)
  - [미들웨어 배포](#미들웨어-배포-03cmp-helm--02cmp-mdware)
  - [IaaS CMP](#iaas-cmp-03cmp-helm--03iaas-cmp)
  - [PaaS CMP](#paas-cmp-03cmp-helm--04paas-cmp)
  - [Gateway 및 서비스 브로커](#gateway-및-서비스-브로커)

---

## 설치 패키지 다운로드

(다운로드 경로 또는 방법 기재)

## 패키지 구조

```
99.packages/
├─ 01.certs/                   # 사설 인증서
├─ 02.images/                  # 컨테이너 이미지(iaas-cmp / mdware / paas-cmp)
├─ 03.cmp-helm/
│   ├─ 01.cmp-gateway/         # [Istio 전용] Gateway
│   ├─ 02.cmp-mdware/          # 미들웨어(스크립트 기반): Redis·Rabbitmq·Vault·Keycloak(+postgres)
│   ├─ 03.iaas-cmp/dev-helm/   # IaaS CMP (Helm)
│   └─ 04.paas-cmp/dev-helm/   # PaaS CMP (Helm)
├─ 04.gateway-broker/          # 중계서버 (Send, Receive) + 서비스브로커 + openJdk + Terraform
└─ 05.data/                    # 초기 데이터(DB + Vault + Keycloak Realm)
└─ 06.tools/                   # k9s, safe cli
```

## 테스트 환경

> 서버 접속 정보: 임대환 팀장님에게 문의

| 항목 | 버전 |
|------|------|
| OS | RHEL 9.6 |
| OpenSSL | 3.2.2 |
| Kubernetes | v1.31.13 |
| CRI | Containerd |
| CNI | Cilium |
| CSI | NFS |
| 트래픽 처리 | Istio |

### hosts 파일

```
# /etc/hosts
172.30.2.162 kibana.klidcmp.or.kr
172.30.2.162 nexus.klidcmp.or.kr
172.30.2.162 elasticsearch.klidcmp.or.kr
172.30.2.162 keycloak.klidcmp.or.kr
172.30.2.162 vault.klidcmp.or.kr
172.30.2.162 rabbitmq.klidcmp.or.kr
172.30.2.162 app.iaas.klidcmp.or.kr
172.30.2.162 api.iaas.klidcmp.or.kr
172.30.2.162 api.rhov.klidcmp.or.kr
172.30.2.162 api.user.klidcmp.or.kr
172.30.2.162 api.vmware.klidcmp.or.kr
172.30.2.162 api.service-catalog-engine.klidcmp.or.kr
172.30.2.162 api.vmware-service-catalog.klidcmp.or.kr
172.30.2.162 app.contrabass.klidcmp.or.kr
172.30.2.162 api.contrabass.klidcmp.or.kr
172.30.2.162 app.dashboard.klidcmp.or.kr
172.30.2.162 api.dashboard.klidcmp.or.kr
172.30.2.162 www.klidcmp.or.kr
172.30.2.162 app.paas.klidcmp.or.kr
172.30.2.162 api.paas.klidcmp.or.kr
172.30.2.162 api.dashboardAdmin.klidcmp.or.kr
172.30.2.162 app.symphony.klidcmp.or.kr
172.30.2.162 api.symphony.klidcmp.or.kr
```

---

## 순서

### 레포지토리 이미지 업로드 (02.images)

```bash
# 99.packages > 02.images 이동
# containerd 사용 시 nerdctl, crio 사용 시 podman
# 대상: iaas-cmp / mdware / paas-cmp 경로의 tar 파일

nerdctl load -i *.tar

# 이미지 태깅 및 푸시
sh docker-tag.sh
```

### 인증서 생성 (01.certs)

> 참고 페이지: 인증서 v1.0.0

### TLS Secret 생성 (01.certs)

```bash
# 99.packages > 01.certs 이동
sh create-tls.sh deploy
```

### cmp-gateway 생성 (03.cmp-helm > 01.cmp-gateway)

```bash
# 99.packages > 03.cmp-helm > 01.cmp-gateway 이동
helm install -n cmp-gateway cmp-gateway . -f values.yaml --create-namespace
```

### 미들웨어 배포 (03.cmp-helm > 02.cmp-mdware)

```bash
# 99.packages > 03.cmp-helm > 02.cmp-mdware 이동

# Redis
sh scripts/redis/redis-deploy.sh            deploy

# RabbitMQ
sh scripts/rabbitmq/rabbitmq-deploy.sh      deploy

# Vault
sh scripts/vault/1.transit-vault-deploy.sh  deploy
sh scripts/vault/2-1.transit-vault-unseal
sh scripts/vault/2-2.transit-vault-unseal
sh scripts/vault/3.service-vault-deploy.sh  deploy
sh scripts/vault/4.service-vault-unseal

# Vault 데이터 Import
safe target http://{Vault IP}:{Vault Port} vault
safe auth
safe import < vualt-data.json

# Keycloak
sh scripts/postgresql/postgresql-deploy.sh  deploy
sh scripts/keycloak/keycloak-deploy.sh      deploy
```

Keycloak 1회 배포 후 `CREATE_CONFIG_REALM` 값을 `1 → 0`으로 수정한다:

```bash
vi scripts/keycloak/keycloak-deploy.sh
# CREATE_CONFIG_REALM=0

sh scripts/keycloak/keycloak-deploy.sh      upgrade
```

### IaaS CMP (03.cmp-helm > 03.iaas-cmp)

```bash
# 99.packages > 03.cmp-helm > 03.iaas-cmp > dev-helm 이동
# 배포 환경에 맞게 values.yaml 수정 후
helm install -n iaas-cmp iaas-cmp . -f values.yaml
```

### PaaS CMP (03.cmp-helm > 04.paas-cmp)

```bash
# 99.packages > 03.cmp-helm > 04.paas-cmp > dev-helm 이동
# 배포 환경에 맞게 values.yaml 수정 후
helm install -n paas-cmp paas-cmp . -f values.yaml
```

### Gateway 및 서비스 브로커

```bash
# 99.packages > 04.gateway-broker > common 이동

# openJdk
cd openjdk-1.8
unzip openjdk-1.8.zip
# openjdk-install.txt 파일 참고

# Terraform
cd terraform
# terraform-install.txt 파일 참고

# Gateway — 환경에 맞게 application.yml, bootstrap.yml 수정 후
sh gateway start   # 시작
sh gateway stop    # 중지
```
