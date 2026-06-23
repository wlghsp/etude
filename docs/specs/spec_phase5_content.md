# Phase 5 명세 — 퀘스트 콘텐츠 확장

## 목표

플랫폼을 실제로 써보는 팀원이 "이거 쓸 만한데"라는 느낌을 받을 수 있는 수준의 퀘스트 콘텐츠를 작성한다.
세트별로 다른 Docker 이미지를 사용하는 구조를 포함한다.

---

## 퀘스트 작성 기준

- 퀘스트마다 지문 / 힌트 / 풀이 / grade_cmd 가 모두 완성된 것만 추가
- 지문만 보고 풀 수 있는 수준으로 작성 (힌트는 막혔을 때, 풀이는 최후 수단)
- 난이도 순서 배치 — 쉬운 것부터 자연스럽게 이어지도록
- grade_cmd는 직접 터미널에서 실행해서 채점이 정확한지 검증 후 추가

---

## 퀘스트 세트 구성

### 세트 1 — 리눅스 기초 1: 파일 탐색과 생성 (quest_set_id: 1)

| order | 주제 | 명령어 |
|-------|------|--------|
| 1 | 현재 위치 확인 | pwd |
| 2 | 디렉토리 이동 | cd |
| 3 | 파일 목록 | ls |
| 4 | 상세 목록 | ls -al |
| 5 | 디렉토리 만들기 | mkdir |
| 6 | 빈 파일 만들기 | touch |
| 7 | 파일에 내용 쓰기 | echo > |
| 8 | 숨김 파일 만들기 | touch .hidden |
| 9 | 파일 복사 | cp |
| 10 | 파일 이름 변경 | mv |

---

### 세트 2 — 리눅스 기초 2: 삭제·검색·권한 (quest_set_id: 2)

| order | 주제 | 명령어 |
|-------|------|--------|
| 1 | 파일 삭제 | rm |
| 2 | 디렉토리 삭제 | rm -r |
| 3 | 파일 내용 출력 | cat |
| 4 | 문자열 검색 | grep |
| 5 | 여러 줄 파일 | printf |
| 6 | 실행 권한 부여 | chmod +x |
| 7 | 심볼릭 링크 | ln -s |
| 8 | 중첩 디렉토리 | mkdir -p |
| 9 | 파일 찾기 | find |
| 10 | 디스크 사용량 | du -sh |

---

### 세트 3 — 리눅스 네트워크/파일 전송 (quest_set_id: 3)

네트워크 확인 및 서버 간 파일 전송을 실습한다.
SSH 데몬이 포함된 전용 이미지 사용 — 컨테이너 내 `localhost`를 대상 서버로 삼아 scp/rsync 실습.

| order | 주제 | 명령어 |
|-------|------|--------|
| 1 | HTTP 요청 | curl |
| 2 | 파일 다운로드 | curl -O |
| 3 | 네트워크 연결 확인 | ping |
| 4 | 포트 확인 | ss -tlnp |
| 5 | 원격 파일 복사 | scp |
| 6 | 디렉토리 동기화 | rsync |

목표 퀘스트 수: **6개 이상**

> 사용 이미지: openssh-server + rsync + curl 포함 커스텀 이미지 (또는 `rastasheep/ubuntu-sshd` 계열)
> 세트 ID 기반 이미지 분기 구현 필요 (아래 기술 변경 항목 참고)

---

### 세트 4 — Docker 기초 (quest_set_id: 4)

Docker가 설치된 환경에서 컨테이너 조작을 실습한다.

| order | 주제 | 명령어 |
|-------|------|--------|
| 1 | 이미지 목록 | docker images |
| 2 | 이미지 받기 | docker pull |
| 3 | 컨테이너 실행 | docker run |
| 4 | 컨테이너 목록 | docker ps |
| 5 | 컨테이너 중지 | docker stop |
| 6 | 컨테이너 삭제 | docker rm |
| 7 | 로그 확인 | docker logs |
| 8 | 컨테이너 접속 | docker exec |

