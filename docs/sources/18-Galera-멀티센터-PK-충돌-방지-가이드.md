# Galera 멀티센터 PK 충돌 방지 가이드

> 주센터 + DR센터 양방향 CDC(Active-Active) 구성 시 AUTO_INCREMENT PK 충돌 문제와 방지 방법을 설명합니다.

---

## 목차

1. [문제 배경](#1-문제-배경)
2. [어떤 상황에서 충돌이 발생하는가](#2-어떤-상황에서-충돌이-발생하는가)
3. [해결 방법: AUTO_INCREMENT Offset 분리](#3-해결-방법-auto_increment-offset-분리)
4. [설정 적용 방법](#4-설정-적용-방법)
5. [적용 후 검증](#5-적용-후-검증)
6. [DR 전환 시나리오](#6-dr-전환-시나리오)
7. [한계 및 추가 고려사항](#7-한계-및-추가-고려사항)

---

## 1. 문제 배경

### 구성 환경

```
┌─────────────────────────┐          ┌─────────────────────────┐
│       주센터             │          │       DR센터             │
│  Galera Cluster (3노드)  │◄──CDC───►│  Galera Cluster (3노드)  │
│                         │          │                         │
│  쓰기/읽기 모두 처리      │          │  평상시 수신, DR 시 쓰기  │
└─────────────────────────┘          └─────────────────────────┘
```

- 주센터: 평상시 쓰기 주도
- DR센터: 주센터 데이터를 CDC로 수신, 장애 시 쓰기 전환
- 양방향 CDC이므로 DR센터에서 발생한 쓰기도 주센터로 전파됨

### Galera의 AUTO_INCREMENT 기본 동작

Galera는 `wsrep_auto_increment_control = ON`이 기본값으로, **클러스터 내 노드 수에 맞춰 자동으로** `auto_increment_increment`와 `auto_increment_offset`을 조정합니다.

예) 3노드 클러스터:
- node1: 1, 4, 7, 10 ...
- node2: 2, 5, 8, 11 ...
- node3: 3, 6, 9, 12 ...

이 방식은 **단일 클러스터 내** 충돌을 막아줍니다.  
하지만 **센터 간(주센터 ↔ DR센터)** 충돌은 막지 못합니다.

---

## 2. 어떤 상황에서 충돌이 발생하는가

### 2.1 기본 충돌 시나리오

`wsrep_auto_increment_control = ON` 상태에서 3노드 클러스터 두 개(주/DR)가 운영되면:

| 센터 | 생성되는 id |
|------|------------|
| 주센터 node1 | 1, 4, 7, 10 ... |
| 주센터 node2 | 2, 5, 8, 11 ... |
| 주센터 node3 | 3, 6, 9, 12 ... |
| DR센터 node1 | 1, 4, 7, 10 ... ← **주센터와 동일** |
| DR센터 node2 | 2, 5, 8, 11 ... ← **주센터와 동일** |
| DR센터 node3 | 3, 6, 9, 12 ... ← **주센터와 동일** |

→ 주센터 `id=1`과 DR센터 `id=1`이 **서로 다른 데이터**를 가리킴.

### 2.2 CDC Upsert에서의 영향

Debezium → JDBC Sink 파이프라인에서 upsert 기준이 PK일 때:

```
주센터: INSERT id=1, name='홍길동'  (고객 A)
DR센터: INSERT id=1, name='김철수'  (고객 B)
```

Sink 타겟에서 나중에 도착한 이벤트가 먼저 온 것을 **덮어씌움** → 데이터 유실.

### 2.3 DR 전환 후 복귀 시 충돌

1. 주센터 장애 → DR센터에서 쓰기 시작, `id=1, 2, 3 ...` 생성
2. 주센터 복구 → 주센터도 `id=1, 2, 3 ...`부터 다시 생성
3. 양쪽에 동일 PK, 다른 데이터 존재 → 복제 충돌

---

## 3. 해결 방법: AUTO_INCREMENT Offset 분리

### 핵심 원리

센터별로 생성되는 PK 범위가 **절대 겹치지 않도록** offset을 다르게 설정합니다.

```
주센터: auto_increment_offset = 1  →  1, 3, 5, 7, 9 ... (홀수)
DR센터: auto_increment_offset = 2  →  2, 4, 6, 8, 10 ... (짝수)
```

### 필수 설정값

| 항목 | 의미 |
|------|------|
| `wsrep_auto_increment_control = OFF` | Galera 자동 제어 비활성화 (수동 설정 유지) |
| `auto_increment_increment = 2` | 총 센터 수 (센터가 늘면 이 값도 증가) |
| `auto_increment_offset = 1 or 2` | 센터 식별자 (주센터=1, DR센터=2) |

> **왜 OFF가 필요한가?**  
> `wsrep_auto_increment_control = ON`이면 Galera가 노드 수 기준으로 위 값을 **덮어씁니다**.  
> 수동으로 센터별 offset을 유지하려면 반드시 OFF로 설정해야 합니다.

---

## 4. 설정 적용 방법

### 4.1 my.cnf 수정

**주센터 3노드 모두:**

```ini
# /etc/my.cnf
wsrep_auto_increment_control = OFF
auto_increment_increment     = 2
auto_increment_offset        = 1
```

**DR센터 3노드 모두:**

```ini
# /etc/my.cnf
wsrep_auto_increment_control = OFF
auto_increment_increment     = 2
auto_increment_offset        = 2
```

### 4.2 재시작 (⚠️ 반드시 1노드씩 순서대로)

> 동시 재시작 시 quorum을 잃어 클러스터 복구 절차가 필요해집니다.

```bash
# 각 노드에서 순서대로 실행
sudo systemctl restart mariadb

# Synced 확인 후 다음 노드 진행
mysql -u root -S /var/lib/mysql/mysql.sock \
  -e "SHOW STATUS LIKE 'wsrep_local_state_comment';"
# → Synced 가 나와야 다음 노드 재시작
```

---

## 5. 적용 후 검증

### 5.1 설정값 확인

```sql
SHOW VARIABLES LIKE 'auto_increment%';
SHOW VARIABLES LIKE 'wsrep_auto_increment_control';
```

**주센터 기대 출력:**

```
+------------------------------+-------+
| Variable_name                | Value |
+------------------------------+-------+
| auto_increment_increment     | 2     |
| auto_increment_offset        | 1     |
| wsrep_auto_increment_control | OFF   |
+------------------------------+-------+
```

**DR센터 기대 출력:**

```
+------------------------------+-------+
| Variable_name                | Value |
+------------------------------+-------+
| auto_increment_increment     | 2     |
| auto_increment_offset        | 2     |
| wsrep_auto_increment_control | OFF   |
+------------------------------+-------+
```

### 5.2 PK 범위 검증

```sql
-- 주센터에서 INSERT 3건
INSERT INTO test_table (name) VALUES ('주1'), ('주2'), ('주3');
SELECT id, name FROM test_table ORDER BY id DESC LIMIT 3;
-- id: 1, 3, 5 (홀수) 이어야 함

-- DR센터에서 INSERT 3건
INSERT INTO test_table (name) VALUES ('DR1'), ('DR2'), ('DR3');
SELECT id, name FROM test_table ORDER BY id DESC LIMIT 3;
-- id: 2, 4, 6 (짝수) 이어야 함
```

---

## 6. DR 전환 시나리오

### 평상시

```
주센터 (쓰기) ──CDC──► DR센터 (수신)
             ◄──CDC──
```

- 주센터 id: 1, 3, 5, 7 ...
- DR센터는 수신만 하므로 id 생성 없음

### DR 전환 (주센터 장애)

```
주센터 (장애) ✗         DR센터 (쓰기 전환)
```

- DR센터가 쓰기를 받기 시작: id = 2, 4, 6, 8 ...
- 주센터 복구 후 재합류해도 offset이 달라 **PK 충돌 없음**

### 주센터 복구 후 재동기화

```
주센터 (복구) ◄──CDC──  DR센터
             ──CDC──►
```

- 주센터는 DR센터에서 생성된 짝수 id 데이터를 수신
- 주센터 자체 쓰기는 다시 홀수 id부터 이어감
- **충돌 없이 양방향 동기화 정상화**

---

## 7. 한계 및 추가 고려사항

### 기존 데이터가 있는 경우

offset 설정 전에 이미 데이터가 있으면, 양 센터의 id가 겹칠 수 있습니다.

```sql
-- 현재 최대 id 확인
SELECT MAX(id) FROM your_table;

-- 주센터 최대 id가 1000이면
-- DR센터 AUTO_INCREMENT 시작값을 1002 이상으로 맞춰야 안전
ALTER TABLE your_table AUTO_INCREMENT = 1002;
```

### UUID PK가 더 근본적인 해결책

offset 방식은 센터 수가 늘면 `increment` 값도 바꿔야 하고, 기존 데이터 조정도 필요합니다.  
신규 테이블 설계 시에는 UUID PK가 더 안전합니다.

```sql
CREATE TABLE example (
    id   CHAR(36) DEFAULT (UUID()) PRIMARY KEY,
    name VARCHAR(100)
);
```

### SEQUENCE 객체는 별도 처리 필요

Galera에서 `CACHE` 옵션이 있는 SEQUENCE는 지원하지 않습니다.  
덤프 복원 시 아래 처리가 필요합니다:

```bash
sed -i 's/[Cc][Aa][Cc][Hh][Ee] [0-9]*/nocache/g' backup.sql
```
