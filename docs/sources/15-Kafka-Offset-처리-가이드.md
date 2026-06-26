# Kafka 오프셋(Offset) 처리 가이드

## 오프셋이 두 종류다

Kafka 파이프라인에서 "오프셋"은 완전히 다른 두 가지를 가리킵니다.

---

## 1. Kafka 브로커의 오프셋 (Consumer Offset)

Kafka 토픽의 각 파티션은 메시지마다 순서 번호를 붙입니다.

```
파티션 0: [0] [1] [2] [3] [4] [5] ...
                        ↑
                   consumer가 여기까지 읽음 (offset=3)
```

컨슈머는 "나는 파티션 0에서 offset 3까지 읽었다"를 `__consumer_offsets` 내부 토픽에 저장합니다. 이게 **commit** 입니다.

컨슈머가 죽었다 살아나면 `__consumer_offsets`를 읽어서 마지막 commit 위치부터 재개합니다.

**auto.offset.reset** — 처음 본 토픽이거나 offset이 없을 때:
- `earliest` → 파티션 맨 처음부터
- `latest` → 지금 이후 들어오는 것만

---

## 2. Kafka Connect의 오프셋 (Source Connector)

Debezium 같은 Source Connector는 완전히 다른 오프셋을 씁니다.

MariaDB binlog 위치를 추적합니다:

```json
{
  "file": "mysql-bin.000123",
  "pos": 4892341
}
```

이걸 `connect-offsets` 내부 토픽에 저장합니다. 재시작하면 이 binlog 위치부터 다시 읽습니다.

Sink Connector는 Kafka 메시지를 DB에 쓰는 쪽이라 Consumer Offset 방식을 씁니다.

---

## 3. 이 파이프라인에 대입하면

```
MariaDB binlog
    ↓
Debezium Source Connector
  → 오프셋: binlog file+pos → connect-offsets 토픽에 저장
    ↓
Kafka 토픽 (dr.ECP_ADMIN.TADP_PRJCT 등)
    ↓
Logstash (kafka input)
  → 오프셋: consumer offset → __consumer_offsets 토픽에 저장
    ↓
MariaDB (싱크 DB)
```

Logstash는 내부적으로 Kafka 컨슈머입니다. `group.id`로 묶인 컨슈머 그룹이 offset을 관리하므로, 재시작해도 같은 `group.id`면 이어서 처리합니다.

---

## 4. 오프셋 비교 요약

| | Debezium (Source) | Logstash (Consumer) |
|---|---|---|
| 추적 대상 | binlog 위치 | Kafka 메시지 offset |
| 저장 위치 | `connect-offsets` 토픽 | `__consumer_offsets` 토픽 |
| 재시작 시 | binlog 해당 위치부터 재읽기 | 마지막 commit offset부터 재처리 |
| 중복 가능성 | 있음 (at-least-once) | 있음 (at-least-once) |

---

## 5. 중복 메시지와 UPSERT

at-least-once 특성상 같은 메시지가 두 번 올 수 있습니다. 그래서 이 파이프라인이 `INSERT ... ON DUPLICATE KEY UPDATE` (upsert) 방식을 쓰는 이유가 여기 있습니다. 같은 메시지가 두 번 와도 멱등하게 처리됩니다.

### upsert 시 값은 마지막으로 처리된 메시지 기준

```sql
INSERT INTO ECP_ADMIN.TADP_PRJCT (PRJCT_ID, PRJCT_NM, UPD_DT, ...)
VALUES ('proj-001', '프로젝트A', 1736933400000, ...)
ON DUPLICATE KEY UPDATE
  PRJCT_NM = '프로젝트A',
  UPD_DT   = 1736933400000,
  ...
```

UPDATE 절에 모든 컬럼이 포함되므로 나중에 처리된 메시지 값으로 덮어씌워집니다.

단, **중복 메시지는 동일한 이벤트의 재전송**이라 값 자체는 같습니다. 실제로 다른 값이 덮어씌워지는 상황은 이벤트 순서가 뒤바뀐 경우인데, Kafka는 파티션 내 순서를 보장하고 같은 PK의 이벤트는 같은 파티션에 들어가므로 정상 운영 중에는 발생하지 않습니다.
