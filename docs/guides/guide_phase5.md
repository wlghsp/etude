# Phase 5 구현 가이드 — 퀘스트 콘텐츠 확장

명세: `docs/specs/spec_phase5_content.md`
상태: **진행 중**

---

## 목표

코드 수정 없이 `backend/db/init.sql`에 퀘스트를 추가한다.
퀘스트 작성 → 검증 → 추가의 사이클을 반복한다.

---

## 퀘스트 추가 방법

### 1. init.sql에 INSERT 추가

```sql
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, grade_cmd) VALUES
  (1, 4, '퀘스트 제목',
   '지문',
   '힌트',
   '풀이 명령어',
   '["grade", "cmd"]');
```

### 2. DB 재초기화

```bash
cd backend
docker-compose down -v
docker-compose up -d
```

### 3. 브라우저에서 확인

프론트/백엔드 재시작 없이 퀘스트 목록에 반영된다.

---

## 세트 1 — 리눅스 기초 1: 파일 탐색과 생성

| order | 제목 | grade_cmd |
|-------|------|-----------|
| 1 | 현재 위치 확인하기 | `["sh", "-c", "pwd \| grep -q /"]` |
| 2 | 디렉토리 이동하기 | `["test", "-d", "/tmp"]` |
| 3 | 파일 목록 확인하기 | `["test", "-d", "/tmp"]` |
| 4 | 파일 상세 목록 확인하기 | `["test", "-d", "/tmp"]` |
| 5 | 디렉토리 만들기 | `["test", "-d", "/tmp/hello"]` |
| 6 | 빈 파일 만들기 | `["test", "-f", "/tmp/empty.txt"]` |
| 7 | 파일에 내용 쓰기 | `["grep", "-q", "done", "/tmp/answer.txt"]` |
| 8 | 숨김 파일 만들기 | `["test", "-f", "/tmp/.hidden"]` |
| 9 | 파일 복사하기 | `["test", "-f", "/tmp/backup.txt"]` |
| 10 | 파일 이름 바꾸기 | `["test", "-f", "/tmp/renamed.txt"]` |

---

## 세트 2 — 리눅스 기초 2: 삭제·검색·권한

| order | 제목 | grade_cmd |
|-------|------|-----------|
| 1 | 파일 삭제하기 | `["sh", "-c", "test ! -f /tmp/renamed.txt"]` |
| 2 | 디렉토리 삭제하기 | `["sh", "-c", "test ! -d /tmp/hello"]` |
| 3 | 파일 내용 출력하기 | `["test", "-f", "/tmp/answer.txt"]` |
| 4 | 파일에서 문자열 검색하기 | `["grep", "-q", "done", "/tmp/answer.txt"]` |
| 5 | 여러 줄 파일 만들기 | `["grep", "-q", "line2", "/tmp/multiline.txt"]` |
| 6 | 파일 실행 권한 부여하기 | `["sh", "-c", "test -x /tmp/answer.txt"]` |
| 7 | 심볼릭 링크 만들기 | `["sh", "-c", "test -L /tmp/link.txt"]` |
| 8 | 중첩 디렉토리 만들기 | `["test", "-d", "/tmp/a/b/c"]` |
| 9 | 파일 찾기 | `["sh", "-c", "find /tmp -name '*.txt' \| grep -q ."]` |
| 10 | 디스크 사용량 확인하기 | `["sh", "-c", "du -sh /tmp \| grep -q /tmp"]` |

---

## 세트별 이미지 분기 구현

세트마다 다른 환경이 필요하므로 `terminal.ts`에서 `questSetId`를 받아 이미지를 분기한다.

### 구현 순서

1. `backend/src/quest.ts` — `getQuestSets()` 쿼리에 `sandbox_type` 포함
2. `backend/src/terminal.ts` — `handleTerminal`에 `sandboxType` 파라미터 추가, DB에서 sandbox 조회
3. `backend/src/index.ts` — WebSocket에서 `?sandboxType=` 파싱 후 전달
4. `frontend/src/App.tsx` — `sandboxType` state 추가, `SetSelect`에서 함께 받기
5. `frontend/src/components/Terminal.tsx` — WebSocket URL에 `?sandboxType=` 추가

