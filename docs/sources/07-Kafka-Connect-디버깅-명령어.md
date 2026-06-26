# Kafka Connect 디버깅 명령어

Kafka UI 없이 CLI로 상태를 확인하고 문제를 추적하기 위한 명령어 모음.

환경 기준:
- Kafka Broker: 10.0.0.45 / 46 / 47 (port 9092)
- Kafka Connect REST API: port 8083
- 로그 경로: `/opt/kafka/logs/`
- 바이너리: `/opt/kafka/bin/`

---

## 1. Kafka Broker

### 브로커 상태

```bash
# 서비스 상태
sudo systemctl status kafka

# 실시간 로그
sudo journalctl -u kafka -f

# 브로커 ID 및 클러스터 메타데이터 확인
/opt/kafka/bin/kafka-metadata-quorum.sh \
  --bootstrap-server localhost:9092 describe --status
```

### 토픽 목록

```bash
# 전체 토픽
/opt/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092

# CDC 토픽만 (center.* / dr.*)
/opt/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092 \
  | grep "^center\.\|^dr\."

# Connect 내부 토픽
/opt/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092 \
  | grep "^connect-"
```

### 토픽 상세

```bash
# 파티션 수, replication factor, cleanup.policy 등
/opt/kafka/bin/kafka-topics.sh --describe \
  --bootstrap-server localhost:9092 \
  --topic center.ECP_ADMIN.TADP_PRJCT

# Connect 내부 토픽 정책 확인 (compact 인지 확인)
/opt/kafka/bin/kafka-topics.sh --describe \
  --bootstrap-server localhost:9092 \
  --topic connect-offsets
```

### 메시지 확인

```bash
# 특정 토픽 최신 메시지 3개
/opt/kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 \
  --topic center.ECP_ADMIN.TADP_PRJCT \
  --from-beginning \
  --max-messages 3

# 실시간 수신 (Ctrl+C로 종료)
/opt/kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 \
  --topic center.ECP_ADMIN.TADP_PRJCT
```

### Consumer Group (offset 추적)

```bash
# 전체 consumer group 목록
/opt/kafka/bin/kafka-consumer-groups.sh \
  --bootstrap-server localhost:9092 --list

# Connect consumer group lag 확인
/opt/kafka/bin/kafka-consumer-groups.sh \
  --bootstrap-server localhost:9092 \
  --group connect-cluster \
  --describe
```

---

## 2. Kafka Connect

### 서비스 상태

```bash
# 서비스 상태
sudo systemctl status kafka-connect

# 실시간 로그 (systemd journal)
sudo journalctl -u kafka-connect -f

# 최근 50줄
sudo journalctl -u kafka-connect -n 50 --no-pager
```

### Connect 클러스터 확인

```bash
# 버전 및 클러스터 정보
curl -s http://localhost:8083/ | jq .

# 현재 Worker 목록 (3대 중 몇 대가 클러스터에 참여했는지)
curl -s http://localhost:8083/connectors | jq .

# 설치된 플러그인 목록 (MariaDbConnector 있는지 확인)
curl -s http://localhost:8083/connector-plugins | jq '.[].class'
```

---

## 3. 커넥터

### 상태 확인

```bash
# 등록된 커넥터 목록
curl -s http://localhost:8083/connectors | jq .

# 커넥터 상태 (RUNNING / FAILED / PAUSED)
curl -s http://localhost:8083/connectors/primary-mariadb-source/status | jq .
curl -s http://localhost:8083/connectors/replica-mariadb-source/status | jq .

# Task 에러 trace (FAILED일 때)
curl -s http://localhost:8083/connectors/primary-mariadb-source/status \
  | jq '.tasks[0].trace'
```

### 커넥터 제어

```bash
# 커넥터 일시정지
curl -s -X PUT http://localhost:8083/connectors/primary-mariadb-source/pause

# 커넥터 재개
curl -s -X PUT http://localhost:8083/connectors/primary-mariadb-source/resume

# Task 재시작 (FAILED 후 재시도)
curl -s -X POST http://localhost:8083/connectors/primary-mariadb-source/tasks/0/restart

# 커넥터 전체 재시작
curl -s -X POST http://localhost:8083/connectors/primary-mariadb-source/restart

# 커넥터 삭제
curl -s -X DELETE http://localhost:8083/connectors/primary-mariadb-source
```

### 커넥터 설정 확인

```bash
# 현재 적용된 설정 전체 조회
curl -s http://localhost:8083/connectors/primary-mariadb-source/config | jq .
```

---

## 4. 로그 확인

### 로그 파일 구조

```
/opt/kafka/logs/
├── connect.log              # Connect 프레임워크 (Worker, Task, offset)
├── connect.log.yyyy-MM-dd
├── connect-debezium.log     # Debezium Source 커넥터 전용
└── connect-debezium.log.yyyy-MM-dd
```

### 실시간 확인

```bash
# Debezium 로그 (CDC 이벤트, binlog 읽기)
tail -f /opt/kafka/logs/connect-debezium.log

# Connect 프레임워크 로그 (rebalance, offset commit 등)
tail -f /opt/kafka/logs/connect.log

# 에러만 필터
tail -f /opt/kafka/logs/connect-debezium.log | grep -i "error\|exception\|failed"
```

### 로그 레벨 동적 변경 (재시작 불필요)

```bash
# Debezium DEBUG로 전환 (문제 추적 시)
curl -s -X PUT -H "Content-Type: application/json" \
  -d '{"level": "DEBUG"}' \
  http://localhost:8083/admin/loggers/io.debezium

# 현재 레벨 확인
curl -s http://localhost:8083/admin/loggers/io.debezium

# INFO로 원복
curl -s -X PUT -H "Content-Type: application/json" \
  -d '{"level": "INFO"}' \
  http://localhost:8083/admin/loggers/io.debezium
```

---

## 5. 자주 쓰는 조합

### Connect가 시작되지 않을 때

```bash
sudo journalctl -u kafka-connect -n 100 --no-pager | grep -i "error\|exception"
```

### 커넥터가 FAILED일 때

```bash
# 1. trace 확인
curl -s http://localhost:8083/connectors/primary-mariadb-source/status \
  | jq '.tasks[0].trace'

# 2. Debezium 로그에서 전후 맥락 확인
grep -i "error\|exception" /opt/kafka/logs/connect-debezium.log | tail -30
```

### CDC 토픽에 메시지가 안 올 때

```bash
# 1. 커넥터 상태 확인
curl -s http://localhost:8083/connectors/primary-mariadb-source/status | jq .

# 2. 토픽 존재 여부
/opt/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092 | grep "^center\."

# 3. Debezium 로그에서 binlog 위치 확인
grep "binlog\|snapshot" /opt/kafka/logs/connect-debezium.log | tail -20
```

### Connect 내부 토픽 cleanup.policy 확인 (시작 실패 원인)

```bash
for T in connect-config connect-offsets connect-status; do
  echo "=== $T ==="
  /opt/kafka/bin/kafka-topics.sh --describe \
    --bootstrap-server localhost:9092 --topic $T \
    | grep "cleanup.policy"
done
```
