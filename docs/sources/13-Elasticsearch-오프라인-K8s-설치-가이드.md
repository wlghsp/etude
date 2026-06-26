# Elasticsearch 오프라인 K8s 설치 가이드 (ECK Operator)

> 이미지 tar 파일과 manifest yaml이 이미 준비된 상태에서 시작합니다.

---

## 패키지 구조

```
elasticsearch-packages/
├── images/
│   ├── eck-operator.tar            # ECK Operator 이미지
│   ├── es.tar                      # Elasticsearch 이미지
│   └── kibana.tar                  # Kibana 이미지
├── es/
│   ├── crds.yaml                   # ECK CRD 정의
│   ├── operator.yaml               # ECK Operator 배포 manifest
│   ├── elastic.yaml                # Elasticsearch 클러스터 정의
│   ├── elastic-gateway.yaml        # Gateway 설정
│   ├── elastic-vs.yaml             # VirtualService 설정
│   └── elasticsearch-ingress.yaml  # Ingress 설정 (환경에 따라 적용)
└── kibana/
    ├── kibana.yaml                 # Kibana 배포 manifest
    └── kibana-route.yaml           # Route 설정
```

### 운영 환경 스펙 (elastic.yaml 기준)

| 노드 | count | CPU | Memory | Storage |
|---|---|---|---|---|
| master | 3 | 2 core | 4 Gi (JVM 2g) | 20 Gi |
| worker | 3 | 4 core | 8 Gi (JVM 4g) | 50 Gi (운영 시 조정) |
| coordinate | 2 | 2 core | 4 Gi (JVM 2g) | emptyDir |

---

## 목차

