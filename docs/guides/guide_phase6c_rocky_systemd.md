# Phase 6c 구현 가이드 — Rocky Linux systemd sandbox 타입 추가

명세: [specs/spec_phase6c_rocky_systemd.md](../specs/spec_phase6c_rocky_systemd.md)

전제: [Phase 6](guide_phase6.md)(k8s 기초)가 구현되어 있는 상태. `terminal.ts`의 `handleDockerTerminal`(DinD, privileged 컨테이너 처리)을 그대로 참고한다.

---

## 전체 흐름

```
Step 1. backend/db/01_sandbox.sql — linux-systemd 타입 추가
Step 2. terminal.ts — handleSystemdTerminal 분기 추가
Step 3. backend/db/03_quest_set10.sql — sandbox_type 변경 + 1,2번 문제 systemctl로 원복 + 6번 iproute 설치
Step 4. 로컬 검증
```

---

## Step 1. `backend/db/01_sandbox.sql` — 타입 추가

```sql
('linux-systemd', 'rockylinux/rockylinux:9-ubi-init', NULL, FALSE, 'Rocky Linux systemd 환경. 실제 systemctl 명령이 동작하는 서비스 관리 실습용.'),
```

---

## Step 2. `terminal.ts` — systemd 분기

`handleDockerTerminal`(DinD)과 거의 동일한 구조다 — 차이는 부팅 완료를 기다리는 조건뿐이다. DinD는 `/var/run/docker.sock`이 생길 때까지 기다리는데(`waitForDocker`), systemd는 `systemctl is-system-running`이 응답할 때까지 기다린다.

```typescript
async function waitForSystemd(container: Docker.Container): Promise<void> {
    const exec = await container.exec({
        Cmd: ['sh', '-c', 'until systemctl is-system-running 2>/dev/null | grep -qE "running|degraded"; do sleep 0.3; done'],
        AttachStdout: false,
        AttachStderr: false,
    })
    await exec.start({})
    await new Promise<void>((resolve) => {
        const poll = setInterval(async () => {
            const info = await exec.inspect()
            if (!info.Running) {
                clearInterval(poll)
                resolve()
            }
        }, 300)
    })
}

async function handleSystemdTerminal(socket: WebSocket, docker: Docker, config: { image: string, binds: string[] | null }, questId: number | null) {
  const container = await docker.createContainer({
    Image: config.image,
    Labels: { etude: 'sandbox' },
    OpenStdin: false, Tty: false,
    AttachStdin: false, AttachStdout: false, AttachStderr: false,
    HostConfig: {
      Binds: [...(config.binds ?? []), '/sys/fs/cgroup:/sys/fs/cgroup:rw'],
      Privileged: true,
      CgroupnsMode: 'host',
    },
    // 이미지의 기본 Entrypoint(/usr/sbin/init)를 그대로 사용 — Cmd 지정 안 함
  })
  await container.start()
  await waitForSystemd(container)

  await runSetupCmd(container, questId)

  const exec = await container.exec({
    Cmd: ['/bin/bash'],
    AttachStdin: true, AttachStdout: true, AttachStderr: true, Tty: true,
  })
  const stream = await exec.start({ hijack: true, stdin: true, Tty: true })

  socket.send(JSON.stringify({ type: 'connected', containerId: container.id }))

  stream.on('data', (chunk: Buffer) => socket.send(chunk))
  socket.on('message', (msg: Buffer) => stream.write(msg))
  socket.on('close', () => {
    container.stop().then(() => container.remove()).catch(() => {})
  })
}
```

`handleTerminal()`의 분기에 추가:

```typescript
} else if (sandboxType === 'linux-systemd') {
    await handleSystemdTerminal(socket, docker, config, questId)
} else if (sandboxType === 'docker' || sandboxType === 'docker-persistent') {
    await handleDockerTerminal(socket, docker, config, questId, containerId)
} else {
```

---

## Step 3. `backend/db/03_quest_set10.sql` — 콘텐츠 재작성

