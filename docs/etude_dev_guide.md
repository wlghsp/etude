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
| Phase 5 — 퀘스트 콘텐츠 확장 | [guides/guide_phase5.md](guides/guide_phase5.md) | [specs/spec_phase5_content.md](specs/spec_phase5_content.md) | ✅ 완료 |
| Phase 6 — k8s 기초 실습 세트 | [guides/guide_phase6.md](guides/guide_phase6.md) | [specs/spec_phase6_k8s.md](specs/spec_phase6_k8s.md) | ✅ 완료 |
| Phase 7 — 사용자 인증 + 진행 추적 | [guides/guide_phase7a_auth_backend.md](guides/guide_phase7a_auth_backend.md) 외 | [specs/spec_phase7_auth.md](specs/spec_phase7_auth.md) | ✅ 완료 |
| Phase 7 — 퀘스트 세트 접근 제어 | [guides/guide_phase7h_quest_access.md](guides/guide_phase7h_quest_access.md) | [specs/spec_phase7_quest_access.md](specs/spec_phase7_quest_access.md) | 대기 |
| Phase 8 — 서버 배포 (OCI) | [guides/guide_phase8_deploy.md](guides/guide_phase8_deploy.md) | [specs/spec_phase8_deploy.md](specs/spec_phase8_deploy.md) | 대기 |
| Phase 8b — CI/CD (GitHub Actions) | [guides/guide_phase8b_cicd.md](guides/guide_phase8b_cicd.md) | [specs/spec_phase8b_cicd.md](specs/spec_phase8b_cicd.md) | 대기 |
| Phase 9 — 인앱 피드백 | (Phase 7f 구현 완료, 가이드 미작성) | [specs/spec_phase9_feedback.md](specs/spec_phase9_feedback.md) | ✅ 완료 |
| Phase 10 — vcluster 전환 + KLID CMP 현장실습 | [guides/guide_phase10_klid_cmp.md](guides/guide_phase10_klid_cmp.md) | [specs/spec_phase10_klid_cmp.md](specs/spec_phase10_klid_cmp.md) | 대기 |
| Phase 11 — 퀘스트 콘텐츠 확장 2 | (Phase 10 완료 후 작성) | (Phase 10 완료 후 작성) | 대기 |

---

## 참고 문서

- `docs/glossary/` — 개념 설명 (async/await, WebSocket, Docker 스트리밍, ESM)
- `docs/etude_dev_plan.md` — 아키텍처 및 전체 개발 계획
- `docs/product/okestro_training_platform.md` — 제품 기획/요구사항
- `docs/research/ai_dlc.md` — AI-DLC 개발 방법론
- `docs/research/ai_efficiency_talk_roadmap.md` — AI 효율 활용법 연구
- `docs/research/k8s_cluster_isolation.md` — k8s 샌드박스 격리 설계 검토 (namespace vs 클러스터 per user)
