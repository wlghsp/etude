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

## 세트 1 — 리눅스 기초

### 완성된 퀘스트

| order | 제목 | grade_cmd |
|-------|------|-----------|
| 1 | /tmp/hello 디렉토리 만들기 | `["test", "-d", "/tmp/hello"]` |
| 2 | 파일에 내용 쓰기 | `["grep", "-q", "done", "/tmp/answer.txt"]` |
| 3 | 숨김 파일 만들기 | `["test", "-f", "/tmp/.hidden"]` |

### 추가 예정 주제

- 파일 복사 (cp)
- 파일 이동/이름 변경 (mv)
- 파일 삭제 (rm)
- 파일 내용 확인 (cat, head, tail)
- 특정 문자열 검색 (grep)
- 파일 권한 변경 (chmod)
- 심볼릭 링크 생성 (ln -s)
- 프로세스 확인 (ps)
- 디스크 사용량 확인 (df, du)
- 네트워크 연결 확인 (curl)

---

## 세트 2 — Docker 기초

Docker-in-Docker 환경 구성이 필요하므로 리눅스 기초 세트 완성 후 진행.

현재 샌드박스(ubuntu 컨테이너)에서 docker 명령어를 실행하려면:
- DinD(Docker-in-Docker) 이미지 사용 필요 (`docker:dind`)
- 또는 호스트 Docker 소켓을 컨테이너에 마운트 (`/var/run/docker.sock`)

→ 보안/구조 검토 후 방향 확정.

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