목표 퀘스트 수: **8개 이상**

> 사용 이미지: `docker:cli` + 호스트 소켓 마운트 (`/var/run/docker.sock`)
> 리눅스 기초 세트 완성 후 진행.

---

## 퀘스트 작성 사이클

```
1. 주제/요구사항 전달
2. AI가 퀘스트 초안 생성 (지문 + 힌트 + 풀이 + grade_cmd)
3. 터미널에서 직접 실행해서 grade_cmd 검증
4. 보강 후 init.sql에 추가
5. docker-compose down -v && docker-compose up -d 로 반영 확인
```

---

## 변경 파일

| 파일 | 변경 내용 |
|------|-----------|
| `backend/db/init.sql` | 퀘스트/세트 추가 |
| `backend/src/terminal.ts` | 세트 ID 기반 이미지 분기 |
| `backend/src/index.ts` | WebSocket 핸들러에 questSetId 전달 |
| `frontend/src/components/Terminal.tsx` | 연결 시 selectedSetId 포함 |

## 샌드박스 설계

환경 정보를 `sandbox` 테이블에서 관리한다. `quest_set`은 `sandbox_type`으로 FK 참조만 하면 되고, 새 환경 추가 시 `sandbox` INSERT 한 줄로 끝난다.

```
sandbox (type PK, image, binds, description)
    ↑ FK
quest_set (sandbox_type)
```

| sandbox_type | image | 설명 |
|---|---|---|
| `linux` | `ubuntu` | 기본 리눅스 환경 |
| `network` | `etude-ssh` | SSH 데몬 포함, scp/rsync 실습용 |
| `docker` | `docker:cli` | 호스트 소켓 마운트, docker 명령어 실습용 |
| `k8s` | `etude-k8s` | kubectl 포함 (향후 추가) |

`backend/src/terminal.ts` — DB에서 sandbox 설정을 조회해 컨테이너 생성:

```typescript
// sandbox 테이블에서 image, binds 조회
const [rows] = await db.query<any[]>('SELECT image, binds FROM sandbox WHERE type = ?', [sandboxType])
const { image, binds } = rows[0]

const container = await docker.createContainer({
  Image: image,
  // ...
  HostConfig: { Binds: binds ?? [] },
})
```

`backend/src/index.ts` — WebSocket 연결 시 `sandboxType` 쿼리 파라미터 파싱:

```typescript
app.get('/ws/terminal', { websocket: true }, (socket, req) => {
  const sandboxType = new URL(req.url, 'http://localhost').searchParams.get('sandboxType') ?? 'linux'
  handleTerminal(socket, docker, sandboxType).catch(...)
})
```

`frontend/src/components/Terminal.tsx` — 세트의 `sandbox_type`을 URL에 포함:

```typescript
const ws = new WebSocket(`ws://localhost:3001/ws/terminal?sandboxType=${sandboxType}`)
```

`frontend/src/App.tsx` — 퀘스트 세트 조회 시 `sandbox_type` 포함해서 Terminal에 전달:

```typescript
const [sandboxType, setSandboxType] = useState<string>('linux')
```

---

## 검증 기준

- [x] 리눅스 기초 세트 1 (파일 탐색과 생성) 10개 완성
- [x] 리눅스 기초 세트 2 (삭제·검색·권한) 10개 완성
- [ ] 각 퀘스트 지문만 보고 풀 수 있는 수준인지 직접 확인
- [ ] grade_cmd가 정확히 동작하는지 터미널에서 검증 완료
- [ ] 세트별 이미지 분기 구현 (terminal.ts)
- [ ] 세트 3 (네트워크/파일 전송) 퀘스트 완성 및 검증
- [ ] 세트 4 (Docker 기초) 퀘스트 완성 및 검증
