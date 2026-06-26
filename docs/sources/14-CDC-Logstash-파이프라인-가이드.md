# CDC Logstash 파이프라인 가이드

주센터 ↔ DR센터 간 양방향 DB 실시간 동기화를 담당하는 Logstash 파이프라인 설명서입니다.

---

## 전체 흐름

```
주센터 MariaDB                          DR센터 MariaDB
    ↓ binlog 감지                           ↓ binlog 감지
Debezium (주센터 Kafka Connect)         Debezium (DR Kafka Connect)
    ↓ JSON 메시지 발행                       ↓ JSON 메시지 발행
주센터 Kafka 토픽                        DR Kafka 토픽
(center.ECP_ADMIN.TADP_PRJCT 등)       (dr.ECP_ADMIN.TADP_PRJCT 등)
    ↓ HAProxy 경유                           ↓ HAProxy 경유
Logstash (DR센터, dr/)                  Logstash (주센터, center/)
    ↓ SQL 생성 후 실행                       ↓ SQL 생성 후 실행
DR센터 MariaDB                          주센터 MariaDB
```

각 센터의 DB 변경(INSERT/UPDATE/DELETE)이 발생하면 Debezium이 binlog를 읽어 자기 센터 Kafka에 발행하고, 반대편 센터의 Logstash가 이를 소비해 DB에 반영합니다.

**단, SDN/SDS 6개 테이블은 DR센터에만 존재하므로 DR → 주센터 단방향으로만 동기화됩니다.**
(`TADP_SDN_TENANT`, `TADP_SDN_FVVRF`, `TADP_SDN_FVBD`, `TADP_SDN_FVEPG`, `TADP_STRG_POOL`, `TADP_STRG_DEVICE`)

---

## 파일 구성

양쪽 파이프라인의 파일 구조와 역할은 동일합니다.

```
logstash_conf/
├── center/                   # DR → 주센터 방향 (주센터 서버에 배포)
│   ├── cdc-10-input.conf
│   ├── cdc-20-filter.conf
│   ├── cdc-30-output.conf
│   ├── cdc_upsert.rb
│   └── cdc_delete.rb
└── dr/                       # 주센터 → DR 방향 (DR센터 서버에 배포)
    ├── cdc-10-input.conf
    ├── cdc-20-filter.conf
    ├── cdc-30-output.conf
    ├── cdc_upsert.rb
    └── cdc_delete.rb
```

| 파일 | 역할 |
|---|---|
| `cdc-10-input.conf` | 반대편 센터 Kafka에서 메시지 수신 |
| `cdc-20-filter.conf` | 메시지 파싱, SQL 생성, DB 실행 |
| `cdc-30-output.conf` | 처리 실패 메시지 DLQ 전송 |
| `cdc_upsert.rb` | INSERT ... ON DUPLICATE KEY UPDATE SQL 생성 |
| `cdc_delete.rb` | DELETE SQL 생성 |

---

## 센터별 설정 차이

로직은 동일하고 접속 정보와 토픽 패턴만 다릅니다.

| 항목 | center/ (주센터에 배포) | dr/ (DR센터에 배포) |
|---|---|---|
| 구독 토픽 패턴 | `dr...*` (DR에서 발행한 토픽) | `center...*` (주센터에서 발행한 토픽) |
| input bootstrap_servers | `192.168.1.54:29092~29094` (주센터 HAProxy) | `172.30.1.223:19092~19094` (DR Kafka 직접) |
| group_id | `cdc-logstash-center` | `cdc-logstash-dr` |
| 싱크 DB 주소 | `192.168.1.56:30336` (주센터 MariaDB) | `10.0.0.200:3306` (DR MariaDB) |
| output bootstrap_servers | `192.168.1.54:19092~19094` (주센터 Kafka) | `10.0.0.45~47:9092` (DR Kafka) |
| ECP_ADMIN SDN/SDS 테이블 | 포함 (DR→주센터 단방향) | 없음 |

---

## cdc-10-input.conf — Kafka 수신

```ruby
input {
  kafka {
    bootstrap_servers => "..."   # 센터별 상이
    topics_pattern    => "..."   # 센터별 상이 (dr...*  또는 center...*) 
    group_id          => "..."   # 센터별 상이
    client_id         => "..."   # 센터별 상이
    consumer_threads  => 3
    auto_offset_reset => "earliest"
    enable_auto_commit        => false
    auto_commit_interval_ms   => "1000"
    codec             => json {}
    decorate_events   => true
    reconnect_backoff_ms => 500
    retry_backoff_ms     => 1000
  }
}
```

