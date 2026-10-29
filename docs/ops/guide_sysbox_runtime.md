# 운영 가이드 — Sysbox 런타임 설치·적용·롤백

`docker`, `docker-persistent`, `linux-systemd` 샌드박스를 `Privileged` 없이 Sysbox 런타임으로 돌려, 학습자가 호스트 root가 되지 못하게 한다. 배경과 검증 결과는 [privileged 샌드박스 격리 명세](../specs/spec_privileged_sandbox_isolation.md)에 있다.

> **상태: 서버에는 아직 적용하지 않았다.** 로컬(Colima, Ubuntu 24.04)에서만 검증했다. 서버(Ubuntu 22.04)에서 처음 하는 설치이므로 아래 "서버 확인 항목"을 먼저 본다.

## 한눈에 보기

| 단계 | 서비스 영향 |
|------|------------|
| 1. 사전 확인 | 없음 |
| 2. Sysbox 설치 | **Docker 데몬 재시작 → 모든 컨테이너 중단** (점검 시간 필요) |
| 3. 서비스 복구 | 중단 시간 끝 |
| 4. `SANDBOX_RUNTIME` 켜기 | backend 재기동(수 초). 이후 새 세션부터 Sysbox |
| 롤백 | `SANDBOX_RUNTIME` 지우고 backend 재기동. 즉시 예전 방식(Privileged)으로 복귀 |

앱은 `SANDBOX_RUNTIME`이 **없으면 지금처럼 `Privileged`로** 동작한다. Sysbox를 설치만 하고 켜지 않아도 서비스는 그대로다. 그래서 "설치"와 "켜기"를 따로 할 수 있고, 켜기 전에 서버에서 검증 러너를 돌려볼 수 있다.

## 1. 사전 확인 (서비스 영향 없음)

```bash
uname -m                       # aarch64 이어야 한다 (arm64 deb 사용)
lsb_release -ds                # Ubuntu 22.04
uname -r                       # 커널 6.x 권장 (로컬 검증은 6.8)
stat -fc %T /sys/fs/cgroup     # cgroup2fs 이어야 한다
docker info --format '{{.CgroupDriver}} {{.LiveRestoreEnabled}}'
docker network ls              # 현재 네트워크 대역 확인용
sudo cat /etc/docker/daemon.json
docker ps --format '{{.Names}}\t{{.Status}}'
docker inspect -f '{{.Name}} {{.HostConfig.RestartPolicy.Name}}' $(docker ps -aq)
```

마지막 명령으로 컨테이너별 재시작 정책을 적어 둔다. Docker 재시작 뒤에 **`no`인 컨테이너는 직접 올려야** 한다 (로컬에서는 `etude-db`가 그랬다).

### 서버 확인 항목 (로컬과 달랐거나 달라질 수 있는 것)

- **`fuse3`:** Sysbox는 `fusermount3`를 실행한다. 없으면 컨테이너 생성이 `failed to pre-register with sysbox-fs`로 실패한다. 설치 전에 `which fusermount3`로 확인하고, 없으면 `sudo apt-get install -y fuse3`.
- **Docker 주소 대역:** 설치 프로그램이 `/etc/docker/daemon.json`에 `default-address-pools`(172.25.0.0/16, /24 단위)를 **추가**한다. 이미 쓰는 네트워크(k3d, compose)와 겹치지 않는지 `docker network ls`와 `docker network inspect`로 확인한다. 이미 `default-address-pools`가 있으면 건드리지 않는다.
- **`bip` 경고:** 설치 중 `Docker bridge-ip network ... overlaps` 경고가 나올 수 있다. 설치는 해당 설정만 건너뛰고 진행한다. 기본 브리지가 이미 쓰는 대역과 충돌하지 않는지만 확인한다.
- **커널 헤더 경고:** `linux kernel headers package was not found`는 학습자가 커널 모듈을 빌드할 때만 영향이 있다. 무시해도 된다.
- **Docker Hub 요청 한도:** 각 DinD 컨테이너는 이미지 캐시가 없는 새 데몬이라 퀘스트마다 Docker Hub에서 이미지를 받는다. 익명 요청 한도(429)에 걸리면 퀘스트가 실패한다. Sysbox와 무관하고 현재(Privileged)도 같다. 서버 IP가 같으면 모든 학습자가 한도를 공유하므로, 동시 사용이 늘기 전에 별도 대책(레지스트리 미러, 로그인 등)을 검토한다.

## 2. 설치 (점검 시간 필요)

