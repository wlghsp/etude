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

> 완료된 가이드는 [guides/completed/](guides/completed/)에, 진행 중이거나 미완료인 가이드는 `guides/` 바로 아래에 둔다. 가이드를 완료하면 이 표의 상태를 ✅로 바꾸고 파일을 `completed/`로 옮긴다.

| Phase | 문서 | 명세 | 상태 |
|-------|------|------|------|
| Phase 1 — 터미널 샌드박스 | [guides/completed/guide_phase1.md](guides/completed/guide_phase1.md) | [specs/spec_phase1_terminal.md](specs/spec_phase1_terminal.md) | ✅ 완료 |
| Phase 1b — containerId 관리 주체를 Terminal로 이전 | [guides/completed/guide_phase1b_terminal_container_ownership.md](guides/completed/guide_phase1b_terminal_container_ownership.md) | [specs/spec_phase1b_terminal_container_ownership.md](specs/spec_phase1b_terminal_container_ownership.md) | ✅ 완료 |
| Phase 2 — 퀘스트 + 채점 | [guides/completed/guide_phase2.md](guides/completed/guide_phase2.md) | [specs/spec_phase2_quest.md](specs/spec_phase2_quest.md) | ✅ 완료 |
| Phase 3 — UX 개선 | [guides/completed/guide_phase3.md](guides/completed/guide_phase3.md) | [specs/spec_phase3_ux.md](specs/spec_phase3_ux.md) | ✅ 완료 |
| Phase 4 — MariaDB 연동 + 퀘스트 세트 구조 | [guides/completed/guide_phase4.md](guides/completed/guide_phase4.md) | [specs/spec_phase4_db.md](specs/spec_phase4_db.md) | ✅ 완료 |
| Phase 5 — 퀘스트 콘텐츠 확장 | [guides/completed/guide_phase5.md](guides/completed/guide_phase5.md) | [specs/spec_phase5_content.md](specs/spec_phase5_content.md) | ✅ 완료 |
| Phase 6 — k8s 기초 실습 세트 | [guides/completed/guide_phase6.md](guides/completed/guide_phase6.md) | [specs/spec_phase6_k8s.md](specs/spec_phase6_k8s.md) | ✅ 완료 |
| Phase 6b — k8s namespace 고아 정리 | [guides/completed/guide_phase6b_ns_cleanup.md](guides/completed/guide_phase6b_ns_cleanup.md) | [specs/spec_phase6b_ns_cleanup.md](specs/spec_phase6b_ns_cleanup.md) | ✅ 완료 |
| Phase 6c — Rocky Linux systemd sandbox 타입 | [guides/completed/guide_phase6c_rocky_systemd.md](guides/completed/guide_phase6c_rocky_systemd.md) | [specs/spec_phase6c_rocky_systemd.md](specs/spec_phase6c_rocky_systemd.md) | ✅ 완료 |
| Phase 6d — etude-linux 커스텀 이미지 도입 | (가이드 미작성, 명세 참고) | [specs/spec_phase6d_etude_linux_image.md](specs/spec_phase6d_etude_linux_image.md) | ✅ 완료 |
| Phase 7 — 사용자 인증 + 진행 추적 | [guides/completed/guide_phase7a_auth_backend.md](guides/completed/guide_phase7a_auth_backend.md) 외 | [specs/spec_phase7_auth.md](specs/spec_phase7_auth.md) | ✅ 완료 |
| Phase 7 — 퀘스트 세트 접근 제어 | [guides/completed/guide_phase7h_quest_access.md](guides/completed/guide_phase7h_quest_access.md) | [specs/spec_phase7_quest_access.md](specs/spec_phase7_quest_access.md) | ✅ 완료 |
| Phase 7i — 본인 비밀번호 변경 | [guides/completed/guide_phase7i_change_password.md](guides/completed/guide_phase7i_change_password.md) | [specs/spec_phase7i_change_password.md](specs/spec_phase7i_change_password.md) | ✅ 완료 |
| Phase 8 — 서버 배포 (OCI) | [guides/completed/guide_phase8_deploy.md](guides/completed/guide_phase8_deploy.md) | [specs/spec_phase8_deploy.md](specs/spec_phase8_deploy.md) | ✅ 완료 |
| Phase 8b — CI/CD (GitHub Actions) | [guides/completed/guide_phase8b_cicd.md](guides/completed/guide_phase8b_cicd.md) | [specs/spec_phase8b_cicd.md](specs/spec_phase8b_cicd.md) | ✅ 완료 |
| Phase 8c — 도메인 + HTTPS + 보안 점검 | [guides/guide_phase8c_https.md](guides/guide_phase8c_https.md) | [specs/spec_phase8c_https.md](specs/spec_phase8c_https.md) | 진행 중 — HTTPS 적용 완료, 자동 갱신 검증 대기 |
| Phase 8d — 실습 세션 보안 (인증 + 컨테이너 소유권) | (명세 확정 후 작성) | [specs/spec_phase8d_session_security.md](specs/spec_phase8d_session_security.md) | 구현 완료, 수동 검증·배포 대기 |
| Phase 9 — 인앱 피드백 | (Phase 7f 구현 완료, 가이드 미작성) | [specs/spec_phase9_feedback.md](specs/spec_phase9_feedback.md) | ✅ 완료 |
| Phase 10 — vcluster 전환 + KLID CMP 현장실습 | [guides/guide_phase10_klid_cmp.md](guides/guide_phase10_klid_cmp.md) | [specs/spec_phase10_klid_cmp.md](specs/spec_phase10_klid_cmp.md) | 대기 |
| Phase 11 — 퀘스트 콘텐츠 확장 2 | (Phase 10 완료 후 작성) | (Phase 10 완료 후 작성) | 대기 |
| Node 테스트 기반 Step 1 — 첫 테스트와 `buildApp()` | [guides/completed/guide_node_testing_01_first_test.md](guides/completed/guide_node_testing_01_first_test.md) | (가이드에 포함) | ✅ 완료 |
| Node 20 → 24 (LTS) 업그레이드 | [guides/guide_node_upgrade_24.md](guides/guide_node_upgrade_24.md) | (가이드에 포함) | 대기 (테스트 Step 1 이후) |

---

## 참고 문서

- `docs/glossary/` — 개념 설명 (async/await, WebSocket, Docker 스트리밍, ESM)
- `docs/etude_dev_plan.md` — 아키텍처 및 전체 개발 계획
- `docs/product/okestro_training_platform.md` — 제품 기획/요구사항
- `docs/research/ai_dlc.md` — AI-DLC 개발 방법론
- `docs/research/ai_efficiency_talk_roadmap.md` — AI 효율 활용법 연구
- `docs/research/k8s_cluster_isolation.md` — k8s 샌드박스 격리 설계 검토 (namespace vs 클러스터 per user)
