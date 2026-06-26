# CDC Logstash 파이프라인 운영 가이드

## 개요

Debezium MySQL Source Connector가 binlog를 캡처하여 Kafka 토픽에 발행하면,
각 센터의 Logstash가 해당 토픽을 컨슘하여 반대 센터 DB에 반영하는 양방향 CDC 파이프라인.

```
주센터 MySQL → Debezium → Kafka(center.*) → DR Logstash → DR MySQL
DR MySQL     → Debezium → Kafka(dr.*)     → 주센터 Logstash → 주센터 MySQL
```

---

## 아키텍처

| 구성요소 | 주센터 | DR센터 |
|---------|-------|-------|
| Kafka Bootstrap | 192.168.1.54:29092~29094 | 172.30.1.223:19092~19094 |
| 토픽 prefix | `center.*` | `dr.*` |
| Logstash 설치 위치 | indexing1, indexing2 | indexing1, indexing2 |
| 대상 DB | 192.168.1.56:30336 | 10.0.0.200:3306 |
| Logstash conf 경로 | `/etc/logstash/conf_cdc/` | `/etc/logstash/conf_cdc/` |

---

## 파일 구조

```
logstash_conf/
├── center/                  # 주센터 Logstash (dr.* 토픽 컨슘 → 주센터 DB 반영)
│   ├── cdc-10-input.conf
│   ├── cdc-20-filter.conf
│   ├── cdc-30-output.conf
│   ├── cdc_upsert.rb
│   └── cdc_delete.rb
└── dr/                      # DR센터 Logstash (center.* 토픽 컨슘 → DR DB 반영)
    ├── cdc-10-input.conf
    ├── cdc-20-filter.conf
    ├── cdc-30-output.conf
    ├── cdc_upsert.rb
    └── cdc_delete.rb
```

---

## 핵심 설계 결정 및 이유

### 1. `decorate_events => true` 필수

`[@metadata][kafka][topic]`으로 토픽명에 접근하려면 반드시 필요.
누락 시 토픽명이 빈 문자열로 와서 schema/table 파싱 실패 → 전체 이벤트 drop.

### 2. grok 대신 ruby split으로 토픽 파싱

grok의 `%{WORD}` 패턴은 언더스코어(`_`)를 포함한 단어를 매칭하지 못함.
`ECP_ADMIN` 같은 테이블명 파싱 실패 → ruby `topic.split(".")` 으로 대체.

### 3. logstash-output-jdbc 대신 filter ruby에서 직접 JDBC 실행

jdbc output plugin의 `statement`에서 `%{field}` 치환 시 MariaDB JDBC가 `{}`를 escape sequence로 해석하여 오류 발생.
filter 블록 내 ruby에서 `Java::org.mariadb.jdbc.Driver.new.connect()`로 직접 연결하여 해결.

MariaDB jar 배치 위치: `/usr/share/logstash/logstash-core/lib/jars/mariadb-java-client-3.x.x.jar`
(이 경로에 두면 Logstash 시작 시 JVM classpath에 자동 등록됨)

### 4. `@@conns` 클래스 변수로 DB 커넥션 재사용

매 이벤트마다 DB 연결을 새로 맺으면 성능 저하. `@@conns[db_schema]`에 커넥션을 캐싱하고 `isValid(1)`로 유효성 검증 후 재사용.

### 5. DELETE 처리: `__deleted == "true"` 조건

Debezium `ExtractNewRecordState` transform + `delete.tombstone.handling.mode: rewrite` 조합.
DELETE 이벤트는 `__deleted: "true"` 필드로 식별 (구버전 `delete.handling.mode`는 Debezium 3.x에서 동작 안 함).

### 6. `topics_pattern => "center...*"` (이스케이프 없이)

Java regex에서 `center\\..*`가 의도대로 동작하지 않는 버그 존재.
`.`을 임의 문자(any char)로 사용하는 `center...*` 패턴이 실제 동작 확인됨.

### 7. tombstone 처리

`tombstones.on.delete: true` + `drop.tombstones: true` 설정으로 tombstone(`value=null`)은 Kafka에서 필터링.
Logstash에 도달하는 tombstone은 `_jsonparsefailure` 태그 → drop 처리.

