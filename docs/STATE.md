# 현재 상태 (세션 인계용)

> 새 세션은 이 문서와 `docs/research/content_gap_2026-11-19/lessons.md` 를 먼저 읽는다. 작업 묶음이 끝날 때마다 이 문서를 갱신한다. 마지막 갱신: 2026-11-20.

## 지금 하는 일

빈틈 보강: 빈틈 보고서(`docs/research/content_gap_2026-11-19/gap_*.md`)의 항목을 세트로 만들고, 독립 점검(읽기 전용)을 받아 지적을 반영하고, `verify:quests` 로 재검증한다. 방식과 기준은 `reviews/README.md`, 결정과 시행착오는 `lessons.md`.

## 진행 현황

| 구간 | 내용 | 상태 |
|---|---|---|
| 502~556 | 빈틈 세트와 점검 | 커밋됨 (`1f0f1fa`) |
| 557~564 | DB(격리·락·복제·Redis) | 점검·재검증 완료, 미커밋 |
| 565~576 | 네트워크 | 점검·재검증 완료, 미커밋 |
| 577~582 | 스토리지 | 점검·재검증 완료, 미커밋 |
| 583~586 | 가상화·OpenStack 상황집 | 점검·재검증 완료, 미커밋 |
| 587~591 | 네트워크 권장(N14~N19) | 점검 반영·재검증 완료, 미커밋 |
| 592~598 | 스토리지(파일시스템·매체 개념, Ceph·iSCSI·NFS 읽기, Ceph 구조, SMART, LVM·RAID 장애 상황집) | 점검 반영·재검증 완료, 미커밋 |
| 599~602 | 가상화(원리, KVM 호스트 확인, 도메인 XML, 오버커밋 계산) | 점검 반영·재검증 완료, 미커밋 |
| 511 | k8s RBAC | 퀴즈로 대체 완료, 독립 점검 없음, 미커밋 |

## 결정 대기·미해결

- 커밋은 사용자가 요청하면 규칙 문서(`CLAUDE.md`, `docs/STATE.md`), 콘텐츠 세트, 점검 기록 순으로 나눠 제안한다.
- 인프라 변경(`deploy.yml`, `Dockerfile.linux-systemd`, `01_sandbox.sql`+마이그레이션, `guide_*.md`, 546)은 독립 점검(읽기 전용) 결과 전부 PASS, 차단 없음(2026-11-20). 선택 권고: 베이스 이미지 `--pull`·다이제스트 고정, 이미지 크기 실측(가이드의 "약 +20MB"는 미검증), `infra/scripts/setup.sh` 의 사전 pull 목록과 가이드 대조(setup.sh 에 `ubi-init` pull·systemd 빌드 없음), `systemctl is-system-running` 을 채점에 쓰는 세트 유무. 546 생성물은 최신임을 확인.
- 배포 전 확인: Cinder 볼륨 상태값·`quota delete`(샘플 형식), 배포 호스트의 IPv6 루프백(590), ssh 클라이언트 설치 의존(589).
- 502~556 의 명세 파일은 문제 표가 남아 있다(이번에 만든 것만 표를 뺐다). 정리 여부 미결.

## 다음 후보 작업

1. 가상화 남은 세트(`gap_virt.md`): 필수 3 virt-install, 4 cloud-init, 9 스냅샷, 10 브리지 네트워크, 권장 13 qemu-img, 15 스토리지 풀, 16 게스트 에이전트, 18 라이브 마이그레이션, 19 VM vs 컨테이너 등.
2. OpenStack 남은 세트(`gap_openstack.md`): F3 CLI 기초, F15 REST API·토큰, F13 이미지 만들기·변환, F14 서버 이동 절차, F16 Ceph 연계 등.
3. 스토리지는 큰 항목 완료(남은 것: P1-7 일부, P2-3·P2-4 등 선택). 새 스토리지 세트(592~598)는 단원 21·70 맨 뒤에 붙어 있어 커리큘럼 위치 조정이 필요하다(`UNIT_ORDER` 에 단원 21·70 미등록).
4. 네트워크 선택 항목: N20 상황집(L2·MTU·성능), N21 VXLAN·WireGuard, N22 iperf3.
5. 새 세트의 화면 확인(단원 순서, 모바일 폭). 단원 안 순서는 `reorder_gap_sets.py` 의 `UNIT_ORDER` 로 조정한다.

## 알아 둘 것

- 검증: `cd backend && DOCKER_HOST=unix:///Users/jihochoi/.colima/default/docker.sock npm run verify:quests -- --set N,...`, 콘텐츠 점검: `bash scripts/check-content.sh`.
- 세트 재생성: `python3 scripts/content-gen/emit_new_sets.py --rewrite N...`, 순서 반영: `python3 scripts/content-gen/reorder_gap_sets.py`.
- 비특권 샌드박스에서 못 하는 영역은 샘플 출력 읽기로 만든다(`lessons.md` 1장).
- 민감 파일(`.env*`, `backend/db/04_users.sql`, `backend/db/users/users.txt`, Terraform tfvars·state)은 출력·커밋하지 않는다.
