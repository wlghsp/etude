# Etude 개발 가이드

개발 계획: `etude_dev_plan.md`

---

## 시작 전 환경 확인

```bash
node --version    # v18 이상
docker ps         # Docker(Colima) 실행 중인지 확인
```

Colima 사용 시 소켓 심볼릭 링크 설정 (최초 1회):

```bash
ln -sf ~/.colima/default/docker.sock ~/.docker/run/docker.sock
```

---

## Phase별 가이드

| Phase | 문서 | 명세 | 상태 |
|-------|------|------|------|
| Phase 1 — 터미널 샌드박스 | [guides/guide_phase1.md](guides/guide_phase1.md) | [specs/spec_phase1_terminal.md](specs/spec_phase1_terminal.md) | ✅ 완료 |
| Phase 2 — 퀘스트 + 채점 | [guides/guide_phase2.md](guides/guide_phase2.md) | [specs/spec_phase2_quest.md](specs/spec_phase2_quest.md) | ✅ 완료 |
| Phase 3 — UX 개선 | [guides/guide_phase3.md](guides/guide_phase3.md) | [specs/spec_phase3_ux.md](specs/spec_phase3_ux.md) | ✅ 완료 |
| Phase 4 — MariaDB 연동 + 퀘스트 세트 구조 | [guides/guide_phase4.md](guides/guide_phase4.md) | [specs/spec_phase4_db.md](specs/spec_phase4_db.md) | ✅ 완료 |
| Phase 5 — 퀘스트 콘텐츠 확장 | (Phase 4 완료 후 작성) | (Phase 4 완료 후 작성) | 대기 |
| Phase 6 — 사용자 인증 + 진행 추적 | (Phase 5 완료 후 작성) | (Phase 5 완료 후 작성) | 대기 |
| Phase 7 — k8s 샌드박스 + 현장 실무 세트 | (Phase 6 완료 후 작성) | (Phase 6 완료 후 작성) | 대기 |

---

## 참고 문서

- `docs/glossary/` — 개념 설명 (async/await, WebSocket, Docker 스트리밍, ESM)
- `docs/etude_dev_plan.md` — 아키텍처 및 전체 개발 계획
- `docs/product/okestro_training_platform.md` — 제품 기획/요구사항
- `docs/research/ai_dlc.md` — AI-DLC 개발 방법론
- `docs/research/ai_efficiency_talk_roadmap.md` — AI 효율 활용법 연구