---

## Debezium Source Connector 설정 (핵심 항목)

```json
{
  "transforms": "unwrap",
  "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
  "transforms.unwrap.delete.tombstone.handling.mode": "rewrite",
  "transforms.unwrap.drop.tombstones": "true",
  "transforms.unwrap.add.fields": "op,ts_ms",
  "tombstones.on.delete": "true"
}
```

- `delete.tombstone.handling.mode: rewrite`: DELETE 시 `__deleted: "true"` + 전체 컬럼 데이터 포함 메시지 발행
- `drop.tombstones: true`: tombstone(`value=null`) 제거, `__deleted: "true"` 메시지만 전달
- `add.fields: "op,ts_ms"`: `__op`, `__ts_ms` 필드 추가

---

## HAProxy를 통한 Kafka 통신

### 문제 배경

주센터 Kafka는 OpenShift 내부에서 운영되며, 브로커들이 **내부 서비스명**(`svc-kafka-1`, `svc-kafka-2`, `svc-kafka-3`)으로 advertised listener를 광고한다.

Kafka 프로토콜 특성상 클라이언트가 최초 bootstrap 서버에 접속하면, 브로커가 **자신의 advertised address**를 응답으로 돌려준다. 이후 클라이언트는 bootstrap 주소가 아닌 **브로커가 알려준 주소**로 직접 연결을 시도한다.

DR센터 Logstash가 주센터 Kafka에 접속하면:
1. bootstrap 서버(HAProxy IP)에 연결 성공
2. 브로커가 `svc-kafka-1:9092` 같은 **OCP 내부 서비스명**을 응답
3. DR 서버에서 `svc-kafka-1`은 DNS 해석 불가 → **연결 실패**

### 해결: HAProxy에 브로커별 포트 매핑

각 브로커를 **고정 포트**로 1:1 매핑하여, advertised listener가 HAProxy IP:포트를 바라보도록 구성.

```
# 주센터 HAProxy (center_haproxy.cfg) - DR 접근용
listen primary-kafka-broker1  bind *:19092  → 192.168.1.56:30192 (kafka-1 NodePort)
listen primary-kafka-broker2  bind *:19093  → 192.168.1.56:30292 (kafka-2 NodePort)
listen primary-kafka-broker3  bind *:19094  → 192.168.1.56:30392 (kafka-3 NodePort)

# DR HAProxy (dr_haproxy.cfg) - 주센터 접근용
listen dr-kafka-broker1       bind *:29092  → 10.0.0.45:9092
listen dr-kafka-broker2       bind *:29093  → 10.0.0.46:9092
listen dr-kafka-broker3       bind *:29094  → 10.0.0.47:9092
```

### 통신 흐름

```
DR Logstash
  → 172.30.1.223:19092 (DR HAProxy)
    → 192.168.1.54:19092 (주센터 HAProxy)  ← DR haproxy.cfg에서 중계
      → 192.168.1.56:30192 (주센터 kafka-1 NodePort)
```

DR HAProxy가 주센터 HAProxy를 한 번 더 거치는 구조 (`primary-haproxy-kafka1 192.168.1.54:19092`).
이는 주센터 HAProxy IP가 DR에서 직접 라우팅 가능한 경우 단순화할 수 있으나, 현재 구성에서는 이중 중계가 필요.

### Kafka advertised.listeners 설계 원칙

Kafka 클라이언트는 bootstrap 접속 후 브로커가 돌려준 **advertised 주소**로 재연결한다.
따라서 advertised 주소가 클라이언트가 실제로 접근 가능한 주소여야 한다.

**핵심 원칙: 해당 센터에서 접근 가능한 HAProxy 주소를 advertised로 설정**