### quest_set 테이블의 sandbox_type 변경

`backend/db/02_quest_set.sql`에서 세트 10 행의 `sandbox_type`을 `linux`에서 `linux-systemd`로 변경.

### 1, 2번 문제 — systemctl로 원복 (패키지/서비스명 Rocky 기준으로 수정)

Rocky/RHEL 계열은 cron 패키지명이 `cronie`, 서비스명이 `crond`다 (Ubuntu는 `cron`/`cron`).

```sql
(10, 1, '서비스 상태 확인하기',
 'cron 서비스의 상태를 확인하고 결과를 /tmp/svc_status.txt 에 저장하세요.',
 'systemctl status <서비스명> 명령어를 사용하세요.',
 'systemctl status crond > /tmp/svc_status.txt 2>&1',
 '["sh", "-c", "dnf install -y cronie > /dev/null 2>&1"]',
 '["sh", "-c", "grep -qi ''crond'' /tmp/svc_status.txt"]'),

(10, 2, '서비스 시작하고 활성화하기',
 'cron 서비스를 시작하고 부팅 시 자동 시작되도록 활성화하세요.',
 'systemctl start 와 systemctl enable 을 사용하세요.',
 'systemctl start crond && systemctl enable crond',
 '["sh", "-c", "dnf install -y cronie > /dev/null 2>&1 && systemctl stop crond 2>/dev/null || true"]',
 '["sh", "-c", "systemctl is-active crond"]'),
```

### 6번 문제 — `ss` 명령을 위한 `iproute` 사전 설치

```sql
(10, 6, '포트 사용 현황 확인하기',
 '현재 리스닝 중인 TCP 포트 목록을 /tmp/ports.txt 에 저장하세요.',
 'ss -tlnp 를 사용하세요.',
 'ss -tlnp > /tmp/ports.txt',
 '["sh", "-c", "dnf install -y iproute > /dev/null 2>&1"]',
 '["sh", "-c", "grep -qi ''listen\\|LISTEN'' /tmp/ports.txt"]'),
```

### 나머지 문제 (3, 4, 5, 7~12번)

`useradd`, `/etc/profile.d`, `/etc/hosts`, `tar`, `chmod`, `chown`은 배포판 무관하게 동작하므로 로직 변경 없음. 다만 Rocky 환경에서 실제로 통과하는지 로컬 검증(Step 4)에서 재확인한다.

---

## Step 4. 로컬 검증

```bash
# 이미지가 정상적으로 systemd 부팅하는지 단독 확인
docker run -d --name systemd-test --privileged --cgroupns=host \
  -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
  rockylinux/rockylinux:9-ubi-init /usr/sbin/init

sleep 3
docker exec systemd-test systemctl is-system-running

# 세트 10 각 문제의 setup_cmd/grade_cmd를 순서대로 직접 실행해 통과하는지 확인
docker exec systemd-test dnf install -y cronie -q
docker exec systemd-test systemctl status crond > /tmp/svc_status.txt 2>&1
docker exec systemd-test grep -qi crond /tmp/svc_status.txt && echo "Q1 PASS"

docker exec systemd-test systemctl start crond
docker exec systemd-test systemctl enable crond
docker exec systemd-test systemctl is-active crond && echo "Q2 PASS"

# 확인 후 정리
docker rm -f systemd-test
```

이후 백엔드/프론트를 통해 실제로 세트 10 12문제를 처음부터 끝까지 브라우저에서 풀어보며 검증한다.

---

## 검증

- [ ] `linux-systemd` 타입으로 터미널 연결 시 몇 초 내로 정상 연결되는지 (systemd 부팅 대기 시간 확인)
- [ ] 1~12번 문제 모두 grade_cmd 통과 확인
- [ ] 세션 종료 시 컨테이너 정상 정리(고아 안 남음) 확인
- [ ] 기존 `linux`, `docker` 등 다른 sandbox 타입 회귀 없음 확인
