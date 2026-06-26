# Kafka CDC 전체 설치 순서 가이드

> 이 문서는 주센터/DR센터 각각에서 Kafka 3중화 + CDC 파이프라인을 구축하는 전체 흐름을 안내합니다.  
> 각 단계별 상세 절차는 해당 가이드 문서를 참고하세요.

---

## 전체 구성도

```
┌─────────────────────────────────────────────────────────────────┐
│                         주센터                                   │
│                                                                 │
│  MariaDB Galera (3노드)                                         │
│       ↓ binlog                                                  │
│  Kafka Broker 3중화 (broker1~3)                                 │
│       ↑↓ INTERNAL :9092                                        │
│  Kafka Connect 3중화 (broker1~3 각각 실행)                       │
│       ↓ Debezium Source → 토픽 발행                              │
│       ↓ JDBC Sink ← DR센터에서 수신                              │
│  Logstash (CDC Sink: 토픽 소비 → DB 반영)                        │
│                                                                 │
│  HAProxy                                                        │
│    :19092~19094 → broker1~3 :9094  (EXTERNAL, DR센터 접근용)    │
│    :3306        → MariaDB node1    (DB 로드밸런싱)               │
└─────────────────────────────────────────────────────────────────┘
                         ↕ CDC 양방향
┌─────────────────────────────────────────────────────────────────┐
│                         DR센터                                   │
│  (동일 구조, auto_increment_offset=2)                            │
└─────────────────────────────────────────────────────────────────┘
```

---

## 작업 전 준비물

### 서버 IP 수집 (현장에서 확인 후 기록)

| 항목 | 주센터 | DR센터 |
|------|--------|--------|
| Broker1 IP | | |
| Broker2 IP | | |
| Broker3 IP | | |
| HAProxy IP | | |
| MariaDB node1 IP | | |
| MariaDB node2 IP | | |
| MariaDB node3 IP | | |

### 반입 파일

| 파일 | 용도 |
|------|------|
| `kafka-offline.tar.gz` | Kafka/Connect/Logstash 설치 파일 전체 |
| `mariadb-packages.tar.gz` | MariaDB Galera 설치 파일 전체 |
| `kafka-guides.tar.gz` | 가이드 문서 모음 |

---

## 설치 순서

### Phase 1. MariaDB Galera Cluster (3노드)

> 참고: `MariaDB-Galera-Cluster-3중화-구축-가이드.md`  
> 패키지: **`mariadb-packages.tar.gz`** (별도 파일)

```
1. 의존성 RPM 설치 (3대 공통)
2. MariaDB 바이너리 설치 (3대 공통)
3. my.cnf 배포 및 노드별 항목 수정 (server-id, wsrep_node_address)
   - 주센터: auto_increment_offset=1
   - DR센터: auto_increment_offset=2
4. mariadb.service 등록
5. node1 galera_new_cluster → node2, node3 순서대로 start
6. wsrep_cluster_size=3, wsrep_local_state_comment=Synced 확인
7. HAProxy mariadb 섹션 추가 (node1 active, node2/3 backup)
8. haproxy_check 계정 생성
9. DB 복원 (schema 또는 full)
10. 앱 계정 생성
```

---

### Phase 2. Java 21 설치 (Kafka 브로커 3대 공통)

> 참고: `Kafka-3중화-오프라인-설치-가이드.md` — 섹션 2

패키지: `kafka-offline/01-java/`

```bash
sudo rpm -ivh *.rpm
java -version  # 확인
```

---

### Phase 3. Kafka Broker 3중화

> 참고: `Kafka-3중화-오프라인-설치-가이드.md`

패키지: `kafka-offline/02-kafka/`

```
1. kafka_2.13-4.2.0.tgz 설치
2. server.properties.broker{1,2,3}.template → 브로커별 IP 치환
   - BROKER1_IP, BROKER2_IP, BROKER3_IP, HAPROXY_IP
3. kafka.service 등록
4. KRaft 메타데이터 초기화 (node1 → node2 → node3 순서)
5. 3대 기동 후 클러스터 확인
6. HAProxy Kafka EXTERNAL 섹션 추가
   - :19092 → broker1:9094
   - :19093 → broker2:9094
   - :19094 → broker3:9094
7. kafka-ui-api-v0.7.2.jar + kafka-ui.service 설치
```

