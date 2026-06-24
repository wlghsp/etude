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
- setup_cmd가 있는 퀘스트는 독립 실행 가능 (이전 퀘스트 완료 여부 무관)

---

## 샌드박스 설계

환경 정보는 `sandbox` 테이블에서 관리한다.

```
sandbox (type PK, image, binds, description)
    ↑ FK
quest_set (sandbox_type)
```

| sandbox_type | image | 설명 |
|---|---|---|
| `linux` | `ubuntu` | 기본 리눅스 환경 |
| `linux-ssh` | `etude-ssh` | SSH 데몬 포함. scp/rsync 실습용 |
| `docker` | `docker:dind` | Docker-in-Docker. docker 명령어 실습용 |
| `k8s` | `etude-k8s` | kubectl 포함 (향후 추가) |

---

## 퀘스트 세트 구성

### 세트 1 — 리눅스 기초 1: 파일 탐색과 생성 (quest_set_id: 1) ✅

sandbox_type: `linux` / 이미지: `ubuntu`

| order | 제목 | 명령어 | setup_cmd |
|-------|------|--------|-----------|
| 1 | 현재 위치 확인하기 | pwd | — |
| 2 | 디렉토리 이동하기 | cd | — |
| 3 | 파일 목록 확인하기 | ls | — |
| 4 | 파일 상세 목록 확인하기 | ls -al | — |
| 5 | 디렉토리 만들기 | mkdir | — |
| 6 | 빈 파일 만들기 | touch | — |
| 7 | 파일에 내용 쓰기 | echo > | — |
| 8 | 숨김 파일 만들기 | touch .hidden | — |
| 9 | 파일 복사하기 | cp | `echo done > /tmp/answer.txt` |
| 10 | 파일 이름 바꾸기 | mv | `echo done > /tmp/backup.txt` |

---

### 세트 2 — 리눅스 기초 2: 삭제·검색·권한 (quest_set_id: 2) ✅

sandbox_type: `linux` / 이미지: `ubuntu`

| order | 제목 | 명령어 | setup_cmd |
|-------|------|--------|-----------|
| 1 | 파일 삭제하기 | rm | `touch /tmp/renamed.txt` |
| 2 | 디렉토리 삭제하기 | rm -r | `mkdir /tmp/hello` |
| 3 | 파일 내용 출력하기 | cat | `echo done > /tmp/answer.txt` |
| 4 | 파일에서 문자열 검색하기 | grep | `echo done > /tmp/answer.txt` |
| 5 | 여러 줄 파일 만들기 | printf | — |
| 6 | 파일 실행 권한 부여하기 | chmod +x | `echo done > /tmp/answer.txt` |
| 7 | 심볼릭 링크 만들기 | ln -s | `echo done > /tmp/answer.txt` |
| 8 | 중첩 디렉토리 만들기 | mkdir -p | — |
| 9 | 파일 찾기 | find | `echo done > /tmp/answer.txt` |
| 10 | 디스크 사용량 확인하기 | du -sh | — |

---

### 세트 3 — 리눅스 기초 3: 프로세스와 시스템 (quest_set_id: 3) ✅

sandbox_type: `linux` / 이미지: `ubuntu`

| order | 제목 | 명령어 | setup_cmd |
|-------|------|--------|-----------|
| 1 | 실행 중인 프로세스 확인하기 | ps aux | — |
| 2 | 특정 프로세스 찾기 | ps + grep | — |
| 3 | 백그라운드 프로세스 실행하기 | sleep & | — |
| 4 | 프로세스 종료하기 | kill | `sleep 60 & echo $! > /tmp/sleep_pid.txt` |
| 5 | 디스크 사용량 확인하기 | df -h | — |
| 6 | 메모리 사용량 확인하기 | free -h | — |
| 7 | 환경변수 설정하기 | export | — |
| 8 | 전체 환경변수 저장하기 | env | — |

---

### 세트 4 — 리눅스 네트워크/파일 전송 (quest_set_id: 4) ✅

