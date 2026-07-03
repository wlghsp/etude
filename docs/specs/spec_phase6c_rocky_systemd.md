# Phase 6c 명세 — Rocky Linux systemd sandbox 타입 추가

## 목표

세트 10("리눅스 현장 운영")의 systemd 실습(1, 2번)을 `service` 명령 대체가 아니라 **실제 `systemctl`이 동작하는 환경**에서 실습할 수 있게 한다. 새 sandbox 타입 `linux-systemd`(Rocky Linux 기반)를 추가하고, 세트 10을 이 타입으로 전환한다.

배경: `linux` 타입(일반 `ubuntu` 컨테이너)은 systemd가 PID 1로 뜨지 않아 `systemctl`이 항상 "System has not been booted with systemd" 에러로 실패함을 실측 확인. `apt-get install systemd`를 해도 해결 안 됨 — 근본적으로 컨테이너 실행 방식(privileged, cgroup 마운트, init을 PID 1로) 자체를 바꿔야 함. 1차로 `service` 명령으로 대체했으나(`1d62b3d`), 실무에서 `systemctl`이 더 표준적인 도구라는 지적에 따라 실제 systemd 환경을 제공하는 방향으로 전환.

---

## 검증 완료 사항 (로컬 실측)

`rockylinux/rockylinux:9-ubi-init` 이미지 + 아래 옵션으로 실제 systemd 부팅과 `systemctl` 전체 동작(status/start/enable/is-active)을 확인했다.

```bash
docker run -d --privileged --cgroupns=host \
  -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
  rockylinux/rockylinux:9-ubi-init /usr/sbin/init
```

`ss` 명령은 기본 미설치(`iproute` 패키지 설치 필요) — 세트 10의 6번 퀘스트(`ss -tlnp`)에서 `setup_cmd`로 설치 필요.

---

## 범위

**포함**: 세트 10("리눅스 현장 운영") 하나만 새 sandbox 타입으로 전환. 12개 퀘스트 전체를 Rocky Linux 기준으로 재검증(패키지 매니저 `dnf`, 기본 도구 설치 여부 등).

**제외 (범위 밖)**:
- `linux`(기본) 타입 자체를 Rocky Linux로 바꾸는 것 — 다른 리눅스 세트(1~4, 7, 9번)까지 전면 재검증이 필요한 큰 작업이라 별도로 검토. 이 Phase는 세트 10 하나로 한정.
- Rocky Linux 기반 신규 콘텐츠 확장 — 우선 기존 세트 10의 정상화만.

---

## 새 sandbox 타입 — `linux-systemd`

| 항목 | 값 |
|---|---|
| type | `linux-systemd` |
| image | `rockylinux/rockylinux:9-ubi-init` |
| 컨테이너 실행 옵션 | `Privileged: true`, cgroup 마운트, Cmd 없이 이미지 기본 entrypoint(`/usr/sbin/init`) 사용 |
| 접속 방식 | `docker`(DinD) 타입과 동일하게 컨테이너 시작 → 부팅 대기 → `exec`로 셸 연결 |

### 백엔드 변경 포인트

`docker`(DinD) sandbox 처리 로직([terminal.ts](../../backend/src/services/terminal.ts)의 `handleDefaultTerminal` 중 `Privileged` 분기, `waitForDocker` 패턴)과 매우 유사한 새 분기가 필요하다 — 다만 "부팅 완료"를 기다리는 조건이 다르다(`/var/run/docker.sock` 대신 systemd가 준비됐는지 확인해야 함, 예: `systemctl is-system-running` 폴링).

| 파일 | 변경 내용 |
|------|-----------|
| `backend/db/01_sandbox.sql` | `linux-systemd` 타입 추가 |
| `backend/src/services/terminal.ts` | 새 분기(`handleSystemdTerminal` 등) — privileged + cgroup 마운트 + 부팅 대기 후 exec 연결 |
| `backend/db/03_quest_set10.sql` | `sandbox_type`을 `linux-systemd`로 변경(quest_set 테이블), 1·2번 문제를 `systemctl` 기반으로 원복, 나머지 문제들도 Rocky 기준 setup_cmd 재검증 |

---

## 세트 10 콘텐츠 재검토 필요 항목

| 순서 | 내용 | Rocky 전환 시 확인할 것 |
|---|---|---|
| 1 | 서비스 상태 확인 (`systemctl status cron`) | 패키지명이 Ubuntu는 `cron`, Rocky/RHEL 계열은 `cronie` — 서비스명도 `cron` → `crond`로 다름 |
| 2 | 서비스 시작 + enable | 위와 동일, `systemctl start/enable crond` |
| 3 | `/etc/profile.d` 환경변수 | 배포판 무관, 그대로 유지 가능 |
| 4 | 시스템 계정 생성 (`useradd`) | Rocky에도 표준 존재, `/sbin/nologin` 경로 확인 필요 |
| 5 | `/etc/hosts` 등록 | 배포판 무관 |
| 6 | 포트 확인 (`ss -tlnp`) | `iproute` 패키지 설치 필요 (Ubuntu는 기본 포함, Rocky는 미포함 — 실측 확인됨) |
| 7 | tar 백업 | 배포판 무관 |
| 8 | PATH 등록 | 배포판 무관 |
| 9~12 | chmod/chown 권한 관련 | 배포판 무관 |

---

## 검증 기준

- [ ] `linux-systemd` sandbox 타입으로 터미널 연결 시 정상적으로 systemd가 부팅되고 셸이 연결되는지
- [ ] 세트 10의 12개 퀘스트를 처음부터 끝까지 실제로 풀어서 grade_cmd가 모두 정상 판정하는지 확인
- [ ] 1, 2번 퀘스트가 실제 `systemctl status/start/enable/is-active`로 통과하는지 확인
- [ ] 컨테이너 종료/정리가 기존 sandbox 타입들과 동일하게 정상 동작하는지 (고아 컨테이너 안 남는지)
- [ ] 기존 다른 sandbox 타입(`linux`, `docker`, `k8s` 등)에 영향이 없는지 회귀 확인
