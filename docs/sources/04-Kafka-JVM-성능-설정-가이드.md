# Kafka JVM 성능 설정 가이드

## 인프라 스펙

| 센터 | vCPU | RAM | 대수 |
|---|---|---|---|
| 주센터 | 4 | 16GB | 3 |
| DR센터 | 4 | 8GB | 3 |

---

## JVM 힙 설정

systemd 서비스 파일(`/etc/systemd/system/kafka.service`)의 `[Service]` 섹션에 추가.

```ini
[Service]
# 주센터 (RAM 16GB) — 힙은 RAM의 ~35%
Environment="KAFKA_HEAP_OPTS=-Xms6g -Xmx6g"
Environment="KAFKA_JVM_PERFORMANCE_OPTS=-XX:+UseG1GC -XX:MaxGCPauseMillis=20 -XX:+ExplicitGCInvokesConcurrent"

# DR센터 (RAM 8GB) — 힙은 RAM의 ~50%
Environment="KAFKA_HEAP_OPTS=-Xms4g -Xmx4g"
Environment="KAFKA_JVM_PERFORMANCE_OPTS=-XX:+UseG1GC -XX:MaxGCPauseMillis=20 -XX:+ExplicitGCInvokesConcurrent"
```

적용 후 반드시 reload:
```bash
systemctl daemon-reload && systemctl restart kafka
```

### 힙을 작게 잡는 이유

Kafka의 실제 I/O 성능은 JVM 힙이 아닌 **OS PageCache**에 달려 있다. 프로듀서/컨슈머가 읽고 쓰는 세그먼트 파일을 OS가 메모리에 캐싱하는데, 힙을 크게 잡으면 PageCache에 할당될 메모리가 줄어들어 디스크 I/O가 증가한다. 힙이 클수록 GC pause도 길어져 지연이 발생한다.

- 주센터: 힙 6GB → 나머지 ~10GB를 PageCache로 활용
- DR센터: 힙 4GB → 나머지 ~4GB를 PageCache로 활용

---

## server.properties 성능 설정

```properties
# 주센터 (vCPU 4)
num.network.threads=4
num.io.threads=8

# DR센터 (vCPU 4)
num.network.threads=3
num.io.threads=4
```

DR센터는 주센터 대비 처리량이 낮고 RAM도 절반이므로 스레드 수를 줄여 자원 낭비를 방지한다.

---

## 3중화 HA 구조

3-브로커 클러스터에서 `replication.factor=3`, `min.insync.replicas=2`로 설정하면 브로커 1대가 다운되어도 데이터 손실 없이 서비스가 유지된다. 각 브로커는 파티션의 일부만 리더를 담당하고 나머지는 팔로워로 복제를 받는다.

---

## 병목 진단 순서

실제 성능 문제가 생겼을 때 확인 순서:

1. **처리 지연(lag) 증가** → `num.network.threads` / `num.io.threads` 조정
   - 네트워크 연결이 많으면 `num.network.threads` 증가 (vCPU의 1~2배)
   - 디스크 I/O가 병목이면 `num.io.threads` 증가 (vCPU의 2~3배)

2. **디스크 I/O 높음** → PageCache 부족 의심
   - 힙을 줄여 OS PageCache에 메모리 더 확보
   - `kafka-log-dirs.sh`로 파티션별 크기 확인

3. **GC pause 빈번** → 힙 조정 또는 GC 옵션 검토
   - `jstat -gcutil <pid> 1000`으로 GC 빈도/시간 확인
   - `-XX:MaxGCPauseMillis` 값 조정 (낮추면 GC 빈도 증가, 높이면 pause 길어짐)

4. **컨슈머 lag 지속 증가** → 파티션 수 부족 가능성
   - 파티션 수 = 목표 처리량 / 파티션당 처리량으로 계산
   - 파티션 수는 늘릴 수 있지만 줄이는 것은 불가 (신중하게)

5. **브로커 간 부하 불균형** → 리더 파티션 재분배
   - `kafka-leader-election.sh --election-type PREFERRED`로 리더 재분배

---

## 현재 JVM 설정 확인

```bash
ps aux | grep kafka | grep -o '\-Xm[sx][^ ]*'
```

---

## 요약

| 센터 | 힙 | network.threads | io.threads |
|---|---|---|---|
| 주 | 6GB | 4 | 8 |
| DR | 4GB | 3 | 4 |