sandbox_type: `linux-ssh` / 이미지: `etude-ssh`

컨테이너 안의 `localhost`를 원격 서버로 삼아 scp/rsync를 실습한다.
SSH 데몬(`sshd`)은 setup_cmd로 각 퀘스트에서 필요 시 직접 기동한다.

| order | 제목 | 명령어 | setup_cmd |
|-------|------|--------|-----------|
| 1 | HTTP 요청 보내기 | curl | — |
| 2 | 파일 다운로드하기 | curl -o | — |
| 3 | 네트워크 연결 확인하기 | ping | — |
| 4 | 열린 포트 확인하기 | ss -tlnp | `nginx &` |
| 5 | SSH로 원격 파일 복사하기 | scp | `/usr/sbin/sshd && curl -s -o /tmp/index.html http://example.com` |
| 6 | rsync로 원격 디렉토리 동기화하기 | rsync | `/usr/sbin/sshd && mkdir -p /tmp/sync_src && touch /tmp/sync_src/file.txt` |
| 7 | 원격 명령 실행 결과 저장하기 | ssh | `/usr/sbin/sshd` |

> `etude-ssh` 이미지: openssh-server, rsync, curl, nginx, iputils-ping, iproute2 포함.
> `backend/docker/Dockerfile.ssh` 참고.

---

### 세트 5 — Docker 기초 (quest_set_id: 5) ✅

sandbox_type: `docker` / 이미지: `docker:dind`

Docker-in-Docker 환경. 호스트와 격리된 독립 Docker 데몬에서 실습.
`waitForDocker`로 dockerd 기동 완료를 확인한 뒤 터미널을 연결한다.

| order | 제목 | 명령어 | setup_cmd |
|-------|------|--------|-----------|
| 1 | 로컬 이미지 목록 확인하기 | docker images | `docker pull hello-world` |
| 2 | 이미지 받아오기 | docker pull | — |
| 3 | 컨테이너 실행하기 | docker run | — |
| 4 | 백그라운드 컨테이너 실행하기 | docker run -d | — |
| 5 | 실행 중인 컨테이너 목록 저장하기 | docker ps | `docker run -d --name my-nginx nginx` |
| 6 | 컨테이너 로그 확인하기 | docker logs | `docker run -d --name my-nginx nginx` |
| 7 | 컨테이너 중지하기 | docker stop | `docker run -d --name my-nginx nginx` |
| 8 | 컨테이너 삭제하고 결과 저장하기 | docker rm | `docker run -d --name my-nginx nginx && docker stop my-nginx` |

---

## 변경 파일

| 파일 | 변경 내용 |
|------|-----------|
| `backend/db/init.sql` | 퀘스트/세트 전체 내용 |
| `backend/src/terminal.ts` | sandbox_type 분기, DinD 처리 |
| `backend/src/sandbox.ts` | sandbox 테이블 조회 |
| `backend/src/quest.ts` | getSetupCmd 포함 |
| `backend/src/index.ts` | sandboxType, questId 쿼리 파라미터 파싱 |
| `frontend/src/components/Terminal.tsx` | sandboxType, questId 전달 + 로딩 UI |
| `frontend/src/App.tsx` | sandboxType 상태 관리 |

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

## 검증 기준

- [x] 세트 1 (파일 탐색과 생성) 10개 완성
- [x] 세트 2 (삭제·검색·권한) 10개 완성
- [x] 세트 3 (프로세스와 시스템) 8개 완성
- [x] 세트 4 (네트워크/파일 전송) 7개 완성
- [x] 세트 5 (Docker 기초) 8개 완성
- [x] sandbox_type별 이미지 분기 구현
- [x] DinD 환경 구현 (waitForDocker + exec shell)
- [x] setup_cmd 실행 구현 (runSetupCmd)
- [x] 터미널 로딩 UI (connected 메시지 기준)
- [x] 각 퀘스트 grade_cmd 직접 검증 완료
- [ ] 컨테이너 고아 처리 (서버 재시작 시 자동 정리)