| 설정 | 설명 |
|---|---|
| `bootstrap_servers` | 처음 클러스터 정보를 받아올 브로커 주소. center/는 HAProxy 경유, dr/는 DR Kafka 직접 접근 |
| `topics_pattern` | 구독할 토픽 정규식. 반대편 센터에서 발행한 토픽만 구독 |
| `group_id` | 컨슈머 그룹 이름. 오프셋이 이 단위로 저장되며 재시작해도 이어서 처리 |
| `client_id` | 모니터링/로그에서 이 컨슈머를 식별하는 이름. 동작에는 영향 없음 |
| `consumer_threads` | 내부 컨슈머 스레드 수. 파티션 수(3개)와 맞춰 각 스레드가 파티션 하나씩 담당 |
| `auto_offset_reset` | group_id가 **신규**일 때만 적용. 토픽에 이미 쌓인 메시지를 처음부터 전부 처리. 재시작 시엔 저장된 오프셋부터 이어서 읽으므로 무시됨 |
| `enable_auto_commit` | `false` — 파이프라인 처리 완료 후 커밋. DB 실행 실패 시 메시지 유실 방지 |
| `auto_commit_interval_ms` | `enable_auto_commit=false`이므로 실질적으로 무의미 |
| `codec` | Kafka 메시지를 JSON으로 파싱해 Logstash 이벤트 필드로 변환 |
| `decorate_events` | Kafka 메타데이터(`[@metadata][kafka][topic]` 등)를 이벤트에 추가. filter에서 토픽명으로 schema/table 추출 시 필수 |
| `reconnect_backoff_ms` | 브로커 연결 끊김 시 재연결 대기 시간 |
| `retry_backoff_ms` | 메시지 fetch 실패 시 재시도 대기 시간 |

---

## cdc-20-filter.conf — 파싱 / SQL 생성 / DB 실행

파이프라인의 핵심 로직입니다. 크게 5단계로 구성됩니다.

### 단계 1 — 불량 메시지 드롭

```ruby
if "_jsonparsefailure" in [tags] {
  drop {}
}
```

tombstone(Debezium이 DELETE 후 발행하는 null 메시지) 또는 JSON 파싱 실패 메시지를 즉시 버립니다.

### 단계 2 — 토픽명에서 schema/table 추출

```ruby
topic = event.get("[@metadata][kafka][topic]").to_s
parts = topic.split(".")
# parts[0] = 센터 구분 (dr 또는 center), 버림
# parts[1] = db_schema (ECP_ADMIN, ECP_PAAS)
# parts[2] = db_table  (TADP_PRJCT 등)
```

토픽 형식: `dr.ECP_ADMIN.TADP_PRJCT` 또는 `center.ECP_ADMIN.TADP_PRJCT`

파싱 실패(파트가 3개 미만)이면 드롭됩니다.

### 단계 3 — op(작업 유형) 판별

Debezium rewrite 모드로 전송된 메시지 기준입니다.
(rewrite 모드: envelope 없이 after 값을 최상위 필드로 펼치고, op 정보는 `__op`, `__deleted`로 붙임)

```ruby
if [__deleted] == "true" {
  # DELETE 이벤트
  [@metadata][op] = "delete"
} else if [__op] in ["c", "u", "r"] {
  # INSERT(c), UPDATE(u), 스냅샷(r) → 모두 upsert로 처리
  [@metadata][op] = "upsert"
} else {
  # 알 수 없는 op → DLQ
  [@metadata][op] = "dlq"
}
```

### 단계 4 — PK 컬럼 매핑

schema/table 조합으로 어떤 컬럼이 PK인지 `[@metadata][pk_col]`에 기록합니다. 복합 PK는 콤마로 구분합니다. 알 수 없는 schema이면 dlq로 처리합니다.

**동기화 대상 테이블 목록:**

ECP_ADMIN (20개 / dr/에는 SDN·SDS 제외 14개):

