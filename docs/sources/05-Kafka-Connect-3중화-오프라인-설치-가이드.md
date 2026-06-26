# Kafka Connect 3중화 오프라인 설치 가이드

> 사전 조건: Kafka 3중화 오프라인 설치 완료 필수  
> 다음 단계: Kafka-Connect-Debezium-완전-설치-가이드 참고

**구성:**
```
Kafka Broker 서버 (3대 공통)
├─ Kafka Broker     (port 9092)
├─ Kafka Controller (port 9093)
└─ Kafka Connect    (port 8083) ← 이 문서에서 설치
```

---

## 1. 파일 준비 (맥에서)

```
kafka-connect-plugins/
├── debezium-connector-mariadb-3.4.0.Final-plugin.tar.gz
├── confluentinc-kafka-connect-jdbc-10.9.2.tar.gz
└── mariadb-java-client-3.5.8.jar

kafka-connect-addon/
├── connect-distributed.broker1.properties.template   # configs/ 에서 복사
├── connect-distributed.broker2.properties.template
└── connect-distributed.broker3.properties.template
```

**서버로 전송:**
```bash
BROKER1=10.0.0.45
BROKER2=10.0.0.46
BROKER3=10.0.0.47

for H in $BROKER1 $BROKER2 $BROKER3; do
  scp ~/kafka-connect-plugins/* 사용자명@$H:~/
  scp -r ~/kafka-connect-addon 사용자명@$H:~/
done
```

---

## 2. 플러그인 설치 (3대 공통)

```bash
sudo mkdir -p /opt/kafka/plugins
cd /opt/kafka/plugins

sudo tar -xzf ~/debezium-connector-mariadb-3.4.0.Final-plugin.tar.gz
sudo tar -xzf ~/confluentinc-kafka-connect-jdbc-10.9.2.tar.gz

# MariaDB 드라이버를 JDBC 플러그인에 추가
sudo cp ~/mariadb-java-client-3.5.8.jar /opt/kafka/plugins/confluentinc-kafka-connect-jdbc-10.9.2/

sudo chown -R kafka:kafka /opt/kafka/plugins
```

**확인:**
```bash
ls /opt/kafka/plugins/
# debezium-connector-mariadb/
# confluentinc-kafka-connect-jdbc-10.9.2/
```

---

## 3. Connect 설정 (노드별)

브로커별 전용 템플릿(`connect-distributed.broker1~3.properties.template`)을 사용합니다.  
`rest.advertised.host.name`이 미리 설정되어 있으므로 **`BOOTSTRAP_SERVERS`만 치환**하면 됩니다.

**브로커1에서 예시 (bootstrap: 10.0.0.45~47):**

```bash
sudo mkdir -p /opt/kafka/config/connect /opt/kafka/logs

sudo cp ~/kafka-connect-addon/connect-distributed.broker1.properties.template \
  /opt/kafka/config/connect/connect-distributed.properties

BOOTSTRAP="10.0.0.45:9092,10.0.0.46:9092,10.0.0.47:9092"
sudo sed -i "s|BOOTSTRAP_SERVERS|$BOOTSTRAP|g" \
  /opt/kafka/config/connect/connect-distributed.properties

sudo chown kafka:kafka /opt/kafka/config/connect/connect-distributed.properties
```

**브로커2:** `connect-distributed.broker2.properties.template` 사용, 동일한 BOOTSTRAP 치환.  
**브로커3:** `connect-distributed.broker3.properties.template` 사용, 동일한 BOOTSTRAP 치환.

> **내부 토픽 주의사항:**  
> 내부 토픽(`connect-offsets`, `connect-config`, `connect-status`)은 반드시 `cleanup.policy=compact`여야 합니다.  
> delete 정책으로 자동 생성되면 Connect가 반복 시작 실패합니다.  
> → CONNECT-TOPICS-RESET.md 참고

---

## 4. Systemd 서비스 등록 (3대 공통)

```bash
sudo cp ~/kafka-connect-addon/kafka-connect.service /etc/systemd/system/kafka-connect.service
sudo systemctl daemon-reload
sudo systemctl enable kafka-connect
sudo systemctl start kafka-connect
```

---

## 5. 확인

```bash
# 서비스 상태
sudo systemctl status kafka-connect

# REST API 응답 확인 (버전 정보 반환되면 정상)
curl -s http://localhost:8083/ | jq .

# 플러그인 목록 확인 (MariaDbConnector 있어야 함)
curl -s http://localhost:8083/connector-plugins | jq '.[].class'
```

---

## 트러블슈팅

### Connect가 시작되지 않음

```bash
sudo journalctl -u kafka-connect -n 50 --no-pager
```

| 원인 | 해결 |
|------|------|
| Broker 미실행 | `sudo systemctl start kafka` 후 재시도 |
| bootstrap.servers 오류 | 설정 파일 IP 확인 |
| 포트 충돌 (8083) | `netstat -tulpn \| grep 8083` |
| 토픽 cleanup.policy 오류 | CONNECT-TOPICS-RESET.md 참고 |

### Connect 클러스터 초기화

```bash
sudo systemctl stop kafka-connect

/opt/kafka/bin/kafka-topics.sh --delete \
  --bootstrap-server localhost:9092 \
  --topic connect-status,connect-config,connect-offsets

sudo systemctl start kafka-connect
```

---

## 체크리스트

- [ ] 3대 모두 플러그인 설치 완료
- [ ] 3대 모두 `connect-distributed.properties` 배포 및 IP 치환 확인
- [ ] 3대 모두 `kafka-connect` 서비스 `active (running)`
- [ ] `curl http://localhost:8083/ | jq .` → 버전 정보 출력
- [ ] `curl http://localhost:8083/connector-plugins | jq '.[].class'` → MariaDbConnector 확인
- [ ] `/opt/kafka/logs/connect.log` 생성 확인
- [ ] 다음: Kafka-Connect-Debezium-완전-설치-가이드 진행
