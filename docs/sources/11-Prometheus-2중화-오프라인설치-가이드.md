# Prometheus 설치 가이드

> OpenShift 연동 Federation 기반 모니터링 구성

---

## 동작 흐름

```
OpenShift Prometheus (/federate)
        │  HTTPS + Bearer Token / scrape_interval: 25s
        ▼
[scrape_configs]  메트릭 수집 (Pod / Node / VM)
        │  metric_relabel_configs — 불필요 라벨 제거, cgroup 시계열 drop
        ▼
[TSDB]  로컬 저장 (/var/lib/prometheus, retention 2h / 2GB)
        │  evaluation_interval: 25s
        ▼
[Recording Rules]  정상 리소스만 조인하여 집계 시계열 생성
        │  · Running Pod  → kubernetes_pod_resource_usage_node_pct
        │  · Ready Node   → system_kubernetes_node_{cpu|memory|fs|diskio|network}
        │  · Running VM   → system_kubevirt_vm_{cpu|memory|fs|diskio|network}
        ▼
[remote_write]  집계 시계열만 필터(keep) 후 Vector로 전송
        │  http://127.0.0.1:9093/api/v1/write
        ▼
Vector 파이프라인 (normalize → reduce → envelope → Kafka)
```

---

## 목차

1. [NTP 시간 동기화 확인](#1-ntp-시간-동기화-확인)
2. [Prometheus 설치](#2-prometheus-설치)
3. [systemd 서비스 설정](#3-systemd-서비스-설정)
4. [prometheus.yml 설정](#4-prometheusyml-설정)
5. [Recording Rules 설정](#5-recording-rules-설정)
6. [File SD 설정](#6-file-sd-설정)
7. [OpenShift API 토큰 설정](#7-openshift-api-토큰-설정)
8. [설정 파일 검증](#8-설정-파일-검증)
9. [서비스 시작](#9-서비스-시작)
10. [PromQL 동작 확인](#10-promql-동작-확인)
11. [Recording Rule 확인 명령어](#11-recording-rule-확인-명령어)

---

## 1. NTP 시간 동기화 확인

> system time과 RTC time이 일치해야 합니다.  
> 불일치 시 스크랩 타임스탬프가 틀어지고, Prometheus 평가 시작 시 타임스탬프 간 불일치가 발생합니다.

**chrony 동기화 상태 확인**

```bash
chronyc tracking
```

정상 출력 예시:

```
Reference ID    : [NTP서버IP]
System time     : 0.000xxx seconds fast of NTP time   ← 수십ms 이내
RMS offset      : 0.000xxx seconds
Frequency       : xx.xxx ppm slow
Leap status     : Normal
```

**NTP 동기화 여부 확인**

```bash
timedatectl show | grep Synchronized
# NTPSynchronized=yes  ← 이 값이 yes여야 정상
```

---

## 2. Prometheus 설치

### 압축 해제 및 디렉터리 구성

```bash
# 압축 풀기
tar -xvf prometheus-2.53.3.linux-amd64.tar.gz

# 필요 디렉터리 생성
sudo mkdir -p /etc/prometheus
sudo mkdir -p /etc/prometheus/rules
sudo mkdir -p /etc/prometheus/secrets
sudo mkdir -p /var/lib/prometheus
```

### 시스템 계정 생성

```bash
# prometheus 그룹 생성
sudo groupadd --system prometheus

# prometheus 유저 생성
sudo useradd --system --no-create-home --shell /bin/false --gid prometheus prometheus

# (필요 시) 유저명 변경
sudo usermod -l prometheus prometheus
```

### 바이너리 및 리소스 파일 배치

```bash
cp /opt/prometheus/prometheus-2.53.3.linux-amd64/prometheus /usr/local/bin/
cp /opt/prometheus/prometheus-2.53.3.linux-amd64/promtool /usr/local/bin/
cp -r /opt/prometheus/prometheus-2.53.3.linux-amd64/consoles/ /etc/prometheus/
cp -r /opt/prometheus/prometheus-2.53.3.linux-amd64/console_libraries/ /etc/prometheus/
```

### 권한 설정

```bash
sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown -R prometheus:prometheus /var/lib/prometheus
sudo chown -R prometheus:prometheus /usr/local/bin/prometheus
sudo chown -R prometheus:prometheus /usr/local/bin/promtool
```

---

## 3. systemd 서비스 설정

파일 경로: `/etc/systemd/system/prometheus.service`

```ini
[Unit]
Description=Prometheus monitoring server
Documentation=https://prometheus.io/docs/introduction/overview/
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus

ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --web.listen-address=0.0.0.0:9090 \
  --web.enable-lifecycle \
  --storage.tsdb.retention.time=2h \
  --storage.tsdb.retention.size=2GB \
  --storage.tsdb.min-block-duration=2h \
  --storage.tsdb.max-block-duration=2h \
  --storage.tsdb.wal-compression \
  --enable-feature=no-default-scrape-port

ExecReload=/bin/kill -HUP $MAINPID

Restart=always
RestartSec=5
TimeoutStopSec=120

# 파일 디스크립터 (스크랩/페더 대상이 많으면 증가)
LimitNOFILE=65535

# 10개 클러스터 기준 메모리 튜닝
Environment="GOGC=50"
Environment="GOMEMLIMIT=3840MiB"

# 메모리 상한 (8GB 중 Vector·OS 여유 확보)
MemoryHigh=3G
MemoryMax=4G

# CPU 상한 (필요 시 주석 해제 후 조정)
# CPUQuota=300%

# 보안 하드닝 (Rocky 9 기준)
NoNewPrivileges=true
PrivateTmp=true
ProtectHome=true
ProtectSystem=strict
ReadWritePaths=/var/lib/prometheus
ReadOnlyPaths=/etc/prometheus

# 로그 출력
StandardOutput=journal
StandardError=journal
SyslogIdentifier=prometheus

[Install]
WantedBy=multi-user.target
```

---

## 4. prometheus.yml 설정

파일 경로: `/etc/prometheus/prometheus.yml`

> Recording rules에서 사용하는 `center`, `zone`, `cluster` 라벨은  
> `file_sd` targets의 labels 또는 `static_configs`의 labels를 통해 시계열에 전달됩니다.  
> `honor_labels: true` 페더레이션에서 원격과 충돌하지 않으면 시계열에 유지됩니다.

```yaml
global:
  scrape_interval: 25s
  evaluation_interval: 25s

storage:
  tsdb:
    out_of_order_time_window: 2m

rule_files:
  - /etc/prometheus/rules/prometheus-rules.yml

scrape_configs:

  # ── 1) Kubernetes Pod ──────────────────────────────────────────────────────
  - job_name: ocp-federate-k8s-pods
    honor_labels: true
    scrape_interval: 25s
    scrape_timeout: 24s
    metrics_path: /federate
    scheme: https
    tls_config:
      insecure_skip_verify: true
    params:
      match[]:
        # 컨테이너 CPU/Memory 사용량 (init·pause 컨테이너 제외)
        - '{__name__=~"container_cpu_usage_seconds_total|container_memory_working_set_bytes", container!="", container!="POD"}'
        # 리소스 제한값 (CPU/Memory Limits)
        - '{__name__="kube_pod_container_resource_limits"}'
        # Running 상태 파드만 수집
        - '{__name__="kube_pod_status_phase", phase="Running"}'
        # 노드 정보가 할당된 유효 파드 메타데이터
        - '{__name__="kube_pod_info", node!=""}'
    static_configs:
      - targets:
          - prometheus-k8s-federate-openshift-monitoring.apps.ocp4.nirs.go.kr
        labels:
          center: main-center
          zone: zone-a
          cluster: ocp-cluster
    authorization:
      type: Bearer
      credentials_file: /etc/prometheus/secrets/ocp-prometheus.token
    metric_relabel_configs:
      # cadvisor cgroup 레벨 시계열 제거 (same-timestamp 충돌 방지)
      - source_labels: [container]
        regex: ''
        action: drop
      # recording rule에서 사용하는 라벨만 유지
      - action: labelkeep
        regex: ^(__name__|center|zone|cluster|namespace|pod|container|resource|uid|node|phase)$

  # ── 2) Kubernetes Node ─────────────────────────────────────────────────────
  - job_name: ocp-federate-k8s-nodes
    honor_labels: true
    scrape_interval: 25s
    scrape_timeout: 24s
    metrics_path: /federate
    scheme: https
    tls_config:
      insecure_skip_verify: true
    params:
      match[]:
        # CPU (idle/iowait 모드만)
        - '{__name__="node_cpu_seconds_total", mode=~"idle|iowait"}'
        # Memory
        - '{__name__=~"node_memory_MemTotal_bytes|node_memory_MemAvailable_bytes|node_memory_MemFree_bytes|node_memory_SwapTotal_bytes|node_memory_SwapFree_bytes"}'
        # Network (lo·가상 NIC 제외)
        - '{__name__=~"node_network_receive_bytes_total|node_network_transmit_bytes_total", device!~"lo|veth.*|tun.*|ovs.*|genev.*|br.*"}'
        # Filesystem (tmpfs·ramfs 제외)
        - '{__name__=~"node_filesystem_size_bytes|node_filesystem_avail_bytes", fstype=~"xfs|ext4", mountpoint!=""}'
        # DiskIO
        - '{__name__=~"node_disk_read_bytes_total|node_disk_written_bytes_total"}'
        # 노드 호스트명 메타 (nodename 조인용)
        - '{__name__="node_uname_info"}'
        # Ready 상태 노드만 수집
        - '{__name__="kube_node_status_condition", condition="Ready", status="true", node!=""}'
    static_configs:
      - targets:
          - prometheus-k8s-federate-openshift-monitoring.apps.ocp4.nirs.go.kr
        labels:
          center: main-center
          zone: zone-a
          cluster: ocp-cluster
    authorization:
      type: Bearer
      credentials_file: /etc/prometheus/secrets/ocp-prometheus.token
    metric_relabel_configs:
      - action: labelkeep
        regex: ^(__name__|center|zone|cluster|instance|nodename|node|condition|status|device|fstype|mountpoint|cpu|mode)$

  # ── 3) KubeVirt VM ────────────────────────────────────────────────────────
  - job_name: ocp-federate-kubevirt-vms
    honor_labels: true
    scrape_interval: 25s
    scrape_timeout: 24s
    metrics_path: /federate
    scheme: https
    tls_config:
      insecure_skip_verify: true
    params:
      match[]:
        # CPU
        - '{__name__=~"kubevirt_vmi_vcpu_seconds_total|kubevirt_vmi_vcpu_wait_seconds_total"}'
        # Memory
        - '{__name__=~"kubevirt_vmi_memory_resident_bytes|kubevirt_vmi_memory_domain_bytes|kubevirt_vmi_memory_swap_traffic_bytes_total"}'
        # Network
        - '{__name__=~"kubevirt_vmi_network_receive_bytes_total|kubevirt_vmi_network_transmit_bytes_total"}'
        # Storage
        - '{__name__=~"kubevirt_vmi_storage_read_traffic_bytes_total|kubevirt_vmi_storage_write_traffic_bytes_total"}'
        # Filesystem
        - '{__name__=~"kubevirt_vmi_filesystem_used_bytes|kubevirt_vmi_filesystem_capacity_bytes"}'
        # 실행 중인 VM만 수집
        - '{__name__="kubevirt_vmi_info", phase="running"}'
    static_configs:
      - targets:
          - prometheus-k8s-federate-openshift-monitoring.apps.ocp4.nirs.go.kr
        labels:
          center: main-center
          zone: zone-a
          cluster: ocp-cluster
    authorization:
      type: Bearer
      credentials_file: /etc/prometheus/secrets/ocp-prometheus.token
    metric_relabel_configs:
      - action: labelkeep
        regex: ^(__name__|center|zone|cluster|namespace|name|interface|mount_point|id|drive|disk_name|file_system_type|phase)$

# ── Remote Write ──────────────────────────────────────────────────────────────
remote_write:
  - url: "http://127.0.0.1:9093/api/v1/write"
    remote_timeout: 60s
    queue_config:
      capacity: 20000
      max_shards: 70
      min_shards: 5
      max_samples_per_send: 4000
      batch_send_deadline: 1s
      min_backoff: 30ms
      max_backoff: 2s
    write_relabel_configs:
      - source_labels: [__name__]
        regex: >-
          kubernetes_pod_resource_usage_node_pct|
          system_kubernetes_node_cpu|system_kubernetes_node_memory|
          system_kubernetes_node_filesystem|system_kubernetes_node_diskio|
          system_kubernetes_node_network|
          system_kubevirt_vm_cpu|system_kubevirt_vm_memory|
          system_kubevirt_vm_filesystem|system_kubevirt_vm_diskio|
          system_kubevirt_vm_network
        action: keep
```

---

## 5. Recording Rules 설정

파일 경로: `/etc/prometheus/rules/prometheus-rules.yml`

### 6-1. system_kubernetes_node 그룹

> `(center, zone, cluster, instance)` 기준 조인.  
> `kube_node_status_condition{condition="Ready", status="true"}` 으로 정상 노드만 처리.

```yaml
groups:
  - name: system_kubernetes_node
    interval: 25s
    rules:
      # Ready 노드의 nodename 매핑 테이블
      - record: system_kubernetes_node_info
        expr: |
          max by (center, zone, cluster, instance, nodename) (
            node_uname_info
            * on (center, zone, cluster, instance)
              group_left()
              max by (center, zone, cluster, instance) (
                label_replace(
                  max by (center, zone, cluster, node) (kube_node_status_condition),
                  "instance", "$1", "node", "(.+)"
                )
              )
          )

      - record: system_kubernetes_node_cpu
        expr: |
          label_replace(
            floor(
              (
                100 * (1 - avg without (cpu, mode) (rate(node_cpu_seconds_total{mode="idle"}[2m])))
                * on (center, zone, cluster, instance) group_left (nodename)
                  max by (center, zone, cluster, instance, nodename) (system_kubernetes_node_info)
              ) * 100000
            ) / 100000,
            "metric_kind", "cpu_total", "instance", ".*"
          )
          or
          label_replace(
            floor(
              (
                100 * (
                  sum without (cpu, mode) (rate(node_cpu_seconds_total{mode="iowait"}[2m]))
                  / clamp_min(sum without (cpu, mode) (rate(node_cpu_seconds_total[2m])), 1e-9)
                )
                * on (center, zone, cluster, instance) group_left (nodename)
                  max by (center, zone, cluster, instance, nodename) (system_kubernetes_node_info)
              ) * 100000
            ) / 100000,
            "metric_kind", "cpu_iowait", "instance", ".*"
          )
          or
          label_replace(
            count by (center, zone, cluster, instance, nodename) (
              node_cpu_seconds_total{mode="idle"}
            )
            * on (center, zone, cluster, instance) group_left(nodename)
              max by (center, zone, cluster, instance, nodename) (system_kubernetes_node_info),
            "metric_kind", "cpu_cores", "instance", ".*"
          )

      - record: system_kubernetes_node_memory
        expr: |
          label_replace(
            (
              floor(100 * (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100000) / 100000
              * on (center, zone, cluster, instance) group_left (nodename)
                max by (center, zone, cluster, instance, nodename) (system_kubernetes_node_info)
            ),
            "metric_kind", "mem_used_os_pct", "instance", ".*"
          )
          or
          label_replace(
            (
              node_memory_MemAvailable_bytes
              * on (center, zone, cluster, instance) group_left (nodename)
                max by (center, zone, cluster, instance, nodename) (system_kubernetes_node_info)
            ),
            "metric_kind", "mem_actual_free_bytes", "instance", ".*"
          )
          or
          label_replace(
            (
              floor(100 * (1 - node_memory_MemFree_bytes / node_memory_MemTotal_bytes) * 100000) / 100000
              * on (center, zone, cluster, instance) group_left (nodename)
                max by (center, zone, cluster, instance, nodename) (system_kubernetes_node_info)
            ),
            "metric_kind", "mem_actual_used_pct", "instance", ".*"
          )
          or
          label_replace(
            (
              floor(100 * ((node_memory_SwapTotal_bytes - node_memory_SwapFree_bytes) / clamp_min(node_memory_SwapTotal_bytes, 1)) * 100000) / 100000
              * on (center, zone, cluster, instance) group_left (nodename)
                max by (center, zone, cluster, instance, nodename) (system_kubernetes_node_info)
            ),
            "metric_kind", "mem_swap_used_pct", "instance", ".*"
          )

      - record: system_kubernetes_node_filesystem
        expr: |
          label_replace(
            (
              100 * (
                1 - (
                  node_filesystem_avail_bytes
                  / clamp_min(node_filesystem_size_bytes, 1)
                )
              )
              * on (center, zone, cluster, instance) group_left (nodename)
                max by (center, zone, cluster, instance, nodename) (system_kubernetes_node_info)
            ),
            "metric_kind", "fs_used_pct", "instance", ".*"
          )

      - record: system_kubernetes_node_diskio
        expr: |
          label_replace(
            (
              sum by (center, zone, cluster, instance) (rate(node_disk_read_bytes_total[2m]))
              * on (center, zone, cluster, instance) group_left (nodename)
                max by (center, zone, cluster, instance, nodename) (system_kubernetes_node_info)
            ),
            "metric_kind", "diskio_read_bps", "instance", ".*"
          )
          or
          label_replace(
            (
              sum by (center, zone, cluster, instance) (rate(node_disk_written_bytes_total[2m]))
              * on (center, zone, cluster, instance) group_left (nodename)
                max by (center, zone, cluster, instance, nodename) (system_kubernetes_node_info)
            ),
            "metric_kind", "diskio_write_bps", "instance", ".*"
          )

      - record: system_kubernetes_node_network
        expr: |
          label_replace(
            (
              label_replace(
                sum by (center, zone, cluster, instance, device) (rate(node_network_receive_bytes_total[2m])),
                "interface", "$1", "device", "(.+)"
              )
              * on (center, zone, cluster, instance) group_left (nodename)
                max by (center, zone, cluster, instance, nodename) (system_kubernetes_node_info)
            ),
            "metric_kind", "net_in_bps", "instance", ".*"
          )
          or
          label_replace(
            (
              label_replace(
                sum by (center, zone, cluster, instance, device) (rate(node_network_transmit_bytes_total[2m])),
                "interface", "$1", "device", "(.+)"
              )
              * on (center, zone, cluster, instance) group_left (nodename)
                max by (center, zone, cluster, instance, nodename) (system_kubernetes_node_info)
            ),
            "metric_kind", "net_out_bps", "instance", ".*"
          )
```

### 6-2. system_kubevirt_vm 그룹

> `kubevirt_vmi_info{phase="running"}` 으로 실행 중인 VM만 처리.

```yaml
  - name: system_kubevirt_vm
    interval: 25s
    rules:
      - record: system_kubevirt_vm_cpu
        expr: |
          label_replace(
            floor(
              (
                100 * (
                  sum by (center, zone, cluster, namespace, name) (rate(kubevirt_vmi_vcpu_seconds_total[2m]))
                  / 1000
                  / clamp_min(count by (center, zone, cluster, namespace, name) (kubevirt_vmi_vcpu_seconds_total), 0.001)
                )
              ) * 100000
            ) / 100000,
            "metric_kind", "cpu_total", "name", ".*"
          )
          * on (center, zone, cluster, namespace, name)
            group_left()
            max by (center, zone, cluster, namespace, name) (kubevirt_vmi_info)
          or
          label_replace(
            floor(
              (
                100 * (
                  sum by (center, zone, cluster, namespace, name) (rate(kubevirt_vmi_vcpu_wait_seconds_total[2m]))
                  / clamp_min(
                      sum by (center, zone, cluster, namespace, name) (rate(kubevirt_vmi_vcpu_seconds_total[2m])),
                      1e-9
                    )
                )
              ) * 100000
            ) / 100000,
            "metric_kind", "cpu_iowait", "name", ".*"
          )
          * on (center, zone, cluster, namespace, name)
            group_left()
            max by (center, zone, cluster, namespace, name) (kubevirt_vmi_info)
          or
          label_replace(
            (
              count by (center, zone, cluster, namespace, name) (kubevirt_vmi_vcpu_seconds_total)
              * on (center, zone, cluster, namespace, name)
                group_left()
                max by (center, zone, cluster, namespace, name) (kubevirt_vmi_info)
            ),
            "metric_kind", "cpu_cores", "name", ".*"
          )

      - record: system_kubevirt_vm_memory
        expr: |
          label_replace(
            floor(
              (
                100 * (
                  clamp_min(kubevirt_vmi_memory_domain_bytes - kubevirt_vmi_memory_resident_bytes, 0)
                  / clamp_min(kubevirt_vmi_memory_domain_bytes, 1)
                )
              ) * 100000
            ) / 100000,
            "metric_kind", "mem_used_physical_pct", "name", ".*"
          )
          * on (center, zone, cluster, namespace, name)
            group_left()
            max by (center, zone, cluster, namespace, name) (kubevirt_vmi_info)
          or
          label_replace(
            clamp_min(kubevirt_vmi_memory_domain_bytes - kubevirt_vmi_memory_resident_bytes, 0),
            "metric_kind", "mem_actual_free_bytes", "name", ".*"
          )
          * on (center, zone, cluster, namespace, name)
            group_left()
            max by (center, zone, cluster, namespace, name) (kubevirt_vmi_info)
          or
          label_replace(
            floor(
              (
                100 * (kubevirt_vmi_memory_resident_bytes / clamp_min(kubevirt_vmi_memory_domain_bytes, 1))
              ) * 100000
            ) / 100000,
            "metric_kind", "mem_actual_used_pct", "name", ".*"
          )
          * on (center, zone, cluster, namespace, name)
            group_left()
            max by (center, zone, cluster, namespace, name) (kubevirt_vmi_info)
          or
          label_replace(
            kubevirt_vmi_memory_domain_bytes * 0,
            "metric_kind", "mem_swap_used_pct", "name", ".*"
          )
          * on (center, zone, cluster, namespace, name)
            group_left()
            max by (center, zone, cluster, namespace, name) (kubevirt_vmi_info)

      - record: system_kubevirt_vm_filesystem
        expr: |
          label_replace(
            floor(
              (
                100 * (
                  sum by (center, zone, cluster, namespace, name, mount_point) (kubevirt_vmi_filesystem_used_bytes)
                  / clamp_min(
                      sum by (center, zone, cluster, namespace, name, mount_point) (kubevirt_vmi_filesystem_capacity_bytes),
                      1
                    )
                )
              ) * 100000
            ) / 100000,
            "metric_kind", "fs_used_pct", "name", ".*"
          )
          * on (center, zone, cluster, namespace, name)
            group_left()
            max by (center, zone, cluster, namespace, name) (kubevirt_vmi_info)

      - record: system_kubevirt_vm_diskio
        expr: |
          label_replace(
            sum by (center, zone, cluster, namespace, name) (rate(kubevirt_vmi_storage_read_traffic_bytes_total[2m])),
            "metric_kind", "diskio_read_bps", "name", ".*"
          )
          * on (center, zone, cluster, namespace, name)
            group_left()
            max by (center, zone, cluster, namespace, name) (kubevirt_vmi_info)
          or
          label_replace(
            sum by (center, zone, cluster, namespace, name) (rate(kubevirt_vmi_storage_write_traffic_bytes_total[2m])),
            "metric_kind", "diskio_write_bps", "name", ".*"
          )
          * on (center, zone, cluster, namespace, name)
            group_left()
            max by (center, zone, cluster, namespace, name) (kubevirt_vmi_info)

      - record: system_kubevirt_vm_network
        expr: |
          label_replace(
            sum by (center, zone, cluster, namespace, name, interface) (rate(kubevirt_vmi_network_receive_bytes_total[2m])),
            "metric_kind", "net_in_bps", "name", ".*"
          )
          * on (center, zone, cluster, namespace, name)
            group_left()
            max by (center, zone, cluster, namespace, name) (kubevirt_vmi_info)
          or
          label_replace(
            sum by (center, zone, cluster, namespace, name, interface) (rate(kubevirt_vmi_network_transmit_bytes_total[2m])),
            "metric_kind", "net_out_bps", "name", ".*"
          )
          * on (center, zone, cluster, namespace, name)
            group_left()
            max by (center, zone, cluster, namespace, name) (kubevirt_vmi_info)
```

### 6-3. kubernetes_pod_vs_limits 그룹

> `node!=""` 필터로 duplicate series 방지.  
> `kube_pod_status_phase{phase="Running"}` 으로 정상 Pod만 조인.

```yaml
  - name: kubernetes_pod_vs_limits
    interval: 25s
    rules:
      - record: kubernetes_pod_resource_usage_node_pct
        expr: |
          label_replace(
            (
              (
                floor(
                  (
                    sum by (center, zone, cluster, namespace, pod) (
                      rate(container_cpu_usage_seconds_total[2m])
                    )
                    / on (center, zone, cluster, namespace, pod)
                      sum by (center, zone, cluster, namespace, pod) (
                        kube_pod_container_resource_limits{resource="cpu"}
                      )
                  ) * 100 * 100000
                ) / 100000
                and on (center, zone, cluster, namespace, pod)
                  (
                    sum by (center, zone, cluster, namespace, pod) (
                      kube_pod_container_resource_limits{resource="cpu"}
                    ) > 0
                  )
              )
              or on (center, zone, cluster, namespace, pod)
                (
                  max by (center, zone, cluster, namespace, pod) (
                    rate(container_cpu_usage_seconds_total[2m])
                  ) * 0
                )
            )
            * on (center, zone, cluster, namespace, pod) group_left (uid, node)
              max by (center, zone, cluster, namespace, pod, uid, node) (
                kube_pod_info
                and on (center, zone, cluster, namespace, pod)
                (kube_pod_status_phase == 1)
              ),
            "resource", "cpu", "pod", ".*"
          )
          or
          label_replace(
            (
              (
                floor(
                  (
                    sum by (center, zone, cluster, namespace, pod) (container_memory_working_set_bytes)
                    / on (center, zone, cluster, namespace, pod)
                      max by (center, zone, cluster, namespace, pod) (
                        kube_pod_container_resource_limits{resource="memory"}
                      )
                  ) * 100 * 100000
                ) / 100000
                and on (center, zone, cluster, namespace, pod)
                  (
                    sum by (center, zone, cluster, namespace, pod) (
                      kube_pod_container_resource_limits{resource="memory"}
                    ) > 0
                  )
              )
              or on (center, zone, cluster, namespace, pod)
                (
                  sum by (center, zone, cluster, namespace, pod) (container_memory_working_set_bytes) * 0
                )
            )
            * on (center, zone, cluster, namespace, pod) group_left (uid, node)
              max by (center, zone, cluster, namespace, pod, uid, node) (
                kube_pod_info
                and on (center, zone, cluster, namespace, pod)
                (kube_pod_status_phase == 1)
              ),
            "resource", "memory", "pod", ".*"
          )
```

---

## 6. File SD 설정

파일 경로: `/etc/prometheus/file_sd/<center-zone-cluster>.yml`

> 망·클러스터 추가 시 targets 항목을 추가합니다.

```yaml
# 예시: center-zone-cluster-ocp.yml
- targets:
    - prometheus-k8s-federate-openshift-monitoring.apps.ocp4.nirs.go.kr
  labels:
    center: center-a
    zone: zone-1
    cluster: cluster-1
```

---

## 7. OpenShift API 토큰 설정

### 8-1. ServiceAccount 생성

```bash
oc create clusterrolebinding prometheus-node-reader \
  --clusterrole=cluster-reader \
  --serviceaccount=klid-cmp:prometheus
```

### 8-2. cluster-reader 권한 부여

```bash
oc adm policy add-cluster-role-to-user cluster-reader \
  system:serviceaccount:klid-cmp:prometheus
```

### 8-3. RBAC 설정 (node-metrics-reader)

```yaml
# node-metrics-reader.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-metrics-reader
rules:
- apiGroups: [""]
  resources: ["nodes/metrics", "nodes/proxy", "nodes/stats"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: read-node-metrics-binding
subjects:
- kind: ServiceAccount
  name: prometheus
  namespace: klid-cmp
roleRef:
  kind: ClusterRole
  name: node-metrics-reader
  apiGroup: rbac.authorization.k8s.io
```

```bash
oc apply -f node-metrics-reader.yaml
```

### 8-4. 토큰 Secret 생성

```yaml
# prometheus-token.yaml
apiVersion: v1
kind: Secret
metadata:
  name: prometheus-token-manual
  namespace: klid-cmp
  annotations:
    kubernetes.io/service-account.name: "prometheus"
type: kubernetes.io/service-account-token
```

```bash
oc apply -f prometheus-token.yaml
```

### 8-5. 토큰 추출 및 파일 저장

```bash
# 토큰 값 추출 (base64 디코딩)
oc get secret prometheus-token-manual -n klid-cmp \
  -o jsonpath='{.data.token}' | base64 -d

# 토큰 파일 생성 후 위 값을 붙여넣기
touch /etc/prometheus/secrets/ocp-prometheus.token
```

---

## 8. 설정 파일 검증

```bash
# prometheus.yml 설정 파일 검증
promtool check config /etc/prometheus/prometheus.yml

# recording rules 파일 검증
promtool check rules /etc/prometheus/rules/prometheus-rules.yml

# 특정 job의 service discovery 확인
promtool check service-discovery /etc/prometheus/prometheus.yml <job_name>
```

---

## 9. 서비스 시작

```bash
systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus.service
systemctl status prometheus
```

---

## 10. PromQL 동작 확인

```bash
# 전체 Pod CPU 조회
curl -s "http://localhost:9090/api/v1/query" \
  --data-urlencode 'query=kubernetes_pod_resource_usage_node_pct{resource="cpu"}'

# 특정 Pod CPU 조회
curl -s "http://localhost:9090/api/v1/query" \
  --data-urlencode 'query=kubernetes_pod_resource_usage_node_pct{resource="cpu", pod="elastic-operator-0"}'

# 특정 namespace 전체 Pod CPU 조회
curl -s "http://localhost:9090/api/v1/query" \
  --data-urlencode 'query=kubernetes_pod_resource_usage_node_pct{resource="cpu", namespace="klid-cmp"}'

# CPU Limits 값 조회
curl -s "http://localhost:9090/api/v1/query" \
  --data-urlencode 'query=kube_pod_container_resource_limits{resource="cpu", pod="elastic-operator-0"}'

# 결과 포맷팅 출력
curl -s "http://localhost:9090/api/v1/query" \
  --data-urlencode 'query=kubernetes_pod_resource_usage_node_pct{resource="cpu", pod="elastic-operator-0"}' \
  | python3 -c "
import sys, json
d = json.load(sys.stdin)
for r in d['data']['result']:
    m = r['metric']
    print(f'pod={m.get(\"pod\",\"\")}')
    print(f'namespace={m.get(\"namespace\",\"\")}')
    print(f'node={m.get(\"node\",\"\")}')
    print(f'cpu%={r[\"value\"][1]}')
"
```

---

## 11. Recording Rule 확인 명령어

```bash
# 토큰 변수 설정
TOKEN=$(cat /etc/prometheus/secrets/ocp-prometheus.token)

# Recording rule 전체 목록 조회
curl -sk --max-time 30 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Host: prometheus-k8s-openshift-monitoring.apps.ocp4.nirs.go.kr" \
  "https://172.30.1.223/api/v1/rules?type=record" \
  | python3 -m json.tool | grep -E '"name"'

# 그룹명 + rule명 함께 출력
curl -sk --max-time 30 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Host: prometheus-k8s-openshift-monitoring.apps.ocp4.nirs.go.kr" \
  "https://172.30.1.223/api/v1/rules?type=record" \
  | python3 -c "
import sys, json
d = json.load(sys.stdin)
groups = d['data']['groups']
print(f'총 rule 그룹 수: {len(groups)}')
for g in groups:
    print(f\"[그룹] {g['name']}\")
    for r in g['rules']:
        print(f\"  → {r['name']}\")
    print()
"
```

---

## 부록 — 주요 파일 경로 요약

| 파일 | 경로 |
|------|------|
| 바이너리 | `/usr/local/bin/prometheus`, `/usr/local/bin/promtool` |
| 설정 파일 | `/etc/prometheus/prometheus.yml` |
| Recording Rules | `/etc/prometheus/rules/prometheus-rules.yml` |
| File SD | `/etc/prometheus/file_sd/*.yml` |
| 토큰 파일 | `/etc/prometheus/secrets/ocp-prometheus.token` |
| 데이터 저장소 | `/var/lib/prometheus` |
| systemd 서비스 | `/etc/systemd/system/prometheus.service` |