| 테이블 | PK | dr/ 포함 여부 |
|---|---|---|
| TADP_PRJCT | PRJCT_ID | O |
| TADP_DTCNTR | DTCNTR_ID | O |
| TADP_DTCNTR_NET | DTCNTR_NET_ID | O |
| TADP_DTCNTR_ZONE | DTCNTR_ZONE_ID | O |
| TADP_ORG | ORG_CD | O |
| TADP_ROLE | ROLE_NO | O |
| TADP_MENU | MENU_NO | O |
| TADP_USER | USER_NO | O |
| GTP_TICKET_MGMT | TICKET_ID | O |
| GTP_PRJT_ALLO_REQ | NO | O |
| GTP_RSRC_ALLO_REQ | NO | O |
| GTP_RSRC_RET_REQ | NO | O |
| TADP_MENU_ROLE_SETUP | ROLE_NO, MENU_NO | O |
| TADP_USER_ROLE_SETUP | USER_NO, ROLE_NO | O |
| TADP_SDN_TENANT | NAME, BIZ | **center/ 전용** |
| TADP_SDN_FVVRF | NAME, BIZ, TENANTNAME | **center/ 전용** |
| TADP_SDN_FVBD | NAME, BIZ, TENANTNAME | **center/ 전용** |
| TADP_SDN_FVEPG | NAME, BIZ, TENANTNAME | **center/ 전용** |
| TADP_STRG_POOL | POOL_NO | **center/ 전용** |
| TADP_STRG_DEVICE | DEVICE_ID | **center/ 전용** |

ECP_PAAS (13개, 양쪽 동일): TADP_PRJCT, TADP_DTCNTR, TADP_DTCNTR_NET, TADP_DTCNTR_ZONE, TADP_ORG, TADP_ROLE, TADP_MENU, TADP_USER, GTP_TICKET_MGMT, GTP_RSRC_ALLO_REQ, GTP_RSRC_RET_REQ, TADP_MENU_ROLE_SETUP, TADP_USER_ROLE_SETUP

**특이 조건 — TADP_PRJCT:**

`STT_CD`가 `PS00`(진행중) 또는 `PS04`(완료)인 경우만 upsert를 허용합니다. 그 외 상태는 dlq 처리됩니다.

### 단계 5 — SQL 생성 및 DB 실행

upsert/delete op에 따라 Ruby 스크립트로 SQL을 생성한 뒤 JDBC로 싱크 DB에 직접 실행합니다.

DB 연결은 schema별로 커넥션을 유지(`@@conns`)하며, 연결이 끊기면 재연결합니다. DB 실행 실패 시 `[@metadata][op]`를 `db_error`로 변경하고 에러 메시지를 `db_error_message` 필드에 기록합니다.

---

## cdc_upsert.rb — UPSERT SQL 생성

```sql
INSERT INTO `schema`.`table` (col1, col2, ...)
VALUES (v1, v2, ...)
ON DUPLICATE KEY UPDATE col1 = v1, col2 = v2, ...
```

**핵심 동작:**
- PK가 없으면 INSERT, 있으면 UPDATE (모든 컬럼 덮어씌움)
- 중복 메시지가 와도 결과가 동일 (멱등)
- `__deleted`, `__op`, `db_schema`, `db_table` 등 내부 필드는 SQL에서 제외
- `DATETIME_COLS`에 명시된 컬럼만 epoch ms → `'YYYY-MM-DD HH:MM:SS'` 변환. 그 외 날짜 컬럼은 bigint 그대로 삽입

**DATETIME_COLS 현황 (양쪽 동일):**

| 테이블 | datetime 컬럼 |
|---|---|
| ECP_ADMIN.GTP_TICKET_MGMT | APPROVER_DT |
| ECP_PAAS.TADP_MENU | CRT_DT, UPD_DT |
| ECP_PAAS.TADP_ORG | CRT_DT, UPD_DT |
| ECP_PAAS.TADP_ROLE | CRT_DT, UPD_DT |
| ECP_PAAS.TADP_USER | CRT_DT, UPD_DT |

SDN/SDS 6개 테이블은 날짜 컬럼이 모두 `bigint`이므로 별도 변환 불필요.

---

## cdc_delete.rb — DELETE SQL 생성

```sql
DELETE FROM `schema`.`table` WHERE `PK1` = v1 AND `PK2` = v2
```

`[@metadata][pk_col]`에서 PK 컬럼을 읽어 WHERE 조건을 구성합니다. 복합 PK도 지원합니다.

---

## cdc-30-output.conf — DLQ 처리

정상 처리(upsert/delete 성공)된 메시지는 output에서 아무것도 하지 않습니다. 실패한 메시지만 자기 센터 Kafka DLQ 토픽으로 보냅니다.

