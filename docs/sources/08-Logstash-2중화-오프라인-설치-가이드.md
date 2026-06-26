# Logstash 설치 가이드

> Rocky Linux 9 / RHEL 9, 오프라인 환경, 노드 2대 (2중화)

---

## 동작 흐름

```
Kafka (openshift-metric-container / node / vm)
        ↓
   [Logstash input]  Kafka consumer
        ↓
   [filter]  grok, ruby, fingerprint
        ↓
   [output]  Elasticsearch HTTPS upsert
```

---

## 목차

1. [패키지 구조 확인](#1-패키지-구조-확인)
2. [서버 사전 준비](#2-서버-사전-준비)
3. [Java 11 설치](#3-java-11-설치)
4. [Logstash 설치](#4-logstash-설치)
5. [설정 파일 배포](#5-설정-파일-배포)
6. [systemd 서비스 등록](#6-systemd-서비스-등록)
7. [설정 검증 및 서비스 시작](#7-설정-검증-및-서비스-시작)
8. [로그 확인](#8-로그-확인)
9. [2중화 구성 요약](#9-2중화-구성-요약)
10. [설치 체크리스트](#10-설치-체크리스트)

---

## 1. 패키지 구조 확인

`logstash-packages.tar.gz` 압축을 풀면 아래 구조여야 합니다.

```
logstash-packages/
├── java-11-openjdk.tar.gz          # Java 11 RPM 오프라인 패키지 묶음
├── logstash-7.9.3.tar.gz           # Logstash 바이너리
├── mariadb-java-client-3.5.3.jar   # MariaDB JDBC 드라이버
├── mysql-connector-java-5.1.44.jar # MySQL JDBC 드라이버
├── klidcmp-ca.crt                  # ES 연결용 CA 인증서
├── logstash.yml                    # 메인 설정
├── pipelines.yml                   # 파이프라인 정의
├── jvm.options                     # JVM 힙 설정
├── log4j2.xml                      # 로그 설정
├── startup.options                 # (참고용)
├── etc/systemd/system/
│   └── logstash.service            # systemd 서비스 파일
└── conf.d/
    ├── 10-input-filter.conf        # Kafka input + filter
    └── 20-output-main.conf         # ES output
```

---

## 2. 서버 사전 준비

> 두 노드 모두 동일하게 수행합니다.

```bash
# 패키지 압축 해제
tar -xzf logstash-packages.tar.gz
cd logstash-packages
```

### 디렉터리 생성

```bash
mkdir -p /etc/logstash/conf.d
mkdir -p /applog/logstash
mkdir -p /appdata/logstash
mkdir -p /usr/share/logstash/vendor/jar/jdbc
```

### logstash 계정 생성

```bash
# 이미 있으면 생략
useradd --system --no-create-home --shell /bin/false logstash
```

---

## 3. Java 11 설치

> 핵심 절차만 요약합니다.

### 3.1 RPM 패키지 압축 해제

```bash
mkdir -p /tmp/java11-offline
tar -xzf java-11-openjdk.tar.gz -C /tmp/java11-offline
```

### 3.2 RPM 설치

```bash
cd /tmp/java11-offline
dnf localinstall *.rpm -y

# GPG 오류 발생 시
# dnf localinstall *.rpm -y --nogpgcheck
```

### 3.3 설치 확인

```bash
java -version
# openjdk version "11.0.25" ...
```

### 3.4 환경변수 설정

```bash
cat > /etc/profile.d/java.sh << 'EOF'
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.25.0.9-7.el9.x86_64
export PATH=${JAVA_HOME}/bin:${PATH}
EOF
chmod 644 /etc/profile.d/java.sh
source /etc/profile.d/java.sh
```

> `JAVA_HOME` 경로는 `logstash.service`의 `JAVA_HOME`과 반드시 일치해야 합니다.

---

## 4. Logstash 설치

### 4.1 압축 해제 및 배치

```bash
# /usr/share 에 압축 해제
tar -zxvf logstash-7.9.3.tar.gz -C /usr/share/
mv /usr/share/logstash-7.9.3 /usr/share/logstash
```

### 4.2 JDBC 드라이버 배치

```bash
cp mariadb-java-client-3.5.3.jar  /usr/share/logstash/vendor/jar/jdbc/
cp mysql-connector-java-5.1.44.jar /usr/share/logstash/vendor/jar/jdbc/
```

### 4.3 기본 설정 파일 복사

```bash
cp -r /usr/share/logstash/config/* /etc/logstash/
```

### 4.4 권한 설정

```bash
chown -R logstash:logstash /usr/share/logstash
chown -R logstash:logstash /etc/logstash
chown -R logstash:logstash /applog/logstash
chown -R logstash:logstash /appdata/logstash
```

---

## 5. 설정 파일 배포

### 5.1 메인 설정: `/etc/logstash/logstash.yml`

```bash
cp logstash.yml /etc/logstash/logstash.yml
chown logstash:logstash /etc/logstash/logstash.yml
```

주요 내용:

```yaml
node.name: logstash-node-1     # ← 노드 2는 logstash-node-2 로 변경
path.data:  /appdata/logstash
path.logs:  /applog/logstash
path.queue: /appdata/logstash/queue
http.host: 0.0.0.0
http.port: 9600
log.level: info
```

> **노드마다 `node.name`만 다르게 설정합니다.** 나머지는 동일하게 유지합니다.

### 5.2 파이프라인: `/etc/logstash/pipelines.yml`

```bash
cp pipelines.yml /etc/logstash/pipelines.yml
chown logstash:logstash /etc/logstash/pipelines.yml
```

파이프라인 구성:

| pipeline.id | 설정 파일 | 역할 |
|---|---|---|
| `input-process` | `conf.d/10-input-filter.conf` | Kafka 수신 + 필터 처리 |
| `output-main` | `conf.d/20-output-main.conf` | ES upsert 출력 |
| `cdc` | `conf_cdc/*.conf` | CDC 파이프라인 (별도 배포) |

### 5.3 파이프라인 설정 파일 배포

```bash
cp conf.d/10-input-filter.conf /etc/logstash/conf.d/
cp conf.d/20-output-main.conf  /etc/logstash/conf.d/
chown -R logstash:logstash /etc/logstash/conf.d/
```

> CDC 파이프라인(`conf_cdc/`)은 Kafka Connect + Debezium 설치 가이드 참고.

### 5.4 JVM 힙: `/etc/logstash/jvm.options`

```bash
cp jvm.options /etc/logstash/jvm.options
chown logstash:logstash /etc/logstash/jvm.options
```

운영 환경 힙 설정 (`-Xms`와 `-Xmx`는 반드시 동일하게):

```
# 운영 환경 (RAM 24GB 기준)
-Xms4g
-Xmx4g
```

GC 옵션 확인 (이미 포함되어 있어야 함):

```
-XX:+UseG1GC
-XX:MaxGCPauseMillis=20
-XX:+ExplicitGCInvokesConcurrent
```

### 5.5 로그 설정: `/etc/logstash/log4j2.xml`

```bash
cp log4j2.xml /etc/logstash/log4j2.xml

# 기존 properties 파일 백업
mv /etc/logstash/log4j2.properties /etc/logstash/log4j2.properties.bak

chown logstash:logstash /etc/logstash/log4j2.xml
chmod 644 /etc/logstash/log4j2.xml
```

### 5.6 CA 인증서 배포

```bash
cp klidcmp-ca.crt /etc/logstash/klidcmp-ca.crt
chown logstash:logstash /etc/logstash/klidcmp-ca.crt
```

---

## 6. systemd 서비스 등록

```bash
cp etc/systemd/system/logstash.service /etc/systemd/system/logstash.service
```

서비스 파일 주요 내용:

```ini
[Service]
User=logstash
Group=logstash
Environment="JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.25.0.9-7.el9.x86_64"
Environment="PATH=/usr/lib/jvm/java-11-openjdk-11.0.25.0.9-7.el9.x86_64/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"
Environment="LS_JAVA_OPTS=-Dlog4j.configurationFile=/etc/logstash/log4j2.xml"
ExecStart=/usr/share/logstash/bin/logstash "--path.settings" "/etc/logstash"
Restart=always
LimitNOFILE=65535
```

> `LS_JAVA_OPTS`의 `log4j.configurationFile` 설정이 없으면 log4j2.xml을 찾지 못하고 journalctl로 fallback됩니다.

```bash
systemctl daemon-reload
systemctl enable logstash
```

---

## 7. 설정 검증 및 서비스 시작

### 7.1 설정 문법 검증 (기동 전 필수)

```bash
sudo -u logstash /usr/share/logstash/bin/logstash -t --path.settings /etc/logstash
```

- `Configuration OK` 가 나와야 정상
- CDC conf_cdc/ 파이프라인이 아직 없으면 cdc 파이프라인 오류 발생 — CDC 설정 배포 후 재검증

### 7.2 서비스 시작

```bash
systemctl start logstash
systemctl status logstash
```

### 7.3 API 응답 확인

```bash
# 9600 포트 응답 확인 (기동 후 10~30초 소요)
curl -s http://localhost:9600/
curl -s http://localhost:9600/_node/pipelines | python3 -m json.tool
```

---

## 8. 로그 확인

```bash
# 전체 로그 동시 확인
tail -f /applog/logstash/logstash-plain.log \
        /applog/logstash/logstash-main.log \
        /applog/logstash/logstash-cdc.log

# systemd 로그
journalctl -u logstash -f
```

### 주요 에러 패턴

| 로그 메시지 | 원인 | 조치 |
|---|---|---|
| `Could not find log4j2 configuration` | log4j2.xml 미배포 또는 LS_JAVA_OPTS 누락 | Step 5.5 재확인 |
| `JAVA_HOME not set` | 환경변수 미설정 | logstash.service JAVA_HOME 확인 |
| `Connection refused` (Kafka) | Kafka 브로커 미기동 또는 bootstrap_servers 오타 | conf.d 설정 확인 |
| `SSL handshake failed` (ES) | CA 인증서 경로 오류 | klidcmp-ca.crt 경로 확인 |

---

## 9. 2중화 구성 요약

| 구분 | 노드 1 | 노드 2 |
|---|---|---|
| `node.name` | `logstash-node-1` | `logstash-node-2` |
| `pipelines.yml` | 동일 | 동일 |
| `conf.d/` | 동일 | 동일 |
| `jvm.options` | 동일 | 동일 |

- 두 노드가 **동일한 Kafka 토픽을 같은 consumer group으로 구독** → Kafka가 파티션을 나눠 분배
- 한 노드 장애 시 나머지 노드가 전체 파티션을 인계받아 계속 처리
- `queue.type: persisted` 설정으로 재시작 시 큐 데이터 유지

---

## 10. 설치 체크리스트

> 두 노드 모두 수행 후 체크

- [ ] `logstash-packages.tar.gz` 서버 전송 및 압축 해제
- [ ] Java 11 RPM 설치 → `java -version` 확인
- [ ] `/etc/profile.d/java.sh` JAVA_HOME 설정
- [ ] Logstash 압축 해제 → `/usr/share/logstash`
- [ ] JDBC 드라이버 배치 → `/usr/share/logstash/vendor/jar/jdbc/`
- [ ] `logstash.yml` 배포 → 노드별 `node.name` 수정
- [ ] `pipelines.yml` 배포
- [ ] `conf.d/` 설정 파일 배포
- [ ] `jvm.options` 힙 설정 확인 (`-Xms`, `-Xmx` 동일)
- [ ] `log4j2.xml` 배포 및 `log4j2.properties` 백업
- [ ] `klidcmp-ca.crt` 배포
- [ ] `logstash.service` 배포 → `systemctl daemon-reload && systemctl enable logstash`
- [ ] `logstash -t` 설정 검증 → `Configuration OK` 확인
- [ ] `systemctl start logstash` → 로그 확인

---

## 부록 — 주요 파일 경로 요약

| 파일 | 경로 |
|---|---|
| 바이너리 | `/usr/share/logstash/bin/logstash` |
| 메인 설정 | `/etc/logstash/logstash.yml` |
| 파이프라인 정의 | `/etc/logstash/pipelines.yml` |
| 파이프라인 설정 | `/etc/logstash/conf.d/` |
| CDC 파이프라인 | `/etc/logstash/conf_cdc/` |
| JVM 힙 | `/etc/logstash/jvm.options` |
| 로그 설정 | `/etc/logstash/log4j2.xml` |
| CA 인증서 | `/etc/logstash/klidcmp-ca.crt` |
| JDBC 드라이버 | `/usr/share/logstash/vendor/jar/jdbc/` |
| 데이터 디렉터리 | `/appdata/logstash` |
| 로그 디렉터리 | `/applog/logstash` |
| systemd 서비스 | `/etc/systemd/system/logstash.service` |
