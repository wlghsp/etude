# Debezium 커넥터 배포 가이드

> 사전 조건: Kafka Connect 3중화 오프라인 설치 완료 필수

Debezium MariaDB Source Connector를 배포하는 가이드입니다.  
Sink는 Logstash가 담당하므로 Source Connector만 배포합니다.

```
주센터 MariaDB → Debezium(center.*) → Kafka → Logstash → DR센터 MariaDB
DR센터 MariaDB → Debezium(dr.*)     → Kafka → Logstash → 주센터 MariaDB
```

---

## 1. MariaDB 사용자 권한 설정

> 양쪽 DB(주센터/DR센터) 모두에서 실행

### Source DB (Debezium이 읽는 쪽)

```sql
CREATE USER 'debezium'@'%' IDENTIFIED BY 'debezium_password';

GRANT SELECT, LOCK TABLES, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT
  ON *.* TO 'debezium'@'%';

FLUSH PRIVILEGES;
SHOW GRANTS FOR 'debezium'@'%';
```

### Sink DB (Logstash가 쓰는 쪽)

```sql
CREATE USER 'kafka_sink'@'%' IDENTIFIED BY 'sink_password';

GRANT SELECT, INSERT, UPDATE, DELETE ON `ECP_ADMIN`.* TO `kafka_sink`@`%`;
GRANT SELECT, INSERT, UPDATE, DELETE ON `ECP_PAAS`.* TO `kafka_sink`@`%`;

-- 루프 방지: kafka_sink 세션에서 binlog 기록 비활성화
GRANT BINLOG ADMIN ON *.* TO 'kafka_sink'@'%';

FLUSH PRIVILEGES;
SHOW GRANTS FOR 'kafka_sink'@'%';
```

> `BINLOG ADMIN`이 필요한 이유: Logstash가 Sink DB에 쓸 때 `SET sql_log_bin=0`을 실행해 해당 세션의 binlog 기록을 비활성화합니다. 이렇게 하면 kafka_sink가 쓴 데이터가 Debezium에 캡처되지 않아 양방향 무한루프를 방지합니다.  
> → LOOP_PREVENTION_GUIDE.md 참고

---

## 2. 설정 파일 준비

`primary.env.template` / `replica.env.template` 파일을 복사해서 실제 값으로 채운다.  
테이블 목록(`MYSQL_TABLE`) 등 상세 설정은 해당 파일을 참고한다.

```bash
# 주센터
cp primary.env.template primary.env
vi primary.env

# DR센터
cp replica.env.template replica.env
vi replica.env
```

---

## 3. 커넥터 배포

```bash
# 주센터 Source Connector 배포
./deploy-connectors.sh --mode primary --config primary.env

# DR센터 Source Connector 배포 (DR센터 서버에서 실행)
./deploy-connectors.sh --mode replica --config replica.env

# 원격 배포 시
./deploy-connectors.sh --mode replica --config replica.env --url http://<DR_IP>:8083

# 커넥터 삭제만
./deploy-connectors.sh --mode primary --delete

# 오프셋 초기화 + 재등록 (binlog purge 등 오프셋 무효 시)
./deploy-connectors.sh --mode primary --reset --config primary.env
```

> 커넥터가 이미 존재하면 PUT으로 config만 업데이트 (binlog 오프셋 유지, 스냅샷 없음)  
> 커넥터가 없으면 POST로 신규 등록 (snapshot.mode: initial 스냅샷 실행)  
> `--reset`: 삭제 → connect-offsets tombstone → schema history 토픽 삭제 → 재등록

---

## 4. 배포 확인

### 커넥터 상태

```bash
curl http://localhost:8083/connectors/primary-mariadb-source/status | jq .
curl http://localhost:8083/connectors/replica-mariadb-source/status | jq .

# 정상:
# { "connector": { "state": "RUNNING" }, "tasks": [{ "state": "RUNNING" }] }
```

### Kafka 토픽 확인

```bash
/opt/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092 | grep "^center\.\|^dr\."

# 토픽명 구조: {prefix}.{database}.{table}
# 예: center.ECP_ADMIN.TADP_PRJCT
#     dr.ECP_ADMIN.TADP_PRJCT
```

### 메시지 확인

```bash
/opt/kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 \
  --topic center.ECP_ADMIN.TADP_PRJCT \
  --from-beginning \
  --max-messages 3
```

---

## 트러블슈팅

### Connector FAILED 상태

```bash
# 에러 상세 확인
curl http://localhost:8083/connectors/primary-mariadb-source/status | jq '.tasks[0].trace'

# 커넥터 재배포
./deploy-connectors.sh --mode primary --delete
./deploy-connectors.sh --mode primary --config primary.env
```

### DROP SEQUENCE 파싱 실패

MariaDB SEQUENCE 오브젝트를 파싱할 때 발생합니다.  
MariaDB 전용 커넥터(`io.debezium.connector.mariadb.MariaDbConnector`)를 사용하고,  
`schema.history.internal.skip.unparseable.ddl: true` 설정으로 안전장치를 추가합니다.

### Binlog Purged 오류

connect-offsets 초기화 또는 오랜 중단 후 binlog가 삭제된 경우 발생합니다.

```bash
# --reset: 삭제 → 오프셋 초기화 → schema history 토픽 삭제 → 재등록 (전체 재동기화)
./deploy-connectors.sh --mode primary --reset --config primary.env
```

### 데이터 동기화 무한루프 의심

Kafka 토픽 메시지가 계속 증가하는데 실제 DB 변경이 없는 경우.  
→ LOOP_PREVENTION_GUIDE.md 참고

→ 더 자세한 트러블슈팅: TROUBLESHOOTING.md 참고

---

## 체크리스트

- [ ] 주센터/DR센터 MariaDB `debezium`, `kafka_sink` 사용자 권한 설정
- [ ] `primary.env`, `replica.env` 작성
- [ ] 주센터 `primary-mariadb-source` RUNNING
- [ ] DR센터 `replica-mariadb-source` RUNNING
- [ ] `center.*`, `dr.*` 토픽 생성 확인
- [ ] 메시지 정상 발행 확인
