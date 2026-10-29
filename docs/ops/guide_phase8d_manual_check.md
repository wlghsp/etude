# 운영 가이드 — Phase 8d 수동 검증 체크리스트

공개(파일럿) 전에 확인한다. 명세: [spec_phase8d_session_security.md](../specs/spec_phase8d_session_security.md)

## 왜 수동으로 확인하나

자동 테스트(163개)는 인증·권한·레지스트리·정리 로직을 mock Docker와 `inject()`로 검증한다. 아래는 그 방식으로 **확인할 수 없는 부분**이다.

- 실제 Docker 컨테이너가 만들어지고 **지워지는지** (테스트는 mock)
- 브라우저에서 탭을 닫거나 세트를 바꿀 때 프론트가 실제로 연결을 끊는지
- nginx를 거친 실제 WebSocket 동작 (`injectWS`는 정상 close 핸드셰이크를 끝내지 못함)
- 서버 종료·재시작 시 정리가 기동·종료 훅에서 실제로 호출되는지 (명세 수용 조건 2개가 이 이유로 미체크)

즉 로직은 자동으로 검증됐고, **로직이 실제 환경에 연결돼 있는지**를 사람이 한 번 확인하는 것이다.

---

## A. 화면 검증

준비: 계정 2개(A, B). 확인용 명령은 서버 또는 로컬 Docker가 있는 곳에서 실행한다.

```bash
docker ps --filter label=etude=sandbox --format '{{.Names}}\t{{.Status}}'   # 실습 컨테이너 목록
```

| # | 할 일 | 기대 결과 | 확인 |
|---|-------|-----------|------|
| 1 | A로 로그인, 세트 하나 진입 | 터미널이 열린다. 컨테이너가 **1개** 생긴다 | [ ] |
| 2 | 퀘스트 하나를 풀고 채점 | 통과/실패가 정상 표시된다 | [ ] |
| 3 | 세트 X → 홈 → **세트 Y** 진입 | Y의 퀘스트로 연결된다 (X의 환경이 아님). X 컨테이너는 사라지고 Y만 남는다 | [ ] |
| 4 | "환경 초기화" 실행 | 컨테이너가 **교체**된다 (이름/ID가 바뀌고 개수는 그대로) | [ ] |
| 5 | 세트에서 홈으로 이탈 | 컨테이너가 사라진다 | [ ] |
| 6 | 세트 진입 후 **브라우저 탭을 그냥 닫기** | 잠시 후(최대 약 1분) 컨테이너가 사라진다. `docker-persistent` 세트(세트 8)도 포함 | [ ] |
| 7 | 로그아웃 상태로 `/terminal-sessions` 호출 | `401` | [ ] |

```bash
curl -s -o /dev/null -w '%{http_code}\n' -X POST https://{서버 도메인}/terminal-sessions
# 기대: 401
```

| # | 할 일 | 기대 결과 | 확인 |
|---|-------|-----------|------|
| 8 | (선택) 퀘스트 접근 권한이 없는 계정으로 그 퀘스트 진입 | 연결이 거부된다 (`403`) | [ ] |

문제가 보이면 **어느 번호에서, 화면과 `docker ps` 결과가 어땠는지**를 알려 주면 된다.

## B. 서버 종료·재시작 시 정리 (명세 미체크 2개)

```bash
# 1) 세트에 진입해 컨테이너가 생긴 상태에서
docker ps --filter label=etude=sandbox -q | wc -l        # 1 이상

# 2) backend 재시작
docker compose -f deploy/docker-compose.prod.yml --project-directory . restart backend

# 3) 재기동 후
docker ps --filter label=etude=sandbox -q | wc -l        # 0
docker logs --tail=30 etude-backend                       # 정리 로그, 오류 없음
```

- 기대: 재시작 뒤 실습 컨테이너가 0개이고, 종료가 타이머 때문에 지연되지 않는다.
- 같은 방식으로 `docker stop etude-backend`로 멈췄을 때 종료가 오래 걸리지 않는지(수 초 이내) 본다.

---

## C. 공개 전 서버 설정 점검 (메모리의 미해결 운영 항목)

### JWT 서명 비밀값이 설정돼 있나

`.env.prod`에 `JWT_SECRET`이 없으면 코드의 기본 문자열(`dev-secret`)로 서명된다. 값을 출력하지 않고 설정 여부만 본다.

```bash
docker exec etude-backend sh -c '[ -n "$JWT_SECRET" ] && [ "$JWT_SECRET" != "dev-secret" ] && echo 설정됨 || echo 미설정'
```

- `미설정`이면 `.env.prod`에 충분히 긴 무작위 값을 넣고 **`--build`로 재기동**한다. 이미 발급된 토큰은 모두 무효가 된다 (재로그인 필요).
- 값은 채팅이나 문서에 붙이지 않는다.

### 인증서 자동 갱신

인증서는 2027-01-26까지 유효하지만, 자동 갱신 시험이 실패했던 이력이 있다. 원인이 해결되지 않으면 그 전에 만료된다.

```bash
sudo certbot renew --dry-run 2>&1 | tail -30
```

- 성공하면 `Congratulations, all simulated renewals succeeded`가 나온다.
- 실패하면 마지막 오류 줄을 알려 달라 (도메인 정보 외에 비밀값은 출력되지 않는다). 원인 확인 후 `troubleshooting_{날짜}_*.md`로 기록한다.

---

## 결과 기록

모두 확인되면 명세의 미체크 수용 조건 2개를 체크하고 (B 결과 반영), 이 체크리스트의 확인란을 채운 사실을 커밋 메시지나 명세에 남긴다.
