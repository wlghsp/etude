# Phase 8d 수동 검증 (5분)

자동 테스트가 못 보는 "실제 환경 연결"만 확인한다. 계정 1개면 된다. 명세: [spec_phase8d_session_security.md](../specs/spec_phase8d_session_security.md)

확인용 (서버에서):

```bash
docker ps --filter label=etude=sandbox --format '{{.Names}}'
```

## 화면 (4개)

- [ ] 1. 세트 진입 → 터미널이 열리고, 퀘스트 하나 채점이 된다
- [ ] 2. 세트 X → 홈 → **세트 Y** 진입 → Y의 퀘스트로 연결된다
- [ ] 3. "환경 초기화" → 정상 동작한다
- [ ] 4. 세트 진입 후 **탭을 그냥 닫기** → 1분 뒤 위 명령 결과가 비어 있다

## 서버 (3개)

```bash
docker compose -f deploy/docker-compose.prod.yml --project-directory . restart backend
docker ps --filter label=etude=sandbox -q | wc -l        # 5번: 0 이면 통과
docker exec etude-backend sh -c '[ -n "$JWT_SECRET" ] && [ "$JWT_SECRET" != "dev-secret" ] && echo 설정됨 || echo 미설정'   # 6번: 설정됨
sudo certbot renew --dry-run 2>&1 | tail -5              # 7번: "all simulated renewals succeeded"
```

- [ ] 5. 재시작 후 실습 컨테이너 0개 (세트에 들어간 상태에서 재시작할 것)
- [ ] 6. `설정됨`
- [ ] 7. 갱신 시험 성공

**막히면** 번호와 화면/출력만 알려 주세요.