| DLQ 토픽 | 발생 케이스 |
|---|---|
| `cdc-garbage` | 알 수 없는 schema, 지원하지 않는 테이블, TADP_PRJCT STT_CD 조건 불일치, 알 수 없는 op |
| `cdc-recovery` | DB 연결 실패, SQL 실행 오류 등 DB 실행 단계 에러 |

`cdc-recovery` 토픽에 쌓인 메시지는 별도 재처리 스크립트로 재시도할 수 있습니다.

---

## op 흐름 요약

```
메시지 수신
    ↓
JSON 파싱 실패? → drop
    ↓
토픽 파싱 실패? → drop
    ↓
__deleted=true  → op=delete
__op=c/u/r      → op=upsert
그 외           → op=dlq → cdc-garbage
    ↓
알 수 없는 schema? → op=dlq → cdc-garbage
    ↓
TADP_PRJCT이고 STT_CD 조건 불일치? → op=dlq → cdc-garbage
    ↓
SQL 생성 (cdc_upsert.rb / cdc_delete.rb)
    ↓
DB 실행 성공 → 완료
DB 실행 실패 → op=db_error → cdc-recovery
```

---

## 테이블 추가/제거

### 테이블 추가

동기화 대상 테이블을 새로 추가할 때는 아래 두 파일을 수정합니다.

**1. `cdc-20-filter.conf` — PK 매핑 추가**

해당 schema 블록에 `else if` 한 줄 추가합니다.

```ruby
# 단일 PK
else if [db_table] == "NEW_TABLE" { mutate { add_field => { "[@metadata][pk_col]" => "PK_COL" } } }

# 복합 PK
else if [db_table] == "NEW_TABLE" { mutate { add_field => { "[@metadata][pk_col]" => "COL1,COL2" } } }
```

**2. `cdc_upsert.rb` — datetime 컬럼 여부 확인**

새 테이블에 `datetime` 타입 컬럼이 있으면 `DATETIME_COLS`에 추가합니다.
`bigint` epoch 또는 `varchar` 날짜 컬럼은 추가 불필요합니다.

```ruby
DATETIME_COLS = {
  ...
  'ECP_ADMIN.NEW_TABLE' => %w[CREATED_AT UPDATED_AT],  # datetime 컬럼만
}
```

**3. Debezium Connector 설정 변경**

Kafka Connect의 Debezium connector 설정에서 `table.include.list`에 새 테이블을 추가하고 connector를 재시작합니다. Logstash는 재시작 불필요합니다.

**SDN/SDS처럼 DR센터 전용 테이블이라면** `center/`에만 추가하고 `dr/`는 수정하지 않습니다.

---

### 테이블 제거

Logstash 설정에서 PK 매핑을 제거하지 않아도 동작에는 문제 없습니다. Debezium connector의 `table.include.list`에서 해당 테이블을 제거하면 Kafka에 메시지가 발행되지 않으므로 Logstash까지 도달하지 않습니다.

Logstash 설정 정리가 필요하다면 `cdc-20-filter.conf`에서 해당 `else if` 블록을 제거합니다. 매핑이 없는 테이블 메시지가 들어오면 pk_col이 설정되지 않아 SQL 생성 단계에서 오류가 발생하므로, Debezium에서 제거한 테이블은 반드시 Logstash 설정에서도 제거하거나 Debezium 설정을 먼저 반영해야 합니다.

---

## 운영 시 확인 포인트

**컨슈머 그룹 오프셋 상태 확인 (LAG이 줄어들면 정상 처리 중):**
```bash
kafka-consumer-groups.sh --bootstrap-server <broker> \
  --group cdc-logstash-center --describe   # 주센터

kafka-consumer-groups.sh --bootstrap-server <broker> \
  --group cdc-logstash-dr --describe       # DR센터
```

**DLQ 토픽 쌓임 여부 확인:**
```bash
kafka-console-consumer.sh --bootstrap-server <broker> \
  --topic cdc-garbage --from-beginning

kafka-console-consumer.sh --bootstrap-server <broker> \
  --topic cdc-recovery --from-beginning
```

**주요 로그 메시지:**
- `CDC DB 실행 성공 schema=... table=... op=...` — 정상
- `CDC DB 실행 실패 schema=... table=... op=... error=...` — DB 실행 실패, cdc-recovery로 이동