```
# 주센터 Kafka server.properties
listener.security.protocol.map=CONTROLLER:PLAINTEXT,INTERNAL:PLAINTEXT,EXTERNAL:PLAINTEXT,PLAINTEXT:PLAINTEXT
listeners=INTERNAL://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093,EXTERNAL://0.0.0.0:9094
advertised.listeners=INTERNAL://192.168.1.54:19092,EXTERNAL://172.30.1.223:19092
inter.broker.listener.name=INTERNAL

# DR Kafka server.properties (브로커1 예시)
listener.security.protocol.map=CONTROLLER:PLAINTEXT,INTERNAL:PLAINTEXT,EXTERNAL:PLAINTEXT,PLAINTEXT:PLAINTEXT
listeners=INTERNAL://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093,EXTERNAL://0.0.0.0:29092
advertised.listeners=INTERNAL://10.0.0.45:9092,EXTERNAL://192.168.1.54:29092
inter.broker.listener.name=INTERNAL
```

| | 주센터 Kafka | DR Kafka |
|---|---|---|
| INTERNAL advertised | `192.168.1.54:19092` (주센터 HAProxy) | `10.0.0.45:9092` (DR 내부 직접) |
| EXTERNAL advertised | `172.30.1.223:19092` (DR HAProxy) | `192.168.1.54:29092` (주센터 HAProxy) |
| INTERNAL 사용 클라이언트 | DR Logstash | 주센터 Logstash |
| EXTERNAL 사용 클라이언트 | 주센터 내부 클라이언트 | - |

**동작 흐름 (DR Logstash → 주센터 Kafka)**
```
DR Logstash
  → 172.30.1.223:19092 (DR HAProxy, bootstrap)
    → 192.168.1.54:19092 (주센터 HAProxy)
      → 주센터 Kafka (INTERNAL 리스너로 접속)
        → 브로커가 INTERNAL advertised "192.168.1.54:19092" 반환
          → DR Logstash가 192.168.1.54:19092로 재연결 성공
```

**동작 흐름 (주센터 Logstash → DR Kafka)**
```
주센터 Logstash
  → 192.168.1.54:29092 (주센터 HAProxy, bootstrap)
    → DR HAProxy 172.30.1.223:29092
      → DR Kafka 10.0.0.45:29092 (EXTERNAL 리스너로 접속) ← HAProxy가 EXTERNAL 포트로 연결해야 함
        → 브로커가 EXTERNAL advertised "192.168.1.54:29092" 반환
          → 주센터 Logstash가 192.168.1.54:29092로 재연결 성공
```

**DR HAProxy 주의사항**: 외부 클라이언트용 포트(`29092~29094`)는 반드시 DR 브로커의 **EXTERNAL 포트**로 연결해야 함.
```
# 잘못된 설정 (INTERNAL 포트로 연결 → 내부 IP 반환 → 재연결 실패)
server dr-kafka1 10.0.0.45:9092

# 올바른 설정 (EXTERNAL 포트로 연결 → 주센터 HAProxy IP 반환 → 재연결 성공)
server dr-kafka1 10.0.0.45:29092
```

### 기타 핵심 요점

- `balance source` 필수: 같은 클라이언트가 항상 같은 브로커로 연결되도록 보장
- 브로커 수만큼 포트를 별도로 열어야 함 (브로커 1개 = 포트 1개)

---

## 배포 시 필요한 파일 목록

### 공통 (주센터/DR센터 동일)

| 파일 | 배치 경로 | 설명 |
|------|----------|------|
| `mariadb-java-client-3.5.8.jar` | `/usr/share/logstash/logstash-core/lib/jars/` | MariaDB JDBC 드라이버. 이 경로에 두면 JVM classpath 자동 등록 |
| `logstash.yml` | `/etc/logstash/logstash.yml` | Logstash 기본 설정. `path.config` 항목 주석 처리 필수 |
| `pipelines.yml` | `/etc/logstash/pipelines.yml` | `main` + `cdc` 파이프라인 등록 |

### DR센터 Logstash (center.* 토픽 컨슘 → DR DB 반영)

| 파일 | 배치 경로 |
|------|----------|
| `dr/cdc-10-input.conf` | `/etc/logstash/conf_cdc/cdc-10-input.conf` |
| `dr/cdc-20-filter.conf` | `/etc/logstash/conf_cdc/cdc-20-filter.conf` |
| `dr/cdc-30-output.conf` | `/etc/logstash/conf_cdc/cdc-30-output.conf` |
| `dr/cdc_upsert.rb` | `/etc/logstash/conf_cdc/cdc_upsert.rb` |
| `dr/cdc_delete.rb` | `/etc/logstash/conf_cdc/cdc_delete.rb` |