1. [이미지 로드 및 레지스트리 Push](#1-이미지-로드-및-레지스트리-push)
2. [사전 준비 사항](#2-사전-준비-사항)
3. [ECK Operator 설치](#3-eck-operator-설치)
4. [Elasticsearch 배포](#4-elasticsearch-배포)
5. [Kibana 배포](#5-kibana-배포)
6. [검증](#6-검증)
7. [트러블슈팅](#7-트러블슈팅)
8. [운영 가이드](#8-운영-가이드)

---

## 1. 이미지 로드 및 레지스트리 Push

### 1.1 tar 이미지 로드

```bash
cd elasticsearch-packages/images/

nerdctl load -i eck-operator.tar
nerdctl load -i es.tar
nerdctl load -i kibana.tar

# 로드된 이미지 확인
nerdctl images | grep -E "eck-operator|elasticsearch|kibana"
```

### 1.2 레지스트리 tag 및 push

로드된 이미지 이름을 확인한 뒤, 운영 환경 레지스트리 주소로 tag를 붙여 push합니다.

```bash
# 로드된 이미지 이름/태그 확인
nerdctl images | grep -E "eck-operator|elasticsearch|kibana"

# 운영 레지스트리 주소로 변경 (실제 주소 확인 후 적용)
REGISTRY="<운영-레지스트리-주소>"

nerdctl tag <eck-operator-image>  ${REGISTRY}/elasticsearch/eck-operator:2.16.1
nerdctl tag <elasticsearch-image> ${REGISTRY}/elasticsearch/elasticsearch:7.9.3
nerdctl tag <kibana-image>        ${REGISTRY}/elasticsearch/kibana:7.9.3

nerdctl push ${REGISTRY}/elasticsearch/eck-operator:2.16.1
nerdctl push ${REGISTRY}/elasticsearch/elasticsearch:7.9.3
nerdctl push ${REGISTRY}/elasticsearch/kibana:7.9.3
```

### 1.3 yaml 파일의 이미지 경로 수정

yaml 파일에 개발 환경 레지스트리 주소가 박혀 있으므로, 운영 레지스트리 주소로 교체합니다.

```bash
cd elasticsearch-packages/

# 현재 박힌 이미지 경로 확인
grep -r "image:" es/ kibana/

# 운영 레지스트리 주소로 일괄 치환 (sed 사용 예시)
OLD_REGISTRY="nexus.okestro-k8s.com:55000"
NEW_REGISTRY="<운영-레지스트리-주소>"

sed -i "s|${OLD_REGISTRY}|${NEW_REGISTRY}|g" es/operator.yaml
sed -i "s|${OLD_REGISTRY}|${NEW_REGISTRY}|g" es/elastic.yaml
sed -i "s|${OLD_REGISTRY}|${NEW_REGISTRY}|g" kibana/kibana.yaml

# 치환 결과 확인
grep -r "image:" es/ kibana/
```

### 1.3 레지스트리 TLS 검증 생략 (자체 서명 인증서인 경우)

K8s 워커 노드에서 pull이 실패하면 containerd에 아래 설정을 추가합니다. **스케줄되는 모든 워커 노드에 동일하게 적용해야 합니다.**

```bash
sudo mkdir -p /etc/containerd/certs.d/nexus.okestro-k8s.com:55000

sudo tee /etc/containerd/certs.d/nexus.okestro-k8s.com:55000/hosts.toml <<'EOF'
server = "https://nexus.okestro-k8s.com:55000"

[host."https://nexus.okestro-k8s.com:55000"]
  capabilities = ["pull", "resolve"]
  skip_verify = true
EOF

sudo systemctl restart containerd
```

---

## 2. 사전 준비 사항

### K8s 클러스터 요구사항

- Kubernetes 1.24+
- PersistentVolume 지원 (storageClassName: `klidcmp` — elastic.yaml에 지정됨)
- RBAC 활성화

### vm.max_map_count 설정 (ES Pod가 스케줄되는 모든 워커 노드)

```bash
sudo sysctl -w vm.max_map_count=262144
echo 'vm.max_map_count=262144' | sudo tee /etc/sysctl.d/99-elasticsearch.conf
sudo sysctl --system

# 확인
sysctl vm.max_map_count
```

> 미설정 시 ES가 `vm.max_map_count [65530] is too low` 오류로 기동 실패합니다.

---

## 3. ECK Operator 설치

```bash
cd elasticsearch-packages/es/

# 1) CRD 먼저 적용
kubectl apply -f crds.yaml

# 2) Operator 배포
kubectl apply -f operator.yaml

# 3) 상태 확인 (Running이 될 때까지 대기)
kubectl get pods -n elastic-system
kubectl logs -f -n elastic-system statefulset/elastic-operator
```

정상 출력:

```
NAME                 READY   STATUS    RESTARTS   AGE
elastic-operator-0   1/1     Running   0          2m
```

---

## 4. Elasticsearch 배포

```bash
cd elasticsearch-packages/es/

kubectl apply -f elastic.yaml

# 상태 확인 (HEALTH가 green이 될 때까지 수 분 소요)
kubectl get elasticsearch -n klid-cmp
kubectl get pods -n klid-cmp
```

정상 출력:

```
NAME                    HEALTH   NODES   VERSION   PHASE       AGE
elasticsearch-cluster   green    8       7.9.3     Available   5m
```

### 비밀번호 확인

```bash
kubectl get secret -n klid-cmp elasticsearch-cluster-es-elastic-user \
  -o jsonpath='{.data.elastic}' | base64 -d
```

### 비밀번호 변경

```bash
kubectl patch secret elasticsearch-cluster-es-elastic-user -n klid-cmp \
  -p '{"data":{"elastic":"'$(echo -n "새비밀번호" | base64)'"}}'
```

---

## 5. Kibana 배포

```bash
cd elasticsearch-packages/kibana/

kubectl apply -f kibana.yaml

# 상태 확인
kubectl get kibana -n klid-cmp
kubectl get pods -n klid-cmp -l kibana.k8s.elastic.co/name=kibana-dashboard
```

---

## 6. 검증

### 클러스터 상태 확인

```bash
# Port Forward
kubectl port-forward svc/elasticsearch-cluster-es-http 9200:9200 -n klid-cmp &

ELASTIC_PASSWORD=$(kubectl get secret -n klid-cmp elasticsearch-cluster-es-elastic-user \
  -o jsonpath='{.data.elastic}' | base64 -d)

# 클러스터 상태 (green 확인)
curl -k -u elastic:${ELASTIC_PASSWORD} https://localhost:9200/_cluster/health?pretty

# 노드 목록
curl -k -u elastic:${ELASTIC_PASSWORD} https://localhost:9200/_cat/nodes?v

# 디스크 사용량
curl -k -u elastic:${ELASTIC_PASSWORD} https://localhost:9200/_cat/allocation?v
```

---

## 7. 트러블슈팅

### Pod이 Pending 상태

```bash
kubectl describe pvc -n klid-cmp
kubectl get pv
```

PVC가 Pending이면 storageClass(`klidcmp`)가 존재하는지 확인합니다.

```bash
kubectl get storageclass
```

### ImagePullBackOff

```bash
kubectl describe pod <pod-name> -n klid-cmp
```

레지스트리 주소 오타 또는 인증 문제입니다. Step 1.3의 containerd 설정을 확인합니다.

### 클러스터 상태 Yellow/Red

```bash
# 마스터 확인
curl -k -u elastic:${ELASTIC_PASSWORD} https://localhost:9200/_cat/master?v

# 미할당 shard 원인 확인
curl -k -u elastic:${ELASTIC_PASSWORD} \
  "https://localhost:9200/_cluster/allocation/explain?pretty"
```

### OOM

```bash
kubectl top pods -n klid-cmp
```

`elastic.yaml`의 `ES_JAVA_OPTS` 힙 값과 `resources.limits.memory`를 확인합니다. (힙은 메모리 limit의 50% 권장)

### Operator 로그 확인

```bash
kubectl logs -n elastic-system statefulset/elastic-operator -f
kubectl logs -n elastic-system statefulset/elastic-operator | grep -i error
```

---

## 8. 운영 가이드

### 스케일링

`elastic.yaml`의 `count` 값 수정 후:

```bash
kubectl apply -f elastic.yaml
kubectl get pods -n klid-cmp -w
```

### ILM 정책 적용

ES 배포 후 인덱스 템플릿과 ILM 정책을 등록합니다. `es-ilm-1year-policy-guide.md` 참고.

```bash
# 클러스터 상태 GREEN 확인 후 진행
curl -k -u elastic:${ELASTIC_PASSWORD} \
  "https://localhost:9200/_cluster/health?pretty"
```

### 로그 확인

```bash
# Operator
kubectl logs -n elastic-system statefulset/elastic-operator -f

# ES 노드
kubectl logs -n klid-cmp elasticsearch-cluster-es-master-0 -f

# 전체
kubectl logs -n klid-cmp \
  -l elasticsearch.k8s.elastic.co/cluster-name=elasticsearch-cluster -f
```

### 인증서 만료일 확인

```bash
kubectl get secret -n klid-cmp elasticsearch-cluster-es-http-certs \
  -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -noout -enddate
```

ECK가 자동으로 인증서를 갱신합니다.
