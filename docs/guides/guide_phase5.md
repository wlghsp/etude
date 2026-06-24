# Phase 5 구현 가이드 — 퀘스트 콘텐츠 확장

명세: `docs/specs/spec_phase5_content.md`
상태: **구현 완료**

---

## 구현 완료 항목

- sandbox_type별 이미지 분기 (`sandbox` 테이블 + `getSandboxConfig`)
- DinD 환경 (`docker:dind` + waitForDocker + exec shell)
- setup_cmd 실행 (`runSetupCmd` — linux/docker 공통)
- 터미널 로딩 UI (`connected` 메시지 기준)
- 퀘스트 세트 5개 / 총 43개 퀘스트

---

## 아키텍처

### 레이어 흐름

```
init.sql → DB (sandbox, quest_set, quest 테이블)
    ↓
quest.ts    — getQuestSets / getQuests / gradeQuest / getSetupCmd
sandbox.ts  — getSandboxConfig
    ↓
terminal.ts — handleTerminal → handleDefaultTerminal / handleDockerTerminal
    ↓
index.ts    — WebSocket 라우팅 (/ws/terminal?sandboxType=&questId=)
    ↓
Terminal.tsx — WebSocket 연결 + xterm.js 렌더링 + 로딩 UI
```

### sandbox_type 분기

`terminal.ts`의 `handleTerminal`이 sandboxType에 따라 분기한다:

- `linux`, `linux-ssh` → `handleDefaultTerminal` (attach 방식)
- `docker` → `handleDockerTerminal` (exec 방식 — dockerd가 attach 스트림 점유)

---

## 퀘스트 추가 방법

새 퀘스트 세트 추가 시 건드는 파일은 `init.sql` 하나다.

### 1. init.sql에 세트/퀘스트 INSERT

```sql
-- 세트 추가 시 id 명시 (중간 삽입 시 FK 안전)
INSERT INTO quest_set (id, title, description, sandbox_type) VALUES
  (6, '새 세트 제목', '설명', 'linux');

-- 퀘스트 추가
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (6, 1, '퀘스트 제목',
   '지문',
   '힌트',
   '풀이 명령어',
   NULL,
   '["grade", "cmd"]');
```

`setup_cmd`는 퀘스트 실행 전 컨테이너에서 선행 실행되는 명령어 배열이다. 불필요하면 `NULL`.

### 2. DB 재초기화

```bash
cd backend
docker-compose down -v
docker-compose up -d
```

### 3. 브라우저에서 확인

백엔드/프론트 재시작 없이 퀘스트 목록에 반영된다.

---

## 새 sandbox_type 추가 방법

새 이미지 환경이 필요한 경우:

1. `init.sql`의 `sandbox` INSERT에 새 타입 추가
2. `terminal.ts`의 `SandboxType` union에 추가
3. docker 계열이면 `handleTerminal`의 분기 조건 확인
4. 커스텀 이미지면 `backend/docker/` 에 Dockerfile 추가 후 빌드

코드 변경 최소화 원칙: 기본 linux 계열은 코드 변경 없이 `sandbox` INSERT만으로 추가 가능.

---

## 세트 1 — 리눅스 기초 1 (파일 탐색과 생성)

sandbox_type: `linux` | 퀘스트: 10개

| order | 제목 | grade_cmd |
|-------|------|-----------|
| 1 | 현재 위치 확인하기 | `grep -q / /tmp/pwd_result.txt` |
| 2 | 디렉토리 이동하기 | `grep -q /tmp /tmp/pwd_result.txt` |
| 3 | 파일 목록 확인하기 | `grep -q passwd /tmp/ls_result.txt` |
| 4 | 파일 상세 목록 확인하기 | `grep -q ^total /tmp/ls_detail.txt` |
| 5 | 디렉토리 만들기 | `test -d /tmp/hello` |
| 6 | 빈 파일 만들기 | `test -f /tmp/empty.txt` |
| 7 | 파일에 내용 쓰기 | `grep -q done /tmp/answer.txt` |
| 8 | 숨김 파일 만들기 | `test -f /tmp/.hidden` |
| 9 | 파일 복사하기 | `test -f /tmp/backup.txt` |
| 10 | 파일 이름 바꾸기 | `test -f /tmp/renamed.txt` |

---

## 세트 2 — 리눅스 기초 2 (삭제·검색·권한)

sandbox_type: `linux` | 퀘스트: 10개

| order | 제목 | grade_cmd |
|-------|------|-----------|
| 1 | 파일 삭제하기 | `test ! -f /tmp/renamed.txt` |
| 2 | 디렉토리 삭제하기 | `test ! -d /tmp/hello` |
| 3 | 파일 내용 출력하기 | `grep -q done /tmp/cat_result.txt` |
| 4 | 파일에서 문자열 검색하기 | `grep -q done /tmp/answer.txt` |
| 5 | 여러 줄 파일 만들기 | `grep -q line2 /tmp/multiline.txt` |
| 6 | 파일 실행 권한 부여하기 | `test -x /tmp/answer.txt` |
| 7 | 심볼릭 링크 만들기 | `test -L /tmp/link.txt` |
| 8 | 중첩 디렉토리 만들기 | `test -d /tmp/a/b/c` |
| 9 | 파일 찾기 | `grep -q .txt /tmp/find_result.txt` |
| 10 | 디스크 사용량 확인하기 | `grep -q /tmp /tmp/du_result.txt` |

