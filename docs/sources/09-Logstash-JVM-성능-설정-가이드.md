# Logstash JVM 성능 설정 가이드

## 인프라 스펙

| 센터 | vCPU | RAM | 대수 |
|---|---|---|---|
| 주센터 | 4 | 24GB | 2 |
| DR센터 | 4 | 16GB | 2 |

---

## JVM 힙 설정

`/etc/logstash/jvm.options` 수정. `-Xms`와 `-Xmx`는 반드시 동일하게 설정.

```
# 주센터 (RAM 24GB)
-Xms4g
-Xmx4g

# DR센터 (RAM 16GB)
-Xms2g
-Xmx2g
```

### 힙 크기 근거

Logstash는 파이프라인 처리 중 이벤트 객체를 힙에 올리므로 JVM 힙이 중요하다. 다만 힙을 과도하게 잡으면 GC pause가 길어져 파이프라인 지연이 발생한다. RAM의 약 15~20% 수준으로 유지하고, 실제 병목은 힙보다 파이프라인 설정(`pipeline.workers`, `pipeline.batch.size`)에서 먼저 확인한다.

### GC 옵션

```
-XX:+UseG1GC
-XX:MaxGCPauseMillis=20
-XX:+ExplicitGCInvokesConcurrent
```

---

## logstash.yml 파이프라인 설정

```yaml
# vCPU 4 기준
pipeline.workers: 4
pipeline.batch.size: 125
pipeline.batch.delay: 50
```

### 설정 근거

- `pipeline.workers`: 일반적으로 vCPU 수와 동일하게 설정. CPU 바운드 필터가 많으면 늘릴 수 있으나, CDC 파이프라인은 **이벤트 순서 보장**이 중요하므로 보수적으로 유지한다. workers를 늘리면 처리량은 올라가지만 이벤트 순서가 뒤섞일 수 있다.
- `pipeline.batch.size`: 한 번에 처리할 이벤트 수. 너무 크면 메모리 압박 및 지연 증가, 너무 작으면 처리량 감소. 125는 Logstash 기본값으로 CDC 워크로드에 무난하다.
- `pipeline.batch.delay`: 배치가 꽉 차지 않을 때 대기하는 시간(ms). 낮추면 지연이 줄지만 CPU 사용량 증가.

---

## 2중화 구조 특성

주센터/DR센터 각 2대는 Active-Active 구조로 동시에 파이프라인을 처리한다. HA보다는 **처리량 분산** 목적이며, 1대가 다운되면 나머지 1대가 전체 부하를 받게 된다. Kafka 3중화와 달리 Logstash 레벨의 진정한 HA는 제한적이다.

---

## 병목 진단 순서

실제 성능 문제가 생겼을 때 확인 순서:

1. `pipeline.workers` / `pipeline.batch.size` 튜닝
2. 필터 플러그인 복잡도 확인 (정규식, grok 등)
3. 출력 플러그인(JDBC, ES 등) 응답 지연 확인
4. 그래도 부족하면 힙 증량 검토

---

## 현재 JVM 설정 확인

```bash
ps aux | grep logstash | grep -o '\-Xm[sx][^ ]*'
```

---

## 요약

| 센터 | 힙 | pipeline.workers | pipeline.batch.size |
|---|---|---|---|
| 주 | 4GB | 4 | 125 |
| DR | 2GB | 4 | 125 |