### 주센터 Logstash (dr.* 토픽 컨슘 → 주센터 DB 반영)

| 파일 | 배치 경로 |
|------|----------|
| `center/cdc-10-input.conf` | `/etc/logstash/conf_cdc/cdc-10-input.conf` |
| `center/cdc-20-filter.conf` | `/etc/logstash/conf_cdc/cdc-20-filter.conf` |
| `center/cdc-30-output.conf` | `/etc/logstash/conf_cdc/cdc-30-output.conf` |
| `center/cdc_upsert.rb` | `/etc/logstash/conf_cdc/cdc_upsert.rb` |
| `center/cdc_delete.rb` | `/etc/logstash/conf_cdc/cdc_delete.rb` |

---

## 배포 절차

### 사전 준비 (최초 1회)

```bash
# conf 디렉토리 생성
mkdir -p /etc/logstash/conf_cdc

# MariaDB JDBC 드라이버 배치
cp mariadb-java-client-3.5.8.jar /usr/share/logstash/logstash-core/lib/jars/

# logstash.yml 배포 (기존 파일의 path.config 항목 주석 처리 후)
cp logstash.yml /etc/logstash/logstash.yml

# pipelines.yml 배포
cp pipelines.yml /etc/logstash/pipelines.yml
```

> **주의**: 기존 `logstash.yml`에 `path.config`가 설정되어 있으면 `pipelines.yml`과 충돌합니다.
> `path.config` 항목을 반드시 주석 처리해야 합니다.

### DR센터 Logstash

```bash
cp dr/cdc-*.conf dr/cdc_*.rb /etc/logstash/conf_cdc/

systemctl restart logstash
systemctl status logstash

# 컨슈머 그룹 확인 (Num Of Topics, Consumer Lag 체크)
kafka-consumer-groups.sh --bootstrap-server 10.0.0.45:9092 \
  --describe --group cdc-logstash-dr
```

### 주센터 Logstash

```bash
cp center/cdc-*.conf center/cdc_*.rb /etc/logstash/conf_cdc/

systemctl restart logstash
systemctl status logstash

# 컨슈머 그룹 확인
kafka-consumer-groups.sh --bootstrap-server 192.168.1.54:29092 \
  --describe --group cdc-logstash-center
```

---

## 모니터링

```bash
# 실시간 에러 확인
journalctl -u logstash -f | grep -E "CDC|ERROR"

# 컨슈머 랙 확인
kafka-consumer-groups.sh --bootstrap-server <kafka>:9092 \
  --describe --group cdc-logstash-dr

# DLQ 토픽 메시지 확인
kafka-console-consumer.sh --bootstrap-server <kafka>:9092 \
  --topic cdc-delete-dlq --from-beginning
```

---

## 트러블슈팅

| 증상 | 원인 | 해결 |
|------|------|------|
| 토픽 파싱 실패, 전체 drop | `decorate_events => true` 누락 | input에 추가 |
| `ECP_ADMIN` schema 파싱 실패 | grok `%{WORD}`가 `_` 미지원 | ruby split으로 교체 |
| JDBC `{}` escape 오류 | jdbc output plugin 한계 | filter ruby 직접 JDBC 실행 |
| DELETE가 DB에 반영 안 됨 | `delete.handling.mode` 구버전 옵션명 | `delete.tombstone.handling.mode`로 변경 |
| Num Of Topics가 안 늘어남 | `topics_pattern` 이스케이프 버그 | `center...*` 패턴 사용 |
| Logstash shutdown stall | DB 커넥션이 열린 채 종료 시도 | 정상 동작, 잠시 후 강제 종료됨 |
| cdc 파이프라인이 뜨지 않음, 컨슈머 그룹 미생성 | `logstash.yml`의 `path.config`가 주석 처리 안 됨 → `pipelines.yml` 무시됨 | `path.config` 항목 주석 처리 후 재시작 |