---

## 세트 3 — 리눅스 기초 3 (프로세스와 시스템)

sandbox_type: `linux` | 퀘스트: 8개

| order | 제목 | grade_cmd |
|-------|------|-----------|
| 1 | 실행 중인 프로세스 확인하기 | `test -s /tmp/ps_result.txt` |
| 2 | 특정 프로세스 찾기 | `grep -q bash /tmp/bash_proc.txt` |
| 3 | 백그라운드 프로세스 실행하기 | `test -s /tmp/sleep_pid.txt` |
| 4 | 프로세스 종료하기 | `! kill -0 $(cat /tmp/sleep_pid.txt) 2>/dev/null` |
| 5 | 디스크 사용량 확인하기 | `grep -q Filesystem /tmp/df_result.txt` |
| 6 | 메모리 사용량 확인하기 | `grep -q Mem /tmp/mem_result.txt` |
| 7 | 환경변수 설정하기 | `grep -q etude /tmp/env_result.txt` |
| 8 | 전체 환경변수 저장하기 | `grep -q PATH /tmp/all_env.txt` |

---

## 세트 4 — 리눅스 네트워크/파일 전송

sandbox_type: `linux-ssh` / 이미지: `etude-ssh` | 퀘스트: 7개

SSH 데몬이 포함된 커스텀 이미지. 컨테이너 내 `localhost`를 원격 서버로 삼아 scp/rsync 실습.
`etude-ssh` 이미지에 sshd가 설치되어 있지만 Cmd를 bash로 오버라이드하므로, setup_cmd에서 직접 기동한다.

```bash
# etude-ssh 이미지 빌드 (최초 1회)
cd backend
docker build -f docker/Dockerfile.ssh -t etude-ssh .
```

| order | 제목 | setup_cmd | grade_cmd |
|-------|------|-----------|-----------|
| 1 | HTTP 요청 보내기 | — | `curl -s http://example.com \| grep -q html` |
| 2 | 파일 다운로드하기 | — | `test -f /tmp/index.html` |
| 3 | 네트워크 연결 확인하기 | — | `ping -c 1 8.8.8.8 > /dev/null 2>&1` |
| 4 | 열린 포트 확인하기 | `nginx &` | `grep -q :80 /tmp/ports.txt` |
| 5 | SSH로 원격 파일 복사하기 | `/usr/sbin/sshd && curl -s -o /tmp/index.html ...` | `test -f /tmp/remote_copy.html` |
| 6 | rsync로 원격 디렉토리 동기화하기 | `/usr/sbin/sshd && mkdir -p /tmp/sync_src && ...` | `test -f /tmp/sync_dst/file.txt` |
| 7 | 원격 명령 실행 결과 저장하기 | `/usr/sbin/sshd` | `test -s /tmp/hostname.txt` |

---

## 세트 5 — Docker 기초

sandbox_type: `docker` / 이미지: `docker:dind` | 퀘스트: 8개

Docker-in-Docker 환경. `waitForDocker`가 dockerd 소켓(`/var/run/docker.sock`)이 생길 때까지 대기 후 shell exec으로 연결.
구현 상세는 `docs/guides/guide_docker_sandbox.md` 참고.

| order | 제목 | setup_cmd | grade_cmd |
|-------|------|-----------|-----------|
| 1 | 로컬 이미지 목록 확인하기 | `docker pull hello-world` | `grep -q hello-world /tmp/images.txt` |
| 2 | 이미지 받아오기 | — | `docker images hello-world \| grep -q hello-world` |
| 3 | 컨테이너 실행하기 | — | `docker ps -a \| grep -q hello-world` |
| 4 | 백그라운드 컨테이너 실행하기 | — | `docker ps \| grep -q my-nginx` |
| 5 | 실행 중인 컨테이너 목록 저장하기 | `docker run -d --name my-nginx nginx` | `test -s /tmp/containers.txt` |
| 6 | 컨테이너 로그 확인하기 | `docker run -d --name my-nginx nginx` | `test -f /tmp/nginx_logs.txt` |
| 7 | 컨테이너 중지하기 | `docker run -d --name my-nginx nginx` | `docker ps \| grep -qv my-nginx` |
| 8 | 컨테이너 삭제하고 결과 저장하기 | `docker run -d --name my-nginx nginx && docker stop my-nginx` | `test -s /tmp/final.txt && ! grep -q my-nginx /tmp/final.txt` |

---

## 퀘스트 작성 요청 방법

AI에게 퀘스트 생성을 요청할 때 아래 형식으로 전달:

```
주제: [파일 복사]
sandbox_type: linux
조건: /tmp 디렉토리 사용
난이도: 기초
```

AI가 지문 + 힌트 + 풀이 + setup_cmd + grade_cmd를 포함한 INSERT 쿼리를 생성해준다.
직접 터미널에서 실행해서 grade_cmd가 정확한지 검증 후 init.sql에 추가한다.

---

## 미결 사항

### 컨테이너 고아 처리

서버 재시작 또는 브라우저 강제 종료 시 컨테이너가 stop/remove 되지 않고 남는다.
구현 방법: `docs/guides/guide_container_cleanup.md` 참고.