---

### Phase 4. Kafka Connect 3중화

> 참고: `Kafka-Connect-3중화-오프라인-설치-가이드.md`

패키지: `kafka-offline/03-kafka-connect/`

```
1. debezium-connector-mariadb 플러그인 설치 (3대 공통)
2. confluentinc-kafka-connect-jdbc 플러그인 설치 (3대 공통)
3. mariadb-java-client.jar → JDBC 플러그인 폴더에 복사
4. connect-distributed.broker{1,2,3}.template → BOOTSTRAP_SERVERS 치환
5. kafka-connect.service 등록
   - DR센터: KAFKA_HEAP_OPTS -Xmx512m -Xms512m 으로 변경
6. 3대 기동 후 REST API 확인 (curl http://localhost:8083/)
7. connect-offsets/config/status 토픽 cleanup.policy=compact 확인
```

---

### Phase 5. Logstash 설치

> 참고: `Kafka-Connect-Debezium-완전-설치-가이드.md` — Logstash 섹션

패키지: `kafka-offline/04-logstash/`

```
1. Logstash 바이너리 설치 (별도 패키지)
2. 해당 센터 설정 파일 배포
   - 주센터: center/ 폴더
   - DR센터: dr/ 폴더
3. pipelines.yml 설정
4. logstash.service 등록 및 기동
5. 파이프라인 정상 동작 확인
```

---

### Phase 6. Debezium/JDBC 커넥터 등록

> 참고: `Kafka-Connect-Debezium-완전-설치-가이드.md`

패키지: `kafka-offline/05-connector/`

```
1. MariaDB debezium 계정 생성 및 권한 부여
2. primary.env.template / replica.env.template → IP/계정 정보 수정
3. deploy-connectors.sh 실행
4. 커넥터 상태 확인 (check-connector-status.sh)
5. CDC 동작 확인 (source DB 변경 → Logstash 로그 확인)
```

---

## 최종 체크리스트

### 주센터

- [ ] MariaDB Galera wsrep_cluster_size=3, Synced
- [ ] HAProxy mariadb :3306 연결 확인
- [ ] Kafka 3브로커 클러스터 확인
- [ ] HAProxy Kafka EXTERNAL :19092~19094 연결 확인
- [ ] Kafka Connect 3대 REST API 응답 확인
- [ ] connect 내부 토픽 cleanup.policy=compact 확인
- [ ] Logstash 파이프라인 running 확인
- [ ] Debezium Source 커넥터 RUNNING
- [ ] JDBC Sink 커넥터 RUNNING
- [ ] CDC 테스트: 주센터 DB 변경 → DR센터 반영 확인

### DR센터

- [ ] 위 주센터 항목 동일하게 확인
- [ ] auto_increment_offset=2 확인
- [ ] KAFKA_HEAP_OPTS 512m 확인 (Connect)
- [ ] CDC 테스트: DR센터 DB 변경 → 주센터 반영 확인

---

## 관련 가이드 문서 목록

| 문서 | 용도 |
|------|------|
| `MariaDB-Galera-Cluster-3중화-구축-가이드.md` | MariaDB 설치/구성 |
| `Galera-멀티센터-PK-충돌-방지-가이드.md` | AUTO_INCREMENT 충돌 방지 |
| `Kafka-3중화-오프라인-설치-가이드.md` | Kafka 브로커 설치 |
| `Kafka-JVM-성능-설정-가이드.md` | JVM 힙 튜닝 |
| `Kafka-HAProxy-리스너-설정-가이드.md` | HAProxy EXTERNAL 설정 |
| `Kafka-Connect-3중화-오프라인-설치-가이드.md` | Kafka Connect 설치 |
| `Kafka-Connect-Debezium-완전-설치-가이드.md` | Debezium/JDBC 커넥터 등록 |
| `Kafka-Connect-디버깅-명령어.md` | 트러블슈팅 명령어 |
