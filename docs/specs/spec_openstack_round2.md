# 명세 — OpenStack 2차 퀴즈 세트 384·385

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-13). 1차(353~364, [spec_openstack_category.md](spec_openstack_category.md))가 기초 위주였고, 이번은 기존 단원 안에서 한 단계 깊게 간다. 형식·근거 규칙은 [spec_storage_quiz_sets.md](spec_storage_quiz_sets.md)와 같다.

## 구성

| 세트 | 단원 | 제목 | 내용 |
|---|---|---|---|
| 384 | 37 인스턴스 (끝) | Nova 스케줄링과 인스턴스 이동 | 스케줄러 필터·가중치, Placement(리소스 공급자·인벤토리), 호스트 집합, 가용 영역(영역 간 이동 불가), 서버 그룹 affinity/anti-affinity, resize·VERIFY_RESIZE, 블록 마이그레이션, evacuate 전제 |
| 385 | 38 네트워크 (끝) | Neutron 구조 깊게 | flat·vlan·vxlan·gre, 오버레이를 쓰는 이유, ML2 타입/메커니즘 드라이버, 플러그인은 하나, L3 에이전트 장애 영향, source NAT·floating IP, 프로바이더 네트워크 관리 권한 |

각 세트 12문제(객관식 9, 빈칸 2, 순서 1). 각 단원 끝에 놓으면서 뒤 세트의 `display_order` 를 하나씩 밀었다.

## 근거 문서

docs.openstack.org 의 Nova(scheduling, aggregates, availability-zones, server-groups, resize, live-migration-usage, evacuate), Placement, Neutron(intro-os-networking, config-ml2). 원문에서 확인: 필터는 이진·가중치 순위, 호스트 집합 메타데이터와 플레이버 extra spec 매핑, 호스트는 하나의 가용 영역에만 속함, 영역 간 이동 불가, affinity/anti-affinity 정의와 "HA 로 의존 말 것", VERIFY_RESIZE→confirm/revert, `--block-migration`, evacuate 시 원 호스트가 동작 중이면 실패, flat·VLAN·GRE/VXLAN 설명, 오버레이 이유, 타입/메커니즘 드라이버 정의, 플러그인은 한 번에 하나, L3 에이전트 장애 영향, source NAT/floating IP, 프로바이더 네트워크는 기본 관리자만.

## 수용 조건

- [x] 마이그레이션 적용·재실행 안전, `check-content.sh`, `check-migrations.sh`(12개) 통과, 같은 분야 display_order 중복 없음 — `검증됨`
- [x] 정답 위치 분산, 보기 길이 단서 점검 — `검증됨`
- [ ] 화면 확인 (`미검증`)

## 알려진 한계

- 385 순서 문제(네트워크 → 서브넷 → 라우터 → 서브넷 연결·게이트웨이)의 세부 명령 순서는 일반적인 절차이며 문서의 한 줄로 직접 확인한 것은 아니다.
