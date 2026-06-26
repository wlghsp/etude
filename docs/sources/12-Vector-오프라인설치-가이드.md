# Vector 설치 가이드

> Prometheus remote_write 수신 → metric_to_log → reduce → Kafka(JSON) 파이프라인

---

## 동작 흐름

```
Prometheus remote_write
        ↓
   [filter]  메트릭명 필터링
        ↓
 [metric_to_log]  메트릭 → 로그 변환
        ↓
  [normalize]  VRL 스크립트로 필드 정규화 및 merge_key 생성
        ↓
   [reduce]  merge_key 기준으로 여러 시계열 샘플 병합
        ↓ (ends_when 조건 충족 또는 expire_after_ms 초과 시)
  [envelope]  VRL 스크립트로 최종 JSON 봉투 생성
        ↓
  [Kafka sink]  토픽별 전송 (container / node / vm)
```

---

## 목차

1. [Vector 설치](#1-vector-설치)
2. [systemd 서비스 설정](#2-systemd-서비스-설정)
3. [vector.yaml 설정](#3-vectoryaml-설정)
4. [VRL 스크립트](#4-vrl-스크립트)
5. [설정 파일 검증](#5-설정-파일-검증)
6. [서비스 시작](#6-서비스-시작)
7. [부록 — 주요 파일 경로 요약](#부록--주요-파일-경로-요약)

---

## 1. Vector 설치

### 압축 해제 및 디렉터리 구성

```bash
# 압축 풀기
tar -xvf vector-0.54.0-x86_64-unknown-linux-gnu.tar.gz

# 필요 디렉터리 생성
sudo mkdir -p /etc/vector
sudo mkdir -p /var/lib/vector
sudo mkdir -p /etc/vector/vrl/normalize/container
sudo mkdir -p /etc/vector/vrl/normalize/node
sudo mkdir -p /etc/vector/vrl/normalize/vm
sudo mkdir -p /etc/vector/vrl/normalize/osp-hypervisor
sudo mkdir -p /etc/vector/vrl/normalize/osp-vm
sudo mkdir -p /etc/vector/vrl/envelope/container
sudo mkdir -p /etc/vector/vrl/envelope/node
sudo mkdir -p /etc/vector/vrl/envelope/vm
sudo mkdir -p /etc/vector/vrl/envelope/osp-hypervisor
sudo mkdir -p /etc/vector/vrl/envelope/osp-vm
```

### 시스템 계정 생성

```bash
# vector 그룹 생성
sudo groupadd --system vector

# vector 유저 생성
sudo useradd --system --no-create-home --shell /bin/false --gid vector vector
```

### 바이너리 배치

```bash
cp /opt/vector/vector-0.54.0-x86_64-unknown-linux-gnu/bin/vector /usr/local/bin/
cp /opt/vector/vector-0.54.0-x86_64-unknown-linux-gnu/bin/vector /usr/bin/
```

### VRL 스크립트 배포

```bash
# 패키지의 vrl/ 디렉터리를 /etc/vector/vrl/ 로 복사
cp -r vrl/normalize/container/* /etc/vector/vrl/normalize/container/
cp -r vrl/normalize/node/*      /etc/vector/vrl/normalize/node/
cp -r vrl/normalize/vm/*        /etc/vector/vrl/normalize/vm/
cp -r vrl/normalize/osp-hypervisor/* /etc/vector/vrl/normalize/osp-hypervisor/
cp -r vrl/normalize/osp-vm/*    /etc/vector/vrl/normalize/osp-vm/
cp -r vrl/envelope/container/*  /etc/vector/vrl/envelope/container/
cp -r vrl/envelope/node/*       /etc/vector/vrl/envelope/node/
cp -r vrl/envelope/vm/*         /etc/vector/vrl/envelope/vm/
cp -r vrl/envelope/osp-hypervisor/* /etc/vector/vrl/envelope/osp-hypervisor/
cp -r vrl/envelope/osp-vm/*     /etc/vector/vrl/envelope/osp-vm/
```

### 권한 설정

```bash
sudo chown -R vector:vector /etc/vector
sudo chown vector:vector /var/lib/vector
sudo chown vector:vector /usr/local/bin/vector
sudo chown vector:vector /usr/bin/vector
```

---

## 2. systemd 서비스 설정

파일 경로: `/etc/systemd/system/vector.service`

```ini
[Unit]
Description=Vector observability data pipeline
Documentation=https://vector.dev/docs/
After=network-online.target prometheus.service
Wants=network-online.target

[Service]
Type=simple
User=vector
Group=vector

ExecStart=/usr/local/bin/vector \
  --config /etc/vector/vector.yaml

ExecReload=/bin/kill -HUP $MAINPID

Restart=always
RestartSec=5
TimeoutStopSec=120

LimitNOFILE=65535

# 비동기 워커 스레드 수
Environment="VECTOR_THREADS=2"

# Prometheus와 합산이 RAM을 넘지 않도록 조정
MemoryHigh=2G
MemoryMax=3G

# 보안 하드닝
NoNewPrivileges=true
PrivateTmp=true
ProtectHome=true
ProtectSystem=strict
ReadWritePaths=/var/lib/vector
ReadOnlyPaths=/etc/vector

# 로그 출력
StandardOutput=journal
StandardError=journal
SyslogIdentifier=vector

[Install]
WantedBy=multi-user.target
```

---

## 3. vector.yaml 설정

파일 경로: `/etc/vector/vector.yaml`

> **파이프라인 구조**
> - `sources` → `prom_rw` : Prometheus remote_write 수신 (127.0.0.1:9093)
> - `transforms` : 메트릭명별 filter → metric_to_log → normalize → reduce → envelope
> - `sinks` : Kafka 토픽별 전송 (container / node / vm)

```yaml
data_dir: /var/lib/vector

# ── Sources ───────────────────────────────────────────────────────────────────
sources:
  prom_rw:
    type: prometheus_remote_write
    address: 127.0.0.1:9093
    path: /api/v1/write

# ── Transforms ────────────────────────────────────────────────────────────────
transforms:

  # ============================================================
  # Container (Kubernetes Pod)
  # ============================================================
  filter_container:
    type: filter
    inputs: [prom_rw]
    condition:
      type: vrl
      source: |
        m = string!(.name)
        m == "kubernetes_pod_resource_usage_node_pct"

  pod_metric_to_log:
    type: metric_to_log
    inputs: [filter_container]

  pod_normalize:
    type: remap
    inputs: [pod_metric_to_log]
    file: /etc/vector/vrl/normalize/container/openshift-container-normalize.vrl

  pod_reduce:
    type: reduce
    inputs: [pod_normalize]
    group_by:
      - merge_key
    expire_after_ms: 20000
    ends_when:
      type: vrl
      source: |
        a = to_float(.sym_cpu) ?? -1.0
        b = to_float(.sym_mem) ?? -1.0
        a >= 0.0 && b >= 0.0
    merge_strategies:
      merge_key:  discard
      merge_ts:   discard
      center:     discard
      zone:       discard
      cluster:    discard
      pod_uid:    discard
      node_name:  discard
      pod_name:   discard
      namespace:  discard
      sym_cpu:    max
      sym_mem:    max

  pod_envelope:
    type: remap
    inputs: [pod_reduce]
    file: /etc/vector/vrl/envelope/container/openshift-metric-container-envelope.vrl

  # ============================================================
  # Kubernetes Node — filter
  # ============================================================
  filter_node_cpu:
    type: filter
    inputs: [prom_rw]
    condition:
      type: vrl
      source: |
        m = string!(.name)
        m == "system_kubernetes_node_cpu"

  filter_node_memory:
    type: filter
    inputs: [prom_rw]
    condition:
      type: vrl
      source: |
        m = string!(.name)
        m == "system_kubernetes_node_memory"

  filter_node_diskio:
    type: filter
    inputs: [prom_rw]
    condition:
      type: vrl
      source: |
        m = string!(.name)
        m == "system_kubernetes_node_diskio"

  filter_node_filesystem:
    type: filter
    inputs: [prom_rw]
    condition:
      type: vrl
      source: |
        m = string!(.name)
        m == "system_kubernetes_node_filesystem"

  filter_node_network:
    type: filter
    inputs: [prom_rw]
    condition:
      type: vrl
      source: |
        m = string!(.name)
        m == "system_kubernetes_node_network"

  # ── Node: metric_to_log ──────────────────────────────────────
  m2l_node_cpu:        { type: metric_to_log, inputs: [filter_node_cpu] }
  m2l_node_memory:     { type: metric_to_log, inputs: [filter_node_memory] }
  m2l_node_diskio:     { type: metric_to_log, inputs: [filter_node_diskio] }
  m2l_node_filesystem: { type: metric_to_log, inputs: [filter_node_filesystem] }
  m2l_node_network:    { type: metric_to_log, inputs: [filter_node_network] }

  # ── Node: normalize ──────────────────────────────────────────
  node_normalize_cpu:
    type: remap
    inputs: [m2l_node_cpu]
    file: /etc/vector/vrl/normalize/node/openshift-node-normalize-cpu.vrl

  node_normalize_memory:
    type: remap
    inputs: [m2l_node_memory]
    file: /etc/vector/vrl/normalize/node/openshift-node-normalize-memory.vrl

  node_normalize_diskio:
    type: remap
    inputs: [m2l_node_diskio]
    file: /etc/vector/vrl/normalize/node/openshift-node-normalize-diskio.vrl

  node_normalize_filesystem:
    type: remap
    inputs: [m2l_node_filesystem]
    file: /etc/vector/vrl/normalize/node/openshift-node-normalize-filesystem.vrl

  node_normalize_network:
    type: remap
    inputs: [m2l_node_network]
    file: /etc/vector/vrl/normalize/node/openshift-node-normalize-network.vrl

  # ── Node: reduce ─────────────────────────────────────────────
  node_reduce_cpu:
    type: reduce
    inputs: [node_normalize_cpu]
    group_by: [merge_key]
    expire_after_ms: 20000
    ends_when:
      type: vrl
      source: |
        a = to_float(.sym_total)  ?? -1.0
        b = to_float(.sym_iowait) ?? -1.0
        c = to_float(.sym_cores)  ?? -1.0
        a >= 0.0 && b >= 0.0 && c >= 0.0
    merge_strategies:
      merge_key:     discard
      merge_ts:      discard
      center:        discard
      zone:          discard
      cluster:       discard
      node_uid:      discard
      node_hostname: discard
      sym_total:     max
      sym_iowait:    max
      sym_cores:     max

  node_reduce_memory:
    type: reduce
    inputs: [node_normalize_memory]
    group_by: [merge_key]
    expire_after_ms: 20000
    ends_when:
      type: vrl
      source: |
        a = to_float(.sym_mem_used)       ?? -1.0
        b = to_float(.sym_actual_free)    ?? -1.0
        c = to_float(.sym_actual_used_pct) ?? -1.0
        d = to_float(.sym_swap_pct)       ?? -1.0
        a >= 0.0 && b >= 0.0 && c >= 0.0 && d >= 0.0
    merge_strategies:
      merge_key:          discard
      merge_ts:           discard
      center:             discard
      zone:               discard
      cluster:            discard
      node_uid:           discard
      node_hostname:      discard
      sym_mem_used:       max
      sym_actual_free:    max
      sym_actual_used_pct: max
      sym_swap_pct:       max

  node_reduce_diskio:
    type: reduce
    inputs: [node_normalize_diskio]
    group_by: [merge_key]
    expire_after_ms: 20000
    ends_when:
      type: vrl
      source: |
        a = to_float(.sym_read)  ?? -1.0
        b = to_float(.sym_write) ?? -1.0
        a >= 0.0 && b >= 0.0
    merge_strategies:
      merge_key:     discard
      merge_ts:      discard
      center:        discard
      zone:          discard
      cluster:       discard
      node_uid:      discard
      node_hostname: discard
      sym_read:      max
      sym_write:     max

  node_reduce_filesystem:
    type: reduce
    inputs: [node_normalize_filesystem]
    group_by: [merge_key]
    expire_after_ms: 20000
    merge_strategies:
      merge_key:     discard
      merge_ts:      discard
      center:        discard
      zone:          discard
      cluster:       discard
      node_uid:      discard
      node_hostname: discard
      fs_type:       discard
      sym_fs_pct:    max

  node_reduce_network:
    type: reduce
    inputs: [node_normalize_network]
    group_by: [merge_key]
    expire_after_ms: 20000
    ends_when:
      type: vrl
      source: |
        a = to_float(.sym_in)  ?? -1.0
        b = to_float(.sym_out) ?? -1.0
        a >= 0.0 && b >= 0.0
    merge_strategies:
      merge_key:     discard
      merge_ts:      discard
      center:        discard
      zone:          discard
      cluster:       discard
      node_uid:      discard
      node_hostname: discard
      net_iface:     discard
      sym_in:        max
      sym_out:       max

  # ── Node: envelope ───────────────────────────────────────────
  node_envelope_cpu:
    type: remap
    inputs: [node_reduce_cpu]
    drop_on_error: true
    file: /etc/vector/vrl/envelope/node/openshift-metric-node-envelope-cpu.vrl

  node_envelope_memory:
    type: remap
    inputs: [node_reduce_memory]
    drop_on_error: true
    file: /etc/vector/vrl/envelope/node/openshift-metric-node-envelope-memory.vrl

  node_envelope_diskio:
    type: remap
    inputs: [node_reduce_diskio]
    drop_on_error: true
    file: /etc/vector/vrl/envelope/node/openshift-metric-node-envelope-diskio.vrl

  node_envelope_filesystem:
    type: remap
    inputs: [node_reduce_filesystem]
    drop_on_error: true
    file: /etc/vector/vrl/envelope/node/openshift-metric-node-envelope-filesystem.vrl

  node_envelope_network:
    type: remap
    inputs: [node_reduce_network]
    drop_on_error: true
    file: /etc/vector/vrl/envelope/node/openshift-metric-node-envelope-network.vrl

  # ============================================================
  # KubeVirt VM — filter
  # ============================================================
  filter_vm_cpu:
    type: filter
    inputs: [prom_rw]
    condition:
      type: vrl
      source: |
        m = string!(.name)
        m == "system_kubevirt_vm_cpu"

  filter_vm_memory:
    type: filter
    inputs: [prom_rw]
    condition:
      type: vrl
      source: |
        m = string!(.name)
        m == "system_kubevirt_vm_memory"

  filter_vm_diskio:
    type: filter
    inputs: [prom_rw]
    condition:
      type: vrl
      source: |
        m = string!(.name)
        m == "system_kubevirt_vm_diskio"

  filter_vm_filesystem:
    type: filter
    inputs: [prom_rw]
    condition:
      type: vrl
      source: |
        m = string!(.name)
        m == "system_kubevirt_vm_filesystem"

  filter_vm_network:
    type: filter
    inputs: [prom_rw]
    condition:
      type: vrl
      source: |
        m = string!(.name)
        m == "system_kubevirt_vm_network"

  # ── VM: metric_to_log ────────────────────────────────────────
  m2l_vm_cpu:        { type: metric_to_log, inputs: [filter_vm_cpu] }
  m2l_vm_memory:     { type: metric_to_log, inputs: [filter_vm_memory] }
  m2l_vm_diskio:     { type: metric_to_log, inputs: [filter_vm_diskio] }
  m2l_vm_filesystem: { type: metric_to_log, inputs: [filter_vm_filesystem] }
  m2l_vm_network:    { type: metric_to_log, inputs: [filter_vm_network] }

  # ── VM: normalize ────────────────────────────────────────────
  vm_normalize_cpu:
    type: remap
    inputs: [m2l_vm_cpu]
    file: /etc/vector/vrl/normalize/vm/openshift-vm-normalize-cpu.vrl

  vm_normalize_memory:
    type: remap
    inputs: [m2l_vm_memory]
    file: /etc/vector/vrl/normalize/vm/openshift-vm-normalize-memory.vrl

  vm_normalize_diskio:
    type: remap
    inputs: [m2l_vm_diskio]
    file: /etc/vector/vrl/normalize/vm/openshift-vm-normalize-diskio.vrl

  vm_normalize_filesystem:
    type: remap
    inputs: [m2l_vm_filesystem]
    file: /etc/vector/vrl/normalize/vm/openshift-vm-normalize-filesystem.vrl

  vm_normalize_network:
    type: remap
    inputs: [m2l_vm_network]
    file: /etc/vector/vrl/normalize/vm/openshift-vm-normalize-network.vrl

  # ── VM: reduce ───────────────────────────────────────────────
  vm_reduce_cpu:
    type: reduce
    inputs: [vm_normalize_cpu]
    group_by: [merge_key]
    expire_after_ms: 20000
    ends_when:
      type: vrl
      source: |
        a = to_float(.sym_total)  ?? -1.0
        b = to_float(.sym_iowait) ?? -1.0
        c = to_float(.sym_cores)  ?? -1.0
        a >= 0.0 && b >= 0.0 && c >= 0.0
    merge_strategies:
      merge_key:    discard
      merge_ts:     discard
      center:       discard
      zone:         discard
      cluster:      discard
      vm_uid:       discard
      vm_hostname:  discard
      vm_namespace: discard
      sym_total:    max
      sym_iowait:   max
      sym_cores:    max

  vm_reduce_memory:
    type: reduce
    inputs: [vm_normalize_memory]
    group_by: [merge_key]
    expire_after_ms: 20000
    ends_when:
      type: vrl
      source: |
        a = to_float(.sym_mem_used)        ?? -1.0
        b = to_float(.sym_actual_free)     ?? -1.0
        c = to_float(.sym_actual_used_pct) ?? -1.0
        d = to_float(.sym_swap_pct)        ?? -1.0
        a >= 0.0 && b >= 0.0 && c >= 0.0 && d >= 0.0
    merge_strategies:
      merge_key:           discard
      merge_ts:            discard
      center:              discard
      zone:                discard
      cluster:             discard
      vm_uid:              discard
      vm_hostname:         discard
      vm_namespace:        discard
      sym_mem_used:        max
      sym_actual_free:     max
      sym_actual_used_pct: max
      sym_swap_pct:        max

  vm_reduce_diskio:
    type: reduce
    inputs: [vm_normalize_diskio]
    group_by: [merge_key]
    expire_after_ms: 20000
    ends_when:
      type: vrl
      source: |
        a = to_float(.sym_read)  ?? -1.0
        b = to_float(.sym_write) ?? -1.0
        a >= 0.0 && b >= 0.0
    merge_strategies:
      merge_key:    discard
      merge_ts:     discard
      center:       discard
      zone:         discard
      cluster:      discard
      vm_uid:       discard
      vm_hostname:  discard
      vm_namespace: discard
      sym_read:     max
      sym_write:    max

  vm_reduce_filesystem:
    type: reduce
    inputs: [vm_normalize_filesystem]
    group_by: [merge_key]
    expire_after_ms: 20000
    merge_strategies:
      merge_key:    discard
      merge_ts:     discard
      center:       discard
      zone:         discard
      cluster:      discard
      vm_uid:       discard
      vm_hostname:  discard
      vm_namespace: discard
      fs_type:      discard
      sym_fs_pct:   max

  vm_reduce_network:
    type: reduce
    inputs: [vm_normalize_network]
    group_by: [merge_key]
    expire_after_ms: 20000
    ends_when:
      type: vrl
      source: |
        a = to_float(.sym_in)  ?? -1.0
        b = to_float(.sym_out) ?? -1.0
        a >= 0.0 && b >= 0.0
    merge_strategies:
      merge_key:    discard
      merge_ts:     discard
      center:       discard
      zone:         discard
      cluster:      discard
      vm_uid:       discard
      vm_hostname:  discard
      vm_namespace: discard
      sym_in:       max
      sym_out:      max

  # ── VM: envelope ─────────────────────────────────────────────
  vm_envelope_cpu:
    type: remap
    inputs: [vm_reduce_cpu]
    drop_on_error: true
    file: /etc/vector/vrl/envelope/vm/openshift-metric-vm-envelope-cpu.vrl

  vm_envelope_memory:
    type: remap
    inputs: [vm_reduce_memory]
    drop_on_error: true
    file: /etc/vector/vrl/envelope/vm/openshift-metric-vm-envelope-memory.vrl

  vm_envelope_diskio:
    type: remap
    inputs: [vm_reduce_diskio]
    drop_on_error: true
    file: /etc/vector/vrl/envelope/vm/openshift-metric-vm-envelope-diskio.vrl

  vm_envelope_filesystem:
    type: remap
    inputs: [vm_reduce_filesystem]
    drop_on_error: true
    file: /etc/vector/vrl/envelope/vm/openshift-metric-vm-envelope-filesystem.vrl

  vm_envelope_network:
    type: remap
    inputs: [vm_reduce_network]
    drop_on_error: true
    file: /etc/vector/vrl/envelope/vm/openshift-metric-vm-envelope-network.vrl

# ── Sinks ─────────────────────────────────────────────────────────────────────
sinks:

  kafka_container:
    type: kafka
    inputs: [pod_envelope]
    bootstrap_servers: "172.30.1.53:9092,172.30.1.54:9092,172.30.1.55:9092"
    topic: openshift-metric-container
    encoding:
      codec: json
    compression: snappy
    acknowledgements: true
    batch:
      max_events: 500
      timeout_secs: 1.0
    buffer:
      type: disk
      max_size: 402653184   # 384 MiB
      when_full: block

  kafka_node:
    type: kafka
    inputs:
      - node_envelope_cpu
      - node_envelope_memory
      - node_envelope_diskio
      - node_envelope_filesystem
      - node_envelope_network
    bootstrap_servers: "172.30.1.53:9092,172.30.1.54:9092,172.30.1.55:9092"
    topic: openshift-metric-node
    encoding:
      codec: json
    compression: snappy
    acknowledgements: true
    batch:
      max_events: 500
      timeout_secs: 1.0
    buffer:
      type: disk
      max_size: 402653184
      when_full: block

  kafka_vm:
    type: kafka
    inputs:
      - vm_envelope_cpu
      - vm_envelope_memory
      - vm_envelope_diskio
      - vm_envelope_filesystem
      - vm_envelope_network
    bootstrap_servers: "172.30.1.53:9092,172.30.1.54:9092,172.30.1.55:9092"
    topic: openshift-metric-vm
    encoding:
      codec: json
    compression: snappy
    acknowledgements: true
    batch:
      max_events: 500
      timeout_secs: 1.0
    buffer:
      type: disk
      max_size: 402653184
      when_full: block
```

---

## 4. VRL 스크립트

### 5-1. Container Normalize

파일 경로: `/etc/vector/vrl/normalize/container/openshift-container-normalize.vrl`

> `kubernetes_pod_resource_usage_node_pct{resource="cpu"|"memory"}` 시계열을 정규화하여  
> reduce용 공통 키(`merge_key`)와 심볼 필드(`sym_cpu`, `sym_mem`)를 생성합니다.

```vrl
# Pod/컨테이너 recording rule → reduce용 공통 키 생성
# merge_key: center::zone::cluster::namespace::pod_uid 로 CPU+메모리 샘플을 한 건으로 합침
tags = object!(.tags)

center  = string(tags.center)    ?? ""
zone    = string(tags.zone)      ?? ""
cluster = string(tags.cluster)   ?? ""
ns      = string(tags.namespace) ?? ""
pod     = string(tags.pod)       ?? ""
pu      = string(tags.uid)       ?? ""

# uid가 없으면 namespace::pod 를 대체 키로 사용
pk = if pu != "" { pu } else { join!([ns, "::", pod]) }

.merge_key = join!([center, "::", zone, "::", cluster, "::", ns, "::", pk])
.merge_ts  = format_timestamp!(.timestamp, "%Y-%m-%dT%H:%M:%S%.3fZ")
.center    = center
.zone      = zone
.cluster   = cluster
.pod_uid   = pu
.node_name = string(tags.node) ?? ""
.pod_name  = pod
.namespace = ns

res = string(tags.resource) ?? ""
v   = to_float(.gauge.value) ?? to_float(.gauge) ?? to_float(.counter.value) ?? to_float(.counter) ?? -1.0

if res == "cpu" {
  .sym_cpu = v
  .sym_mem = -1.0
} else if res == "memory" {
  .sym_cpu = -1.0
  .sym_mem = v
} else {
  abort
}

del(.name)
del(.tags)
del(.gauge)
del(.kind)
if exists(.counter) { del(.counter) }
```

### 5-2. Container Envelope

파일 경로: `/etc/vector/vrl/envelope/container/openshift-metric-container-envelope.vrl`

> reduce 완료된 이벤트를 Kafka 전송용 KUBERNETES 봉투 JSON으로 변환합니다.

```vrl
cpu = to_float(.sym_cpu) ?? -1.0
mem = to_float(.sym_mem) ?? -1.0

cpu_pct = if cpu < 0.0 { 0.0 } else { cpu }
mem_pct = if mem < 0.0 { 0.0 } else { mem }

ns = string!(.namespace)
nn = string!(.node_name)
pu = string!(.pod_uid)
pn = string!(.pod_name)
ts = string!(.merge_ts)

k8s = {
  "pod": {
    "uid":    pu,
    "name":   pn,
    "cpu":    { "usage": { "node": { "pct": cpu_pct } } },
    "memory": { "usage": { "node": { "pct": mem_pct } } }
  },
  "node":      { "name": nn },
  "namespace": ns
}

. = {
  "type":      "KUBERNETES",
  "datatype":  "metric",
  "timestamp": ts,
  "kubernetes": k8s
}
```

---

## 5. 설정 파일 검증

```bash
# vector.yaml 전체 설정 검증
vector validate /etc/vector/vector.yaml

# 명시적으로 yaml 형식 지정
vector validate --config-yaml /etc/vector/vector.yaml

# 특정 VRL 스크립트 단독 검증
vector vrl /etc/vector/vrl/normalize/container/openshift-container-normalize.vrl
```

---

## 6. 서비스 시작

```bash
systemctl daemon-reload
systemctl enable vector.service
systemctl start vector.service
systemctl status vector.service
```

---

## 부록 — 주요 파일 경로 요약

| 구분 | 경로 |
|------|------|
| 바이너리 | `/usr/local/bin/vector`, `/usr/bin/vector` |
| 설정 파일 | `/etc/vector/vector.yaml` |
| VRL 루트 | `/etc/vector/vrl/` |
| Container normalize | `/etc/vector/vrl/normalize/container/` |
| Node normalize | `/etc/vector/vrl/normalize/node/` |
| VM normalize | `/etc/vector/vrl/normalize/vm/` |
| OSP Hypervisor normalize | `/etc/vector/vrl/normalize/osp-hypervisor/` |
| OSP VM normalize | `/etc/vector/vrl/normalize/osp-vm/` |
| Container envelope | `/etc/vector/vrl/envelope/container/` |
| Node envelope | `/etc/vector/vrl/envelope/node/` |
| VM envelope | `/etc/vector/vrl/envelope/vm/` |
| OSP Hypervisor envelope | `/etc/vector/vrl/envelope/osp-hypervisor/` |
| OSP VM envelope | `/etc/vector/vrl/envelope/osp-vm/` |
| 데이터 저장소 | `/var/lib/vector` |
| systemd 서비스 | `/etc/systemd/system/vector.service` |

### Kafka 토픽 요약

| 토픽 | 데이터 |
|------|--------|
| `openshift-metric-container` | Kubernetes Pod CPU/Memory |
| `openshift-metric-node` | Kubernetes Node CPU/Memory/DiskIO/Filesystem/Network |
| `openshift-metric-vm` | KubeVirt VM CPU/Memory/DiskIO/Filesystem/Network |
