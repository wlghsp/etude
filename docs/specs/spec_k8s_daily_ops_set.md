# 명세 — k8s "일상 운영 기본기" 세트 (세트 20)

> 상태: **구현 완료(로컬), 서버 반영 대기** (2026-10-29). 갭 분석([spec_k8s_cka_gap_analysis.md](spec_k8s_cka_gap_analysis.md)의 "기본기 점검")에서 가장 기본인데 비어 있던 명령을 채운다.

## 목표

매일 쓰는 `kubectl` 기본 명령(조회, 접속, 로그, 이벤트, 롤아웃, 라벨 셀렉터)을 한 번씩 직접 쳐 보게 한다. 장애 진단(갭 분석 A)과 워크로드 확장(C) 앞의 전제 기술이다.

## 세트 구성 (12개)

| # | 제목 | 핵심 명령 |
|---|------|-----------|
| 1 | 기본 네임스페이스 확인 | `kubectl config view --minify` |
| 2 | Pod 가 실행 중인 노드 | `get -o wide`, `jsonpath` |
| 3 | Pod IP | `get -o wide`, `jsonpath` |
| 4 | 컨테이너 안에서 명령 실행 | `exec` (`-it`는 안내만) |
| 5 | 로그 마지막 줄 | `logs --tail` (`-f`는 안내만) |
| 6 | 라벨 셀렉터로 조회 | `get -l` |
| 7 | 라벨 셀렉터로 삭제 | `delete -l` |
| 8 | 이벤트로 Pod 이력 확인 | `get events --field-selector` |
| 9 | 배포 이력 확인 | `rollout history` |
| 10 | Deployment 재시작 | `rollout restart` |
| 11 | YAML 로 백업 | `get -o yaml` |
| 12 | 한 번만 실행하는 Pod | `run --restart=Never`, `logs`, `wait` |

## 제외한 것과 이유

- **네임스페이스 생성:** 학습자 권한이 자기 네임스페이스 `edit`뿐이라 불가 ([spec_k8s_session_permissions.md](spec_k8s_session_permissions.md)).
- **`exec -it`, `logs -f`, `kubectl edit`:** 대화형·무한 대기라 비대화형 채점이 불가하다. 힌트로만 안내한다.

## 서버 성능 고려 (OCI Always Free ARM, 4 OCPU / 24GB RAM — 사용자 확인, 문서 [spec_phase8_deploy.md](spec_phase8_deploy.md))

이 서버 한 대가 backend, DB, nginx, k3d 클러스터(+vcluster pool 2개), 모든 학습자 샌드박스를 함께 감당한다.

- 이 세트는 **세션 컨테이너(1GiB 상한)와 nginx/busybox Pod 몇 개**만 쓴다. 퀘스트당 Pod는 최대 5개(대개 1~3개)이고 nginx Pod는 수 MB 수준이라 부담이 작다 (`추정`, 서버에서 측정하지 않았다).
- 이미지는 `nginx`, `busybox` 두 개뿐이다. 기존 세트(6, 12, 13)가 이미 쓰는 이미지라 노드 캐시를 공유한다. 서버 클러스터에서 처음 받을 때만 Docker Hub 익명 한도(429) 영향을 받을 수 있다 ([spec_sandbox_image_pull.md](spec_sandbox_image_pull.md), 보류 중).
- 채점은 API 호출 위주라 CPU 소모가 작다.
- 무거운 쪽은 DinD(1.5GiB, 2 CPU)와 systemd(1GiB)다. 동시 접속이 늘면 새 세트보다 이들을 먼저 점검한다.
- 실제 동시 사용자 수와 메모리 여유는 **`미검증`**이다. 사용자가 늘면 서버에서 `docker stats`, `free -m`으로 먼저 측정한다.

## 수용 조건

- [x] 12개 퀘스트 모두 지문·힌트·풀이·채점 — `검증됨`
- [x] 검증 러너 통과 12/12 (정답 시 통과, 무행동 시 실패) — `검증됨` (로컬 k3d)
- [x] 이미지 변경 없음, 마이그레이션(`2026-10-29_k8s_daily_ops_set.sql`)으로 서버 자동 반영
- [ ] 서버 클러스터에서 동작 확인 (`미검증`)
- [ ] 사용자가 화면에서 몇 개를 풀어 확인
