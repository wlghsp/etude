# Logstash 로깅 전략 가이드

## 개요

Logstash에는 세 개의 파이프라인이 운영 중이며, 로그가 단일 파일에 혼재되면 에러 파악이 어렵다.
이를 해결하기 위해 `log4j2.xml`의 `RoutingAppender`로 파이프라인별 로그 파일을 분리한다.

---

## 파이프라인 구성

`pipelines.yml` 기준:

| pipeline.id | conf 경로 | 역할 |
|-------------|-----------|------|
| `input-process` | `/etc/logstash/conf.d/10-input-filter.conf` | Kafka 메트릭/로그 수신 및 필터 처리 |
| `output-main` | `/etc/logstash/conf.d/20-output-main.conf` | Elasticsearch 전송 (update/upsert) |
| `cdc` | `/etc/logstash/conf_cdc/*.conf` | CDC — 반대 센터 Kafka 토픽 컨슘 → 로컬 MariaDB 반영 |

---

## 로그 파일 구조

```
/applog/logstash/
├── logstash-plain.log          # 전체 fallback (시스템 로그, pipeline에 속하지 않는 로그)
├── logstash-plain-yyyy-MM-dd.log
├── logstash-cdc.log            # cdc 파이프라인 전용
├── logstash-cdc-yyyy-MM-dd.log
├── logstash-main.log           # input-process, output-main 파이프라인 전용
└── logstash-main-yyyy-MM-dd.log
```

---

## 보관 정책

| 파일 | 보관 기간 | 근거 |
|------|-----------|------|
| `logstash-plain.log` | 10일 | 시스템/fallback 로그, 단기 참조용 |
| `logstash-cdc.log` | 30일 | DB 동기화 실패 추적 및 재처리 판단에 장기 보관 필요 |
| `logstash-main.log` | 14일 | 메트릭 파이프라인, 중기 이슈 대응용 |

롤링 주기: 1일 단위 (`TimeBasedTriggeringPolicy`)
최대 파일 수: 각 보관 기간만큼 (`DefaultRolloverStrategy.max`)

---

## 설정 파일

`log4j2.xml` — `/etc/logstash/log4j2.xml` 에 배포

### 핵심 구조

Logstash는 파이프라인 실행 시 MDC(Mapped Diagnostic Context)에 `pipeline.id` 값을 자동으로 넣는다.
`RoutingAppender`가 이 값을 읽어 파일을 동적으로 분기한다.

```
RoutingAppender ($${ctx:pipeline.id})
├── cdc           → cdc_rolling    → logstash-cdc.log
├── input-process → main_rolling   → logstash-main.log
├── output-main   → main_rolling   → logstash-main.log
└── (없음/기타)   → plain_rolling  → logstash-plain.log  (fallback)
```

`logstash-plain.log`의 패턴에는 `[%X{pipeline.id}]`가 포함되어 있어, fallback 로그에서도 출처 파이프라인을 구분할 수 있다.

---

## CDC 파이프라인에서 주목할 로그

CDC는 DB 동기화 실패 시 에러를 명시적으로 로깅하므로 `logstash-cdc.log`를 우선 확인한다.

| 상황 | 로그 내용 |
|------|-----------|
| DB 실행 실패 | `CDC DB 실행 실패 schema=... table=... op=... error=...` |
| JSON 파싱 실패 | `_jsonparsefailure` 태그로 drop 처리 |
| 알 수 없는 schema | `[@metadata][op] = dlq` → `cdc-garbage` 토픽으로 라우팅 |
| DB 실행 실패 DLQ | `[@metadata][op] = db_error` → `cdc-recovery` 토픽으로 라우팅 |

---

## 배포 절차

### 1. 설정 파일 복사

```bash
cp logstash/log4j2.xml /etc/logstash/log4j2.xml

# 기존 properties 파일 백업 (있는 경우)
mv /etc/logstash/log4j2.properties /etc/logstash/log4j2.properties.bak
```

### 2. logstash.service 수정

`/etc/systemd/system/logstash.service` 의 `[Service]` 섹션에 아래 항목 추가:

```ini
Environment="LS_JAVA_OPTS=-Dlog4j.configurationFile=/etc/logstash/log4j2.xml"
```

적용 후 전체 `[Service]` 섹션 예시:

```ini
[Service]
Type=simple
User=logstash
Group=logstash
Environment="JAVA_HOME=/usr/lib/jvm/java-11-openjdk-..."
Environment="PATH=..."
Environment="LS_JAVA_OPTS=-Dlog4j.configurationFile=/etc/logstash/log4j2.xml"
ExecStart=/usr/share/logstash/bin/logstash "--path.settings" "/etc/logstash"
Restart=always
WorkingDirectory=/
Nice=19
LimitNOFILE=65535
```

### 3. 재시작

```bash
systemctl daemon-reload
systemctl restart logstash
```

### 4. 분리 확인

```bash
tail -f /applog/logstash/logstash-plain.log /applog/logstash/logstash-main.log /applog/logstash/logstash-cdc.log
```
