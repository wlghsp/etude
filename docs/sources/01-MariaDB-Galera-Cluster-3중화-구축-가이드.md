# MariaDB Galera Cluster 3중화 구축 가이드 (폐쇄망)

> 기존 `MariaDB-CDC-테스트-환경-설치-가이드.md` 기반으로 Galera Cluster를 추가 구성하는 가이드입니다.
> 단독 MariaDB가 아닌 3노드 Galera Cluster로 CDC 테스트 환경을 구성합니다.

---

## 목차

1. [환경 정보](#1-환경-정보)
2. [사전 준비 (맥에서 바이너리 준비)](#2-사전-준비-맥에서-바이너리-준비)
3. [전체 노드 공통 설치](#3-전체-노드-공통-설치)
4. [Galera 설정 (my.cnf)](#4-galera-설정-mycnf)
5. [클러스터 부트스트랩](#5-클러스터-부트스트랩)
6. [클러스터 상태 확인](#6-클러스터-상태-확인)
7. [HAProxy 설정 (DB 로드밸런싱)](#7-haproxy-설정-db-로드밸런싱)
8. [CDC 설정](#8-cdc-설정)
9. [DB 복원 및 계정 설정](#9-db-복원-및-계정-설정)
10. [장애 복구 절차](#10-장애-복구-절차)
11. [체크리스트](#11-체크리스트)

---

## 1. 환경 정보

### 노드 구성

```
┌─────────────────────────────────────────────────────┐
│              MariaDB Galera Cluster (3중화)          │
│                                                     │
│  node1: <node1_ip>  ←→  node2: <node2_ip>           │
│             ↕                   ↕                   │
│          node3: <node3_ip>                          │
│                                                     │
│  포트: 3306 (MySQL), 4567 (Galera), 4568 (IST),     │
│        4444 (SST)                                   │
└─────────────────────────────────────────────────────┘
```

### 스펙 (테스트 최소 사양)

| 항목 | 사양 |
|------|------|
| OS | Rocky Linux 9.6 (x86_64) |
| MariaDB | 10.5.29 (기존 가이드와 동일) |
| CPU | 2코어 이상 |
| RAM | 2GB 이상 |
| Disk | 20GB 이상 |
| 노드 수 | 3대 |

### IP 예시 (실제 IP로 교체)

| 노드 | IP | 역할 |
|------|----|------|
| node1 | 10.0.0.26 | 첫 번째 부트스트랩 노드 |
| node2 | 10.0.0.7 | 일반 노드 |
| node3 | 10.0.0.25 | 일반 노드 |

---

## 2. 사전 준비 (맥에서 바이너리 준비)

폐쇄망이므로 맥에서 필요한 파일을 모두 준비하여 각 서버로 전송합니다.

### 2.1 필요 파일 목록

```
~/Documents/klid/mariadb-packages/
├── mariadb-10.5.29-linux-systemd-x86_64.tar.gz
├── libssl.so.1.0.0                # Galera OpenSSL 1.0 의존성 (Ubuntu 18.04 빌드)
├── libcrypto.so.1.0.0             # Galera OpenSSL 1.0 의존성 (Ubuntu 18.04 빌드)
├── libaio-*.rpm
├── ncurses-base-*.rpm             # ncurses-compat-libs 의존성
├── ncurses-compat-libs-*.rpm
├── ncurses-libs-*.rpm
└── numactl-libs-*.rpm
# rsync는 Rocky Linux 9 기본 설치 (별도 RPM 불필요)
(galera 라이브러리는 MariaDB 10.5 바이너리에 내장)
```

> **참고:** `libgalera_smm.so`는 OpenSSL 1.0.0으로 컴파일되어 있습니다. Rocky Linux 9는 OpenSSL 3.x만 제공하므로 `OPENSSL_1.0.0` 버전 심볼을 포함한 라이브러리를 별도로 준비해야 합니다. `compat-openssl10` RPM(el8 빌드)은 해당 심볼이 없어 동작하지 않으며, Ubuntu 18.04의 `libssl1.0.0` 패키지에서 추출한 파일이 정상 동작합니다.

> **참고:** MariaDB 10.5 Linux 바이너리 tarball에는 `libgalera_smm.so`가 포함되어 있어 별도 Galera 패키지 설치 불필요합니다.

### 2.2 파일 준비 (맥에서)

```bash
mkdir -p ~/Documents/klid/mariadb-packages

# ncurses-base 다운로드
# (ncurses-base는 컨테이너에 기본 설치되어 있어 yumdownloader로 강제 다운로드)
docker run --rm --platform linux/amd64 \
  -v ~/Documents/klid/mariadb-packages:/packages \
  quay.io/centos/centos:stream9 bash -c \
  "yum install -y yum-utils && \
   yumdownloader --destdir=/packages ncurses-base"

# libssl.so.1.0.0, libcrypto.so.1.0.0 추출 (Ubuntu 18.04 빌드)
# Rocky Linux 9에서 libgalera_smm.so 로드에 필요한 OPENSSL_1.0.0 심볼 포함
docker run --rm --platform linux/amd64 \
  -v ~/Documents/klid/mariadb-packages:/packages \
  ubuntu:18.04 bash -c \
  "apt-get update && \
   apt-get install -y libssl1.0.0 && \
   cp /usr/lib/x86_64-linux-gnu/libssl.so.1.0.0 /packages/ && \
   cp /usr/lib/x86_64-linux-gnu/libcrypto.so.1.0.0 /packages/"

# 다운로드 확인
ls -lh ~/Documents/klid/mariadb-packages/
```

### 2.3 MariaDB 바이너리 안에 Galera 라이브러리 확인 (선택)

```bash
# 맥에서 tar 안에 galera 라이브러리가 있는지 확인
tar -tzf ~/Downloads/mariadb-10.5.29-linux-systemd-x86_64.tar.gz | grep galera

# 출력 예:
# mariadb-10.5.29-linux-systemd-x86_64/lib/galera/libgalera_smm.so
```

### 2.4 전체 파일 3대 서버로 전송

```bash
# 맥에서 압축
cd ~/Documents/klid
tar -czf mariadb-packages.tar.gz mariadb-packages/

# 3대 서버에 각각 전송
for node in <node1_ip> <node2_ip> <node3_ip>; do
  echo "=== Sending to $node ==="
  scp ~/Documents/klid/mariadb-packages.tar.gz user@$node:/tmp/
done
```

---

## 3. 전체 노드 공통 설치

> **3대 모두 동일하게 수행합니다.**
> 기존 `MariaDB-CDC-테스트-환경-설치-가이드.md`의 2번 설치 절차와 동일합니다.

### 3.1 의존성 설치

```bash
# 서버에서 압축 해제
cd /tmp
tar -xzf mariadb-packages.tar.gz
cd /tmp/mariadb-packages

# 의존성 RPM 설치
sudo rpm -ivh libaio-*.rpm ncurses-base-*.rpm ncurses-compat-libs-*.rpm 2>/dev/null || \
sudo rpm -ivh libaio-*.rpm ncurses-base-*.rpm ncurses-compat-libs-*.rpm --replacepkgs

# OpenSSL 1.0 라이브러리 배포 (libgalera_smm.so 의존성)
sudo cp libssl.so.1.0.0 /usr/lib64/
sudo cp libcrypto.so.1.0.0 /usr/lib64/
sudo ldconfig

# rsync는 Rocky Linux 9에 기본 설치되어 있으므로 별도 설치 불필요
rsync --version
```

### 3.2 MariaDB 설치 (기존과 동일)

```bash
# 사용자 생성
sudo useradd -r -s /bin/false -M -d /var/lib/mysql mysql 2>/dev/null || true

# 설치 디렉터리 준비
sudo mkdir -p /opt/mariadb

# 압축 해제 및 설치
cd /tmp/mariadb-packages
tar -xzf mariadb-10.5.29-linux-systemd-x86_64.tar.gz
sudo cp -r mariadb-10.5.29-linux-systemd-x86_64/* /opt/mariadb/

# 데이터 디렉터리 준비
sudo mkdir -p /var/lib/mysql /var/log/mariadb
sudo chown -R mysql:mysql /var/lib/mysql /var/log/mariadb
sudo chmod 755 /var/lib/mysql /var/log/mariadb

# Galera 소켓 디렉터리
sudo mkdir -p /var/run/mysql
sudo chown mysql:mysql /var/run/mysql
```

### 3.3 Galera 라이브러리 경로 확인

```bash
# 라이브러리 위치 확인
ls -lh /opt/mariadb/lib/galera/libgalera_smm.so

# 출력 예:
# -rwxr-xr-x 1 root root 12M ... /opt/mariadb/lib/galera/libgalera_smm.so
```

### 3.4 DB 초기화

```bash
sudo /opt/mariadb/scripts/mysql_install_db \
  --user=mysql \
  --datadir=/var/lib/mysql \
  --basedir=/opt/mariadb
```

### 3.5 PATH 설정

```bash
echo 'export PATH="/opt/mariadb/bin:$PATH"' | sudo tee /etc/profile.d/mariadb.sh
source /etc/profile.d/mariadb.sh
```

---

## 4. Galera 설정 (my.cnf)

### my.cnf 배포 (3대 모두)

```bash
sudo cp ~/mariadb-packages/my.cnf /etc/my.cnf
```

노드별로 다른 3개 항목을 수정합니다:

```bash
sudo vi /etc/my.cnf
```

| 항목 | node1 | node2 | node3 |
|------|-------|-------|-------|
| `server-id` | 1 | 2 | 3 |
| `wsrep_node_address` | 10.0.0.26 | 10.0.0.7 | 10.0.0.25 |
| `wsrep_node_name` | node1 | node2 | node3 |

> DR센터는 `auto_increment_offset = 2` 로 변경할 것.

### Systemd 서비스 파일 (3대 동일)

```bash
sudo cp ~/mariadb-packages/mariadb.service /etc/systemd/system/mariadb.service
sudo systemctl daemon-reload
```

---

## 5. 클러스터 부트스트랩

> **순서가 매우 중요합니다. 반드시 이 순서를 따르세요.**

### 5.1 node1에서 클러스터 초기화 (부트스트랩)

> `galera_new_cluster`는 내부적으로 `_WSREP_NEW_CLUSTER` 환경변수를 설정하고 `systemctl restart mariadb`를 호출합니다.
> systemd 서비스 파일의 `ExecStart`에 `$_WSREP_NEW_CLUSTER`가 포함되어 있어야 합니다.

```bash
# node1에서만 실행
sudo /opt/mariadb/bin/galera_new_cluster

# 상태 확인
sudo systemctl status mariadb
sudo /opt/mariadb/bin/mysql -u root --socket=/var/lib/mysql/mysql.sock \
  -e "SHOW STATUS LIKE 'wsrep_cluster_size';"

# 출력 예:
# +--------------------+-------+
# | Variable_name      | Value |
# +--------------------+-------+
# | wsrep_cluster_size | 1     |
# +--------------------+-------+
```

### 5.2 node2 시작

```bash
# node2에서 실행
sudo systemctl start mariadb

# 클러스터 크기 확인 (2가 되어야 함)
sudo /opt/mariadb/bin/mysql -u root --socket=/var/lib/mysql/mysql.sock \
  -e "SHOW STATUS LIKE 'wsrep_cluster_size';"
```

### 5.3 node3 시작

```bash
# node3에서 실행
sudo systemctl start mariadb

# 클러스터 크기 확인 (3이 되어야 함)
sudo /opt/mariadb/bin/mysql -u root --socket=/var/lib/mysql/mysql.sock \
  -e "SHOW STATUS LIKE 'wsrep_cluster_size';"
```

---

## 6. 클러스터 상태 확인

### 6.1 핵심 상태 변수

```sql
-- 클러스터 전체 상태 한 번에 확인
SHOW STATUS LIKE 'wsrep_%';

-- 핵심 변수만 확인
SHOW STATUS LIKE 'wsrep_cluster_size';      -- 3이어야 함
SHOW STATUS LIKE 'wsrep_cluster_status';    -- Primary 이어야 함
SHOW STATUS LIKE 'wsrep_connected';         -- ON 이어야 함
SHOW STATUS LIKE 'wsrep_ready';             -- ON 이어야 함
SHOW STATUS LIKE 'wsrep_local_state_comment'; -- Synced 이어야 함
```

### 6.2 정상 상태 예시

```
+---------------------------+---------+
| Variable_name             | Value   |
+---------------------------+---------+
| wsrep_cluster_size        | 3       |
| wsrep_cluster_status      | Primary |
| wsrep_connected           | ON      |
| wsrep_ready               | ON      |
| wsrep_local_state_comment | Synced  |
+---------------------------+---------+
```

### 6.3 동기화 확인 (데이터 복제 테스트)

```bash
# node1에서 데이터 삽입
mysql -u root --socket=/var/lib/mysql/mysql.sock -e \
  "CREATE DATABASE IF NOT EXISTS galera_test;
   USE galera_test;
   CREATE TABLE IF NOT EXISTS test (id INT PRIMARY KEY, val VARCHAR(50));
   INSERT INTO test VALUES (1, 'hello from node1');"

# node2, node3에서 데이터 확인
mysql -u root --socket=/var/lib/mysql/mysql.sock -e \
  "SELECT * FROM galera_test.test;"

# 출력 예:
# +----+------------------+
# | id | val              |
# +----+------------------+
# |  1 | hello from node1 |
# +----+------------------+
```

---

## 7. HAProxy 설정 (DB 로드밸런싱)

앱 서버는 HAProxy VIP(3306)로 접속하고, HAProxy가 node1(active)로 라우팅합니다.  
node2, node3은 backup으로 설정하여 node1 장애 시 자동 페일오버됩니다.

```
앱 서버 → HAProxy :3306 → node1 (active)
                        → node2 (backup, node1 다운 시)
                        → node3 (backup, node1/2 다운 시)
```

> **주의**: Galera는 어느 노드에서도 쓰기가 가능하지만, Debezium CDC 연결 노드를 고정해야 하므로 HAProxy도 동일하게 node1 우선으로 설정합니다.

### haproxy.cfg MariaDB 섹션

기존 `haproxy.cfg`에 아래 블록을 추가합니다:

```
#---------------------------------------------------------------------
# MariaDB Galera Cluster — node1 active, node2/3 backup
#---------------------------------------------------------------------
listen mariadb
  bind *:3306
  mode tcp
  balance source
  option tcpka
  option mysql-check user haproxy_check
  timeout connect  5s
  timeout client   1h
  timeout server   1h
  server node1 <node1_ip>:3306 check inter 5s rise 2 fall 3
  server node2 <node2_ip>:3306 check inter 5s rise 2 fall 3 backup
  server node3 <node3_ip>:3306 check inter 5s rise 2 fall 3 backup
```

### HAProxy 헬스체크 계정 생성

HAProxy의 `mysql-check`용 계정이 필요합니다. node1에서 한 번만 실행하면 3노드 모두 복제됩니다:

```sql
-- node1에서 실행
CREATE USER 'haproxy_check'@'<haproxy_ip>' IDENTIFIED BY '';
-- 또는 모든 IP 허용 (내부망 한정)
CREATE USER 'haproxy_check'@'%' IDENTIFIED BY '';
FLUSH PRIVILEGES;
```

> 비밀번호 없는 계정으로 TCP 연결 가능 여부만 체크합니다. 권한은 부여하지 않아도 됩니다.

### HAProxy 적용

```bash
sudo haproxy -c -f /etc/haproxy/haproxy.cfg   # 설정 문법 검사
sudo systemctl reload haproxy
```

### 연결 확인

```bash
# HAProxy를 통한 MariaDB 접속
mysql -h <haproxy_ip> -P 3306 -u portal -p

# 현재 활성 노드 확인
mysql -h <haproxy_ip> -P 3306 -u portal -p \
  -e "SELECT @@hostname, @@wsrep_node_name;"
```

---

## 8. CDC 설정

Galera 클러스터가 정상이면 기존 가이드의 CDC 설정을 그대로 적용합니다.

> `MariaDB-CDC-테스트-환경-설치-가이드.md` 참고
> **node1에서만 실행하면 3노드 모두 자동 동기화됩니다.**

### Galera + CDC 사용 시 주의사항

Debezium은 binlog 위치를 추적하므로 **반드시 특정 노드 1개에 고정**해서 연결해야 합니다. 중간에 연결 노드를 변경하면 이벤트 중복/누락이 발생합니다.

---

## 9. DB 복원 및 계정 설정

### 9.1 덤프 추출 (개발환경에서)

**데이터 포함 (스키마 + 데이터):**
```bash
mysqldump -u root -p \
  --databases db1 db2 db3 db4 \
  --single-transaction \
  --routines --triggers \
  > /tmp/dump_full.sql
```

**스키마만 (데이터 제외, 운영환경 초기 구성용):**
```bash
mysqldump -u root -p \
  --databases db1 db2 db3 db4 \
  --no-data \
  --routines --triggers \
  > /tmp/dump_schema.sql
```

> `--all-databases` 대신 `--databases`로 특정 DB만 지정하면 시스템 DB 충돌을 피할 수 있습니다.

### 9.2 덤프 복원 (node1에서)

```bash
# node1으로 전송
scp /tmp/dump_full.sql user@<node1_ip>:/tmp/      # 데이터 포함
scp /tmp/dump_schema.sql user@<node1_ip>:/tmp/    # 스키마만

# node1에서 복원 (node2, node3은 Galera가 자동 동기화)
mysql -u root -p --socket=/var/lib/mysql/mysql.sock < /tmp/dump_full.sql
# 또는
mysql -u root -p --socket=/var/lib/mysql/mysql.sock < /tmp/dump_schema.sql
```

#### SEQUENCE CACHE 오류 발생 시

Galera 클러스터에서 `SEQUENCE`의 `CACHE` 옵션이 지원되지 않아 아래 에러가 날 수 있습니다:

```
ERROR 1235 (42000): This version of MariaDB doesn't yet support
'CACHE without INCREMENT BY 0 in Galera cluster'
```

덤프 파일에서 `cache` → `nocache`로 변환 후 임포트:

```bash
sed -i 's/cache [0-9]*/nocache/g' dump_full.sql

# 변경 확인
grep -i 'sequence' dump_full.sql | head -5

# 다시 임포트
mysql -u root -p --socket=/var/lib/mysql/mysql.sock < /tmp/dump_full.sql
```

#### SEQUENCE CACHE 오류 발생 시

Galera 클러스터에서 `SEQUENCE`의 `CACHE` 옵션이 지원되지 않아 아래 에러가 날 수 있습니다:

```
ERROR 1235 (42000): This version of MariaDB doesn't yet support
'CACHE without INCREMENT BY 0 in Galera cluster'
```

덤프 파일에서 `cache` → `nocache`로 변환 후 임포트:

```bash
sed -i 's/cache [0-9]*/nocache/g' backup.sql

# 변경 확인
grep -i 'sequence' backup.sql | head -5

# 다시 임포트
mysql -u root -p --socket=/var/lib/mysql/mysql.sock <DB명> < backup.sql
```

### 8.2 앱 계정 생성

```sql
-- 앱용 계정 생성 (node1에서만 실행, 나머지 노드 자동 복제)
CREATE USER 'portal'@'%' IDENTIFIED BY 'Password123!@';
GRANT ALL PRIVILEGES ON *.* TO 'portal'@'%';
FLUSH PRIVILEGES;

-- 확인
SELECT user, host FROM mysql.user WHERE user='portal';
```

> **참고**: `%` 와일드카드 계정이 OpenStack 등 호스트명 자동생성 환경에서 동작하지 않을 경우 `my.cnf`의 `skip_name_resolve = 1` 설정이 필요합니다.

---

## 10. 장애 복구 절차

### 9.1 노드 1개 다운 → 재시작

```bash
# 다운된 노드에서 그냥 재시작
sudo systemctl start mariadb

# SST 또는 IST로 자동 동기화됨 (데이터 양에 따라 수분 소요 가능)
# 상태 확인
mysql -u root -S /var/lib/mysql/mysql.sock \
  -e "SHOW STATUS LIKE 'wsrep_local_state_comment';"
# Joining → Joined → Synced 순으로 변경됨
```

### 9.2 전체 클러스터 다운 → 재기동 (중요)

전체 다운 후 재기동 시 **가장 최신 seqno를 가진 노드부터 부트스트랩**해야 합니다.

```bash
# 모든 노드에서 마지막 seqno 확인
sudo cat /var/lib/mysql/grastate.dat

# 출력 예:
# # GALERA saved state
# version: 2.1
# uuid:    xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
# seqno:   145        ← 이 값이 가장 큰 노드부터 부트스트랩
# safe_to_bootstrap: 1   ← 1인 노드가 부트스트랩 대상
```

```bash
# safe_to_bootstrap: 1 인 노드에서 (또는 seqno 가장 큰 노드)
sudo sed -i 's/safe_to_bootstrap: 0/safe_to_bootstrap: 1/' /var/lib/mysql/grastate.dat

# 부트스트랩 실행
sudo /opt/mariadb/bin/galera_new_cluster

# 나머지 노드 순서대로 시작
sudo systemctl start mariadb  # node2
sudo systemctl start mariadb  # node3
```

### 9.3 전체 노드 동시 재시작 후 복구 (seqno: -1 상황)

> **발생 상황**: 설정 변경 후 3대를 동시에 `systemctl restart mariadb`한 경우.
> 모든 노드의 `grastate.dat`에 `safe_to_bootstrap: 0`, `seqno: -1`이 기록되어 클러스터가 재구성 불가 상태가 됩니다.

```bash
# 증상: 모든 노드에서 아래와 같이 나옴
sudo cat /var/lib/mysql/grastate.dat
# seqno:   -1
# safe_to_bootstrap: 0

# galera_new_cluster 실행 시 에러 메시지:
# "It may not be safe to bootstrap the cluster from this node.
#  edit the grastate.dat file manually and set safe_to_bootstrap to 1"
```

**복구 절차:**

```bash
# Step 1: 모든 노드 MariaDB 완전 중지 확인
# node1, node2, node3 각각
sudo systemctl stop mariadb
sudo systemctl status mariadb  # inactive (dead) 확인

# Step 2: node1에서 safe_to_bootstrap 강제 설정
# (3대 모두 seqno: -1이면 어느 노드든 무관, node1 권장)
sudo sed -i 's/safe_to_bootstrap: 0/safe_to_bootstrap: 1/' /var/lib/mysql/grastate.dat

# 변경 확인
sudo cat /var/lib/mysql/grastate.dat
# safe_to_bootstrap: 1  ← 이렇게 바뀌어야 함

# Step 3: node1에서 새 클러스터로 부트스트랩
sudo /opt/mariadb/bin/galera_new_cluster
# 명령이 멈춘 것처럼 보여도 정상 — 별도 터미널에서 상태 확인

# Step 4: 별도 터미널에서 node1 상태 확인
sudo systemctl status mariadb  # active (running) 이어야 함
sudo /opt/mariadb/bin/mysql -u root --socket=/var/lib/mysql/mysql.sock \
  -e "SHOW STATUS LIKE 'wsrep_cluster_size';"
# wsrep_cluster_size = 1  확인

# Step 5: node2, node3 순서대로 시작 (동시 시작 금지)
# node2에서:
sudo systemctl start mariadb
# wsrep_cluster_size = 2 확인 후 node3 시작

# node3에서:
sudo systemctl start mariadb
# wsrep_cluster_size = 3 확인
```

> ⚠️ **주의**: 설정 변경(`my.cnf`, systemd 서비스) 후 재시작은 반드시 **1노드씩 순서대로** 진행하세요.
> 동시 재시작 시 quorum을 잃어 위 복구 절차가 필요해집니다.

### 9.4 Split-brain 발생 시

2노드만 살아있고 write가 막힌 경우:

```sql
-- 강제로 Primary 컴포넌트로 승격 (데이터 확인 후 신중하게)
SET GLOBAL wsrep_provider_options='pc.bootstrap=YES';
```

---

## 11. 체크리스트

### 설치 단계

- [ ] 맥에서 MariaDB 바이너리 + 의존성 RPM 준비
- [ ] Ubuntu 18.04 Docker로 `libssl.so.1.0.0`, `libcrypto.so.1.0.0` 추출
- [ ] 3대 서버에 파일 전송
- [ ] 3대에 의존성(libaio, ncurses-compat-libs) 설치
- [ ] 3대에 `/usr/lib64/libssl.so.1.0.0`, `/usr/lib64/libcrypto.so.1.0.0` 복사
- [ ] 3대에 MariaDB 바이너리 설치 (`/opt/mariadb`)
- [ ] 3대에 DB 초기화 (`mysql_install_db`)
- [ ] `/opt/mariadb/lib/galera/libgalera_smm.so` 존재 확인

### 설정 단계

- [ ] 각 노드 `/etc/my.cnf` 작성 (node_address, server-id 각각 다르게)
- [ ] `wsrep_cluster_address`에 3개 IP 모두 포함 확인
- [ ] `wsrep_provider` 경로 `/opt/mariadb/lib/galera/libgalera_smm.so` 확인
- [ ] `innodb_autoinc_lock_mode = 2` 설정 확인
- [ ] 양방향 CDC 구성 시 `wsrep_auto_increment_control = OFF` 확인
- [ ] 양방향 CDC 구성 시 센터별 `auto_increment_offset` 다르게 설정 확인
- [ ] `binlog_format = ROW` 설정 확인
- [ ] systemd 서비스 파일 배포 (`sudo cp mariadb.service /etc/systemd/system/`)

### 부트스트랩 단계

- [ ] node1에서 `galera_new_cluster` 실행
- [ ] `wsrep_cluster_size = 1` 확인 (node1)
- [ ] node2 `systemctl start mariadb` → `wsrep_cluster_size = 2` 확인
- [ ] node3 `systemctl start mariadb` → `wsrep_cluster_size = 3` 확인
- [ ] `wsrep_cluster_status = Primary` 확인 (3노드 모두)
- [ ] `wsrep_local_state_comment = Synced` 확인 (3노드 모두)

### HAProxy 설정 단계

- [ ] `haproxy.cfg`에 `listen mariadb` 블록 추가
- [ ] `haproxy_check` 계정 생성 (node1에서)
- [ ] `haproxy -c -f /etc/haproxy/haproxy.cfg` 문법 검사 통과
- [ ] `systemctl reload haproxy`
- [ ] HAProxy IP:3306으로 MariaDB 접속 확인

### CDC 설정 단계

- [ ] `debezium` 사용자 생성 및 권한 부여 (node1에서)
- [ ] `test_cdc` DB 및 테이블 생성 (node1에서)
- [ ] node2, node3에 자동 복제 확인
- [ ] Debezium connector 연결 노드 고정 (node1 고정 권장)
- [ ] Binlog 활성화 확인 (`SHOW VARIABLES LIKE 'log_bin'`)

---

## 참고

- Galera는 **InnoDB 전용**입니다. MyISAM 테이블은 복제되지 않습니다.
- DDL(CREATE, ALTER, DROP)도 자동 복제됩니다.
- 노드 추가/제거 시 `wsrep_cluster_address`는 변경 불필요 (동적으로 멤버십 관리).
- SST 중에는 donor 노드가 일시적으로 쿼리 처리 불가 상태가 될 수 있습니다 (`rsync` 방식 한계).