### terminal.ts 이미지 분기

`sandbox` 테이블에서 image/binds를 조회해 컨테이너를 생성한다. 새 환경 추가 시 이 코드는 건드리지 않아도 된다.

```typescript
async function getContainerConfig(sandboxType: string) {
  const [rows] = await db.query<any[]>(
    'SELECT image, binds FROM sandbox WHERE type = ?',
    [sandboxType]
  )
  const { image, binds } = rows[0] ?? { image: 'ubuntu', binds: null }
  return {
    Image: image,
    HostConfig: { Binds: binds ?? [] },
  }
}
```

### index.ts WebSocket 쿼리 파라미터 파싱

```typescript
app.get('/ws/terminal', { websocket: true }, (socket, req) => {
  const sandboxType = new URL(req.url, 'http://localhost').searchParams.get('sandboxType') ?? 'linux'
  handleTerminal(socket, docker, sandboxType as SandboxType).catch((err) => {
    console.error('terminal error:', err)
    socket.close()
  })
})
```

### Terminal.tsx WebSocket URL

```typescript
const ws = new WebSocket(`ws://localhost:3001/ws/terminal?sandboxType=${sandboxType}`)
```

### quest.ts — getQuestSets에 sandbox_type 포함

```typescript
export async function getQuestSets() {
  const [rows] = await db.query('SELECT id, title, description, sandbox_type FROM quest_set')
  return rows
}
```

### App.tsx — sandboxType 상태 관리

`SetSelect`의 `onSelect`가 `{ id, sandboxType }` 을 넘기도록 변경:

```typescript
// App.tsx
const [sandboxType, setSandboxType] = useState<string>('linux')

// onSelect 핸들러
function handleSetSelect(id: number, sandboxType: string) {
  setSelectedSetId(id)
  setSandboxType(sandboxType)
}

// SetSelect에 전달
<SetSelect onSelect={handleSetSelect} />

// Terminal에 전달
<Terminal key={selectedSetId} sandboxType={sandboxType} onConnected={setContainerId} />
```

```typescript
// SetSelect.tsx — onSelect 시그니처 변경
interface Props {
  onSelect: (id: number, sandboxType: string) => void
}

