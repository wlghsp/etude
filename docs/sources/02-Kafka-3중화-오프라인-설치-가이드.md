# Kafka 3중화 오프라인 설치 가이드 (맥 → 서버)

현장이 폐쇄망이므로 **맥에서 설치 파일을 준비**한 뒤 서버로 전송하고, **기존 설치를 제거**한 다음 **오프라인으로 처음부터 설치**하는 흐름입니다.  
이 문서만 따라하면 동일한 방식으로 연습·현장 적용이 가능합니다.

- **Kafbat** 오프라인은 6장 참고하세요.

---

## 목차

1. [설치 파일 준비 (맥에서)](#1-설치-파일-준비-맥에서)
2. [서버로 전송](#2-서버로-전송)
3. [기존 Kafka 설치 제거 (서버, 있을 경우)](#3-기존-kafka-설치-제거-서버-있을-경우)
4. [서버에서 오프라인 설치](#4-서버에서-오프라인-설치)
5. [설치 후 확인](#5-설치-후-확인)
6. [Kafka UI 설치 (선택)](#6-kafka-ui-설치-선택-서버-1대)

---

## 1. 설치 파일 준비 (맥에서)

맥에서 아래 항목을 한 곳에 모아 두었다가 서버로 보냅니다. **서버 OS는 Rocky Linux 9.x, 아키텍처는 x86_64**라고 가정합니다.

### 1.1 폴더 구조 예시

설치 파일을 넣을 폴더를 하나 만듭니다. 예: `~/kafka-offline/`

```
kafka-offline/
├── kafka/
│   └── kafka_2.13-4.2.0.tgz
├── java21/
│   └── (여기에 *.rpm 파일들)
├── kafka-ui/
│   └── kafka-ui.jar          ← Kafka UI 실행용 JAR (이름 통일해 두면 서버에서 편함)
└── server.properties.template
```

### 1.2 Kafka 바이너리 (맥에서 다운로드)

맥 터미널에서:

```bash
mkdir -p ~/kafka-offline/kafka
cd ~/kafka-offline/kafka
curl -L -o kafka_2.13-4.2.0.tgz "https://downloads.apache.org/kafka/4.2.0/kafka_2.13-4.2.0.tgz"
# 또는 브라우저에서 https://kafka.apache.org/downloads 에서 4.2.0 Scala 2.13 tgz 받아서 이 폴더에 저장
```

- 버전이 바뀌면 URL의 `4.2.0` 과 파일명을 해당 버전으로 바꾸면 됩니다.

### 1.3 Java 21 RPM (Rocky Linux 9용)

RPM은 **Rocky Linux 9 x86_64** 용이어야 합니다. 맥에서는 **Docker로 Rocky 9 컨테이너를 띄우고** 그 안에서 `dnf download` 로 받은 뒤, 맥 폴더로 복사하는 방식이 편합니다.

**맥에서 Docker 사용 가능한 경우:**

```bash
# Rocky 9 컨테이너 실행 후 의존성 포함 Java 21 다운로드
mkdir -p ~/kafka-offline/java21
# 대상 서버가 x86_64 이면 --platform linux/amd64 필수 (Apple Silicon 맥은 기본이 aarch64 RPM)
docker run --rm --platform linux/amd64 -v "$HOME/kafka-offline/java21:/out" rockylinux:9 bash -c '
  dnf install -y dnf-plugins-core
  dnf install -y --downloadonly --downloaddir=/out java-21-openjdk-devel
'
```

- 실행 후 `~/kafka-offline/java21/` 에 `*.rpm` 파일이 생깁니다. 이 폴더 통째로 서버로 보내면 됩니다.
- **설치할 서버가 x86_64** 이면 반드시 `--platform linux/amd64` 를 넣어서 x86_64용 RPM을 받으세요. (Apple Silicon 맥에서는 이 옵션 없이 받으면 aarch64 RPM이 받아져서 x86_64 서버에서 설치할 수 없습니다.)

**Docker가 없는 경우:**  
인터넷이 되는 **Rocky Linux 9 서버(또는 VM)** 한 대에서 아래를 실행한 뒤, 생성된 `java21` 폴더를 맥으로 가져오거나, 그 서버에서 곧바로 설치할 3대 서버로 전달합니다.

```bash
mkdir -p /tmp/kafka-offline/java21
cd /tmp/kafka-offline/java21
sudo dnf install --downloadonly --downloaddir=. java-21-openjdk-devel
# 생성된 *.rpm 을 맥으로 SCP 하거나, 설치할 서버로 복사
```

### 1.4 server.properties 템플릿

이 프로젝트의 `docs/server.properties.template` 파일을 `~/kafka-offline/` 로 복사합니다.

```bash
# 프로젝트 루트( KLID_2026 )에서 실행 시
cp docs/server.properties.template ~/kafka-offline/
```

(또는 Finder에서 `server.properties.template` 을 `kafka-offline` 폴더로 복사해 넣어도 됩니다.)

### 1.5 Kafka UI JAR (맥에서 다운로드)

Kafka UI는 JAR 한 개만 있으면 됩니다. **Kafka UI를 띄울 서버 1대**에서만 사용합니다.

**방법 A: 브라우저에서 받기**

1. [provectus/kafka-ui Releases](https://github.com/provectus/kafka-ui/releases) 접속.
2. 최신 릴리스의 **Assets** 에서 실행 가능한 JAR 파일 다운로드 (예: `kafka-ui-api.jar`, `kafka-ui-*-exec.jar` 등).
3. 맥에서 폴더 만들고 저장:

```bash
mkdir -p ~/kafka-offline/kafka-ui
# 다운로드한 JAR를 이 폴더로 옮기고, 서버에서 쓰기 쉽게 kafka-ui.jar 로 이름 통일 (선택)
mv ~/Downloads/kafka-ui-*.jar ~/kafka-offline/kafka-ui/kafka-ui.jar
```

**방법 B: 맥 터미널에서 curl로 받기**

릴리스 페이지에서 JAR URL을 확인한 뒤 아래처럼 받습니다. (버전은 [Releases](https://github.com/provectus/kafka-ui/releases) 에서 최신으로 바꾸세요.)

```bash
mkdir -p ~/kafka-offline/kafka-ui
cd ~/kafka-offline/kafka-ui
# 버전은 Releases 페이지에서 확인 후 URL 수정
curl -L -o kafka-ui.jar "https://github.com/provectus/kafka-ui/releases/download/v0.7.2/kafka-ui-api-v0.7.2-exec.jar"
```

- JAR를 `kafka-ui.jar` 로 두면 서버에서 6단계 안내와 동일한 경로로 쓸 수 있습니다.

### 1.6 압축 (맥에서)

폴더 그대로 보내지 말고 **압축 파일 하나**로 만들어 전송합니다.

```bash
cd ~
tar -czvf kafka-offline.tar.gz kafka-offline
```

- 생성된 `~/kafka-offline.tar.gz` 를 서버로 보냅니다.
- 압축 해제 시 `kafka-offline/` 폴더가 생기도록, **kafka-offline 폴더의 상위 디렉터리**에서 `tar` 실행합니다. (예: `~/` 에서 하면 압축 안에 `kafka-offline/` 이 들어감.)

---

## 2. 서버로 전송

준비한 **압축 파일** `kafka-offline.tar.gz` 를 3대 서버 모두에 보냅니다. **한 대에만 보낸 뒤** 그 서버에서 나머지 2대로 `scp` 해도 됩니다.

**맥 터미널에서 (3대 IP를 각각 넣어 실행):**

```bash
# 예: 브로커1, 브로커2, 브로커3 IP
BROKER1=10.0.0.45
BROKER2=10.0.0.46
BROKER3=10.0.0.47

for H in $BROKER1 $BROKER2 $BROKER3; do
  scp ~/kafka-offline.tar.gz 사용자명@$H:~/
done
```

- `사용자명` 은 각 서버의 SSH 로그인 계정으로 바꾸세요.
- 서버 한 대에만 올린 뒤, 그 서버에서 `scp ~/kafka-offline.tar.gz 사용자명@다른서버:~` 로 나머지로 복사해도 됩니다.

---

## 3. 기존 Kafka 설치 제거 (서버, 있을 경우)

**이미 Kafka가 설치·기동 중인 서버**에서만 아래를 수행합니다. 처음 설치하는 서버면 이 단계는 건너뜁니다.

**3대 모두에서 순서대로 실행:**

```bash
# 1) 서비스 중지 및 비활성화
sudo systemctl stop kafka
sudo systemctl disable kafka

# 2) systemd 유닛 파일 삭제
sudo rm -f /etc/systemd/system/kafka.service
sudo systemctl daemon-reload

# 3) Kafka 바이너리·설정 삭제
sudo rm -rf /opt/kafka/*

# 4) 로그·메타데이터 삭제 (포맷 정보 등 모두 삭제됨)
sudo rm -rf /data/kafka/logs/*
sudo rm -rf /data/kafka/metadata/*

# 5) (선택) kafka 사용자까지 제거하고 완전 초기화하려면
# sudo userdel kafka
# 사용자를 지우면 4단계에서 다시 useradd 해야 함

# 6) Java 21 제거 (다시 오프라인 RPM으로 설치할 때만)
sudo dnf remove -y java-21-openjdk-devel java-21-openjdk java-21-openjdk-headless
# 제거 후 확인
java -version   # 없으면 "command not found" 등
```

- `/opt/kafka` 디렉터리 자체를 지우려면: `sudo rm -rf /opt/kafka`  
- `/data/kafka` 는 디렉터리만 남기고 내용만 비우는 방식으로 두었습니다. 디렉터리까지 제거하려면 `sudo rm -rf /data/kafka` 후 4단계에서 다시 `mkdir -p /data/kafka/logs /data/kafka/metadata` 하면 됩니다.
- **Java 제거**: 위 6)은 **Java도 지우고 오프라인으로 다시 깔 때**만 실행하세요. `dnf remove` 시 의존성으로 설치된 패키지까지 같이 제거될 수 있습니다. 다른 버전 Java가 있으면 해당 패키지명만 제거해도 됩니다. (예: `dnf list installed | grep java` 로 확인 후 제거.)

---

## 4. 서버에서 오프라인 설치

전송된 `~/kafka-offline.tar.gz` 를 각 서버에서 압축 해제한 뒤 설치를 진행합니다. **3대 공통**으로 할 작업과 **노드별**로 할 작업이 있습니다.

### 4.0 압축 해제 (3대 공통)

```bash
cd ~
tar -xzvf kafka-offline.tar.gz
```

- `~/kafka-offline/` 폴더가 생깁니다. 이후 경로는 모두 `~/kafka-offline/` 기준입니다.

### 4.1 Java 21 설치 (3대 공통)

```bash
cd ~/kafka-offline/java21
sudo dnf install --disablerepo='*' ./*.rpm -y
java -version
```

- `java -version` 에서 21이 나오면 됩니다.
- 오프라인 환경에서 외부 repo 조회로 오류가 나면 `--disablerepo='*'` 옵션이 필요합니다. GPG 오류까지 발생하면 `--nogpgcheck`도 추가하세요.

### 4.2 Kafka 사용자 및 디렉터리 (3대 공통)

(3단계에서 `userdel kafka` 했으면 다시 생성합니다.)

```bash
sudo useradd -r -s /bin/false kafka
sudo mkdir -p /opt/kafka /data/kafka/logs /data/kafka/metadata
sudo chown -R kafka:kafka /opt/kafka /data/kafka
```

### 4.3 Kafka 바이너리 배치 (3대 공통)

```bash
cd ~/kafka-offline/kafka
sudo tar -xzf kafka_2.13-4.2.0.tgz -C /opt/kafka --strip-components=1
sudo chown -R kafka:kafka /opt/kafka
```

### 4.4 server.properties 배치 (노드별)

브로커별 전용 템플릿(`server.properties.broker1~3.template`)을 사용합니다. `node.id`와 `advertised.listeners` 포트가 미리 설정되어 있으므로 **치환자 3개**만 수정하면 됩니다.

| 치환자 | 설명 |
|--------|------|
| `<BROKER1_IP>` ~ `<BROKER3_IP>` | 각 브로커 서버 IP (3대 동일하게) |
| `<HAPROXY_IP>` | 이 센터 HAProxy IP |

**브로커1에서 예시 (IP: 10.0.0.45, HAProxy IP: 172.30.2.54):**

```bash
cp server.properties.broker1.template /opt/kafka/config/server.properties
sudo chown kafka:kafka /opt/kafka/config/server.properties

sudo sed -i 's/<BROKER1_IP>/10.0.0.45/g' /opt/kafka/config/server.properties
sudo sed -i 's/<BROKER2_IP>/10.0.0.46/g' /opt/kafka/config/server.properties
sudo sed -i 's/<BROKER3_IP>/10.0.0.47/g' /opt/kafka/config/server.properties
sudo sed -i 's/<HAPROXY_IP>/172.30.2.54/g' /opt/kafka/config/server.properties
```

**브로커2:** `server.properties.broker2.template` 사용, 동일한 IP 치환.  
**브로커3:** `server.properties.broker3.template` 사용, 동일한 IP 치환.

> HAProxy 포트 매핑: 브로커1=19092, 브로커2=19093, 브로커3=19094 → 각 브로커 9094  
> HAProxy 설정은 아래 **HAProxy 리스너 설정** 섹션 참고.

### 4.5 클러스터 UUID 생성 (1회, 브로커1에서만)

```bash
/opt/kafka/bin/kafka-storage.sh random-uuid
```

- 출력된 **UUID를 메모**합니다. 다음 4.6에서 사용합니다.

### 4.6 스토리지 포맷 (3대 모두)

**기존 메타데이터가 있으면 먼저 정리** (재구축 시에만, 신규 설치면 스킵):

```bash
sudo rm -rf /data/kafka/logs/meta.properties /data/kafka/metadata/*
```

**위에서 받은 UUID**로 `YOUR_UUID` 를 바꾼 뒤, **3대 각각**에서 실행합니다.

```bash
sudo -u kafka /opt/kafka/bin/kafka-storage.sh format --cluster-id YOUR_UUID --config /opt/kafka/config/server.properties --ignore-formatted
```

### 4.7 Systemd 서비스 등록 (3대 모두, 먼저 실행)

**systemd 서비스 파일 등록:**

```bash
sudo cp ~/kafka-offline/kafka.service /etc/systemd/system/kafka.service
sudo systemctl daemon-reload
sudo systemctl enable kafka
```

> JVM 힙 기본값은 1g (개발/테스트 수준). 현장 운영 시 `kafka.service` 파일에서 수정.  
> 주센터 (RAM 16GB): `-Xms6g -Xmx6g` / DR센터 (RAM 8GB): `-Xms4g -Xmx4g`

### 4.8 기동 및 브로커 확인 (3대 모두)

**3대 모두 기동:**

```bash
sudo systemctl start kafka
sudo systemctl status kafka
```

- 모든 서버에서 `active (running)` 상태여야 합니다.

**한 대에서만 브로커 목록 확인 (IP를 실제 값으로 바꿈):**

```bash
/opt/kafka/bin/kafka-broker-api-versions.sh -bootstrap-server 10.0.0.45:9092,10.0.0.46:9092,10.0.0.47:9092
```

- 아래처럼 3개 브로커(id 1, 2, 3)가 모두 보이면 정상입니다:
  ```
  ApiVersion(api_key: 0, min_version: 0, max_version: 13)
  ...
  ```

### 4.9 PATH 환경변수 설정 (3대 모두)

Kafka 명령어를 경로 없이 사용하기 위해 3대 모두 설정한다.

```bash
echo 'export PATH=$PATH:/opt/kafka/bin' >> ~/.bashrc
source ~/.bashrc
```

적용 확인:

```bash
kafka-topics.sh --version
```

---

## ⚠️ 3중화 구성 시 주의사항

### 동일한 Cluster ID 사용 필수

- 모든 3대 서버에서 **동일한 UUID**를 사용해 포맷해야 합니다.
- 각 서버마다 새로 UUID를 생성하면 **클러스터가 형성되지 않습니다.**
- 4.5에서 생성한 UUID를 **메모했다가 4.6에서 3대 모두 동일하게 적용**하세요.

### server.properties 설정 확인

- **브로커별 전용 파일 사용**: `server.properties.broker1~3.template` (`node.id`, EXTERNAL 포트 미리 설정됨)
- **치환자 4개**: `BROKER1_IP~3_IP`, `HAPROXY_IP` — 3대 모두 동일한 값으로 치환
- **controller.quorum.voters 포트**: 반드시 **9093** (CONTROLLER 리스너)
- **로그 보존 기간**: `log.retention.hours=240` (10일) — 감리 지적 반영 필수 값, 변경 금지

### 메타데이터 확인

포맷 후 각 서버에서 메타데이터가 제대로 생성되었는지 확인:

```bash
cat /data/kafka/logs/meta.properties
```

출력 예:
```
version=1
node.id=1    # 이 서버의 node.id와 일치해야 함
cluster.id=YOUR_CLUSTER_ID
```

### 기존 설치 재구축 시

- 4.6의 `rm -rf /data/kafka/logs/meta.properties /data/kafka/metadata/*` 반드시 실행
- 이전 UUID로 포맷된 메타데이터가 남아있으면 클러스터 형성 실패

---

## HAProxy 리스너 설정

Kafka EXTERNAL 리스너는 HAProxy를 경유합니다. 외부 클라이언트(Logstash)는 HAProxy에 접속하고, HAProxy가 각 브로커의 9094 포트로 포워딩합니다.

```
외부 클라이언트(Logstash)
    ↓
HAProxy :19092  →  브로커1 :9094
HAProxy :19093  →  브로커2 :9094
HAProxy :19094  →  브로커3 :9094
```

**HAProxy 설정 예시 (`/etc/haproxy/haproxy.cfg` 추가):**

```
listen kafka-broker1
  bind *:19092
  mode tcp
  balance source
  server broker1 <BROKER1_IP>:9094 check inter 10s

listen kafka-broker2
  bind *:19093
  mode tcp
  balance source
  server broker2 <BROKER2_IP>:9094 check inter 10s

listen kafka-broker3
  bind *:19094
  mode tcp
  balance source
  server broker3 <BROKER3_IP>:9094 check inter 10s

listen kafka-ui-http
  bind *:<KAFKA_UI_PORT>
  mode http
  option httplog
  option forwardfor
  server kafka-ui <BROKER2_IP>:<KAFKA_UI_PORT> check
```

> Kafka UI는 브로커2에서 실행합니다. `<KAFKA_UI_PORT>`는 현장 방화벽 정책에 맞게 지정하세요.

적용:
```bash
sudo haproxy -c -f /etc/haproxy/haproxy.cfg   # 설정 검증
sudo systemctl restart haproxy
```

> `advertised.listeners`의 EXTERNAL 포트(19092~19094)는 HAProxy 프론트엔드 포트와 일치해야 합니다.  
> 브로커 `listeners`의 EXTERNAL 포트(9094)는 HAProxy 백엔드 포트와 일치해야 합니다.

---

## 5. 설치 후 확인

- 각 서버: `sudo systemctl status kafka` → `active (running)` 확인
- 한 대에서: `/opt/kafka/bin/kafka-broker-api-versions.sh -bootstrap-server 브로커1:9092,브로커2:9092,브로커3:9092` → 3개 브로커 출력 확인
- Topic 생성·테스트는 `/opt/kafka/bin/kafka-topics.sh` 명령어 사용.

---

## 6. Kafka UI 설치 (선택, 서버 1대)

Kafka UI를 쓸 **서버 한 대**(브로커 중 1대 또는 별도 VM)에서만 진행합니다. Java 21이 이미 설치된 상태여야 합니다.

### 6.1 JAR 배치 및 실행

```bash
sudo mkdir -p /opt/kafka-ui
sudo cp ~/kafka-offline/kafka-ui/kafka-ui.jar /opt/kafka-ui/
sudo chown -R kafka:kafka /opt/kafka-ui
```

- JAR 파일명이 `kafka-ui.jar` 가 아니면 위 경로를 실제 파일명에 맞게 바꾸세요.

**환경변수 넣고 실행 (브로커 IP를 실제 값으로):**

```bash
cd /opt/kafka-ui
export KAFKA_CLUSTERS_0_NAME=klid-cluster
export KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS=10.0.0.45:9092,10.0.0.46:9092,10.0.0.47:9092
java -jar kafka-ui.jar
```

- 다른 망이면 `10.0.0.45~47` 대신 해당 망의 브로커 IP(예: 172.30.1.53~55)로 바꾸세요.
- 백그라운드: `nohup java -jar kafka-ui.jar &` 또는 아래 systemd 등록.

### 6.2 systemd 서비스 등록 (권장)

```bash
# 브로커 IP 치환 후 복사
sed 's/<BROKER1_IP>/10.0.0.45/g; s/<BROKER2_IP>/10.0.0.46/g; s/<BROKER3_IP>/10.0.0.47/g' \
  ~/kafka-offline/kafka-ui.service | sudo tee /etc/systemd/system/kafka-ui.service

sudo systemctl daemon-reload
sudo systemctl enable kafka-ui
sudo systemctl start kafka-ui
```

- **접속**: `http://<HAPROXY_IP>:<KAFKA_UI_PORT>` → klid-cluster 선택 후 Brokers에 3대가 보이면 정상.

### 6.3 HAProxy 설정 (HAProxy 서버에서)

Kafka UI는 HAProxy를 통해 접근합니다. HAProxy 서버의 `/etc/haproxy/haproxy.cfg`에 아래 섹션을 추가하세요.

> HAProxy 전체 설정은 **HAProxy 리스너 설정** 섹션을 참고하세요. kafka-ui 섹션만 별도로 추가할 경우 아래를 사용합니다.

```
listen kafka-ui-http
  bind *:<KAFKA_UI_PORT>
  mode http
  option httplog
  option forwardfor
  server kafka-ui <BROKER2_IP>:<KAFKA_UI_PORT> check
```

적용:
```bash
sudo haproxy -c -f /etc/haproxy/haproxy.cfg   # 설정 검증
sudo systemctl restart haproxy
```

---

## 요약 체크리스트

- [ ] **맥**: `kafka-offline/` 에 kafka tgz, java21/*.rpm, server.properties.template, **kafka-ui/kafka-ui.jar** 준비
- [ ] **맥**: `tar -czvf kafka-offline.tar.gz kafka-offline` 로 압축
- [ ] **맥**: 3대 서버로 `kafka-offline.tar.gz` 전송 (scp)
- [ ] **서버**: 각 서버에서 `tar -xzvf kafka-offline.tar.gz` 로 압축 해제
- [ ] **서버(기존 설치 있으면)**: 서비스 중지 → 유닛 삭제 → /opt/kafka, /data/kafka 내용 삭제, (선택) Java 제거
- [ ] **서버 3대**: Java 21 RPM 설치, kafka 사용자·디렉터리, Kafka tgz 압축 해제
- [ ] **서버별**: `server.properties.broker{1,2,3}.template` 복사 후 BROKER1_IP~3_IP, HAPROXY_IP 치환
- [ ] **한 대에서**: UUID 생성 후 메모 (모든 서버에서 동일하게 사용!)
- [ ] **3대**: (기존 설치 있으면) 메타데이터 정리: `sudo rm -rf /data/kafka/logs/meta.properties /data/kafka/metadata/*`
- [ ] **3대**: 스토리지 포맷 (동일 UUID 사용) → `/data/kafka/logs/meta.properties` 파일 생성 확인
- [ ] **3대**: systemd 서비스 파일 등록 및 enable
- [ ] **3대**: systemctl start kafka로 기동 → status로 active (running) 확인
- [ ] **한 대에서**: broker-api-versions로 3대 브로커 확인
- [ ] **(선택) Kafka UI**: JAR를 띄울 서버 1대에서 `/opt/kafka-ui` 에 복사 후 실행 또는 systemd 등록 → `http://서버:8080` 접속 후 klid-cluster Brokers 3대 확인