1. 점검 공지. 학습자의 진행 중 세션은 끊긴다.
2. 패키지 받기. 버전은 [Sysbox 릴리스](https://github.com/nestybox/sysbox/releases)에서 확인한다 (로컬 검증: 0.7.1).

```bash
cd /tmp
wget https://github.com/nestybox/sysbox/releases/download/v0.7.1/sysbox-ce_0.7.1.linux_arm64.deb
sudo apt-get install -y jq fuse3 rsync
```

3. 현재 상태를 백업한다.

```bash
sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.bak.$(date +%Y%m%d)
```

4. 설치한다. **Docker 데몬이 재시작되어 컨테이너가 모두 내려간다.**

```bash
sudo apt-get install -y ./sysbox-ce_0.7.1.linux_arm64.deb
```

5. 확인한다.

```bash
systemctl is-active sysbox sysbox-mgr sysbox-fs     # 모두 active
docker info --format '{{range $k,$v := .Runtimes}}{{$k}} {{end}}'   # sysbox-runc 포함
sudo diff /etc/docker/daemon.json.bak.* /etc/docker/daemon.json     # 바뀐 내용 확인
```

## 3. 서비스 복구

`docker ps -a`로 내려간 컨테이너를 확인하고, 사전 확인에서 적어 둔 대로 올린다.

```bash
k3d cluster start etude
docker compose -f deploy/docker-compose.prod.yml --project-directory . up -d
```

이 시점의 앱은 아직 예전 방식(Privileged)이다. 서비스가 정상인지 [배포 후 점검](guide_post_deploy_checklist.md)대로 확인한다.

## 4. 켜기

먼저 켜지 않은 상태에서 서버의 Sysbox 자체를 시험한다 (서비스 영향 없음).

```bash
docker run --rm --runtime=sysbox-runc alpine sh -c 'cat /proc/self/uid_map; ls /dev | wc -l'
# 기대: "0 100000 65536" 와 한 자리~두 자리 수의 /dev 항목
docker run -d --rm --runtime=sysbox-runc --name sbx-test docker:dind && sleep 15 \
  && docker exec sbx-test docker info --format '{{.ServerVersion}}'; docker rm -f sbx-test
```

문제가 없으면 `backend/.env.prod`에 한 줄을 추가한다 (`.env*`는 커밋하지 않는다).

```
SANDBOX_RUNTIME=sysbox-runc
```

`.env.prod`만 고쳐서는 떠 있는 컨테이너에 반영되지 않는다. 반드시 다시 띄운다.

```bash
docker compose -f deploy/docker-compose.prod.yml --project-directory . up -d --build backend
```

### 켠 뒤 확인

- 화면에서 세트 5(Docker 기초)의 퀘스트 하나, 세트 10(systemd)의 퀘스트 하나를 직접 풀어 본다.
- 새 세션의 컨테이너가 Sysbox로 만들어졌는지 확인한다.

```bash
docker ps --filter label=etude=sandbox -q | xargs -r docker inspect -f '{{.Name}} runtime={{.HostConfig.Runtime}} privileged={{.HostConfig.Privileged}}'
# 기대: runtime=sysbox-runc privileged=false
```

- 가능하면 서버 또는 개발 환경에서 검증 러너로 세트 5, 8, 10, 11을 돌린다. 이때 **같은 세트를 반복해서 돌리지 않는다** (Docker Hub 요청 한도 소진).

```bash
cd backend && SANDBOX_RUNTIME=sysbox-runc npm run verify:quests -- --set 10,8,5,11
```

## 롤백

### A. 앱만 되돌리기 (즉시, 재시작 없음)

`backend/.env.prod`에서 `SANDBOX_RUNTIME` 줄을 지우고 backend를 다시 띄운다. 새 세션부터 예전 방식(Privileged)으로 돌아간다. 이미 열려 있는 세션은 Sysbox 컨테이너로 남아 있다가 종료되면 정리된다.

```bash
docker compose -f deploy/docker-compose.prod.yml --project-directory . up -d --build backend
```

### B. Sysbox 제거 (Docker 재시작 필요, 보통 불필요)

A만으로 서비스는 복구된다. 패키지까지 지워야 할 때만 한다. 점검 시간이 필요하다.

```bash
sudo apt-get remove -y sysbox-ce
sudo cp /etc/docker/daemon.json.bak.<날짜> /etc/docker/daemon.json   # 설치 전 설정 복원
sudo systemctl restart docker
```

그 뒤 서비스 복구(3단계)를 다시 한다. `default-address-pools`를 복원하면 설치 후 만든 네트워크의 대역이 바뀔 수 있으니, 복원 뒤 `docker network ls`로 확인한다.

## 문제가 생겼을 때

| 증상 | 원인 | 조치 |
|------|------|------|
| 컨테이너 생성 시 `failed to pre-register with sysbox-fs` | `fusermount3` 없음 | `sudo apt-get install -y fuse3 && sudo systemctl restart sysbox` |
| 컨테이너 생성 시 `unknown or invalid runtime name: sysbox-runc` | 데몬에 런타임 등록 안 됨 | `daemon.json`의 `runtimes` 확인, `sudo systemctl restart docker` |
| 퀘스트 setup이 `exit 125`, 안쪽 로그에 `429 Too Many Requests` | Docker Hub 익명 요청 한도 | 시간이 지나면 풀린다. 근본 대책은 위 "Docker Hub 요청 한도" |
| 다른 증상 | — | `sudo journalctl -u sysbox-fs -u sysbox-mgr --since "-30min"`. `Failed to write to /proc/sys/fs/nr_open`는 컨테이너 시작마다 찍히는 로그로 무시해도 된다 |

## 알려진 미해결 사항

- 로컬 검증 중 DinD 컨테이너가 퀘스트 도중 스스로 종료된 경우가 두 번 관찰됐다 (`409 container is not running`, 종료 코드 2). 같은 시기에 VM 메모리가 부족했고 Docker Hub 요청 한도도 겹쳐 있어 Sysbox 때문인지 구분하지 못했다. 단순 반복 부하(pull·run·stop 12회)에서는 재현되지 않았다. 서버에서 켠 직후 며칠은 위 "켠 뒤 확인"의 컨테이너 상태와 `docker events --filter event=die`를 함께 본다.