// 버튼 클릭 시
onClick={() => onSelect(s.id, s.sandbox_type)}
```

---

## 세트 3 — 리눅스 네트워크/파일 전송

**방법: SSH 데몬 포함 커스텀 이미지**

컨테이너 안에서 `localhost`를 원격 서버로 삼아 scp/rsync를 실습한다.

### 커스텀 이미지 빌드 (Dockerfile)

`backend/docker/Dockerfile.ssh`:

```dockerfile
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y \
    openssh-server rsync curl iputils-ping iproute2 \
    && rm -rf /var/lib/apt/lists/*
RUN mkdir /var/run/sshd \
    && echo 'root:root' | chpasswd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#StrictModes yes/StrictModes no/' /etc/ssh/sshd_config
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
```

빌드:

```bash
cd backend
docker build -f docker/Dockerfile.ssh -t etude-ssh .
```

| order | 제목 | grade_cmd |
|-------|------|-----------|
| 1 | HTTP 요청 보내기 | `["sh", "-c", "curl -s http://example.com \| grep -q html"]` |
| 2 | 파일 다운로드하기 | `["test", "-f", "/tmp/index.html"]` |
| 3 | 네트워크 연결 확인하기 | `ping -c 1 8.8.8.8` 성공 여부 |
| 4 | 열린 포트 확인하기 | `["test", "-f", "/tmp/ports.txt"]` |
| 5 | SSH로 원격 파일 복사하기 | `["test", "-f", "/tmp/remote_copy.html"]` |
| 6 | rsync로 디렉토리 동기화하기 | `["test", "-f", "/tmp/sync_dst/file.txt"]` |
| 7 | 원격 명령 실행 결과 저장하기 | `["test", "-s", "/tmp/hostname.txt"]` |
| 8 | 프로세스 목록 저장하기 | `["test", "-s", "/tmp/ps_result.txt"]` |

---

## 세트 4 — Docker 기초

**방법: 호스트 Docker 소켓 마운트**

호스트의 `/var/run/docker.sock`을 마운트하면 컨테이너 안에서 docker 명령어를 사용할 수 있다.

| order | 제목 | grade_cmd |
|-------|------|-----------|
| 1 | 로컬 이미지 목록 확인하기 | `["test", "-f", "/tmp/images.txt"]` |
| 2 | 이미지 받아오기 | `docker images hello-world \| grep -q hello-world` |
| 3 | 컨테이너 실행하기 | `docker ps -a \| grep -q hello-world` |
| 4 | 백그라운드 컨테이너 실행하기 | `docker ps \| grep -q my-nginx` |
| 5 | 실행 중인 컨테이너 목록 저장하기 | `["test", "-s", "/tmp/containers.txt"]` |
| 6 | 컨테이너 로그 확인하기 | `["test", "-f", "/tmp/nginx_logs.txt"]` |
| 7 | 컨테이너 중지하기 | `docker ps \| grep -qv my-nginx` |
| 8 | 컨테이너 삭제하고 결과 저장하기 | `docker ps -a \| grep -qv my-nginx` |

---

## 리팩토링 (구현 완료 후)

세트별 이미지 분기 구현이 완료된 뒤 아래 순서로 정리한다.

### 백엔드

**`backend/src/sandbox.ts` 분리**

`terminal.ts`에 있는 sandbox 조회 로직을 별도 파일로 분리:

```typescript
// backend/src/sandbox.ts
export async function getSandboxConfig(sandboxType: string) {
  const [rows] = await db.query<any[]>(
    'SELECT image, binds FROM sandbox WHERE type = ?',
    [sandboxType]
  )
  return rows[0] ?? { image: 'ubuntu', binds: null }
}
```

**타입 정의 분리**

`backend/src/types.ts` 신규 생성 — 여러 파일에서 공유하는 인터페이스 모음:

```typescript
export interface QuestSet {
  id: number
  title: string
  description: string
  sandbox_type: string
}

export interface Quest {
  id: number
  title: string
  description: string
  hint: string
  solution: string
}
```

### 프론트엔드

**`frontend/src/api.ts` 분리**

`App.tsx`, `SetSelect.tsx`에 흩어진 fetch 호출을 한 곳으로 모음:

```typescript
// frontend/src/api.ts
const BASE = 'http://localhost:3001'

export async function fetchQuestSets() {
  return fetch(`${BASE}/quest-sets`).then((r) => r.json())
}

export async function fetchQuests(setId: number) {
  return fetch(`${BASE}/quest-sets/${setId}/quests`).then((r) => r.json())
}

export async function gradeQuest(containerId: string, questId: number) {
  return fetch(`${BASE}/grade`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ containerId, questId }),
  }).then((r) => r.json())
}
```

**`sandboxType` Context 검토**

`App` → `Terminal`로 내려가는 `sandboxType` prop chain이 불편하면 Context로 올리는 것을 검토한다. 지금은 단순하므로 props로 충분하다.

---

## 퀘스트 작성 요청 방법

AI에게 퀘스트 생성을 요청할 때 아래 형식으로 전달하면 된다:

```
주제: [파일 복사]
조건: ubuntu 컨테이너 환경, /tmp 디렉토리 사용
난이도: 기초
```

AI가 지문 + 힌트 + 풀이 + grade_cmd를 포함한 INSERT 쿼리를 생성해준다.
직접 터미널에서 실행해서 grade_cmd가 정확한지 검증 후 init.sql에 추가한다.
