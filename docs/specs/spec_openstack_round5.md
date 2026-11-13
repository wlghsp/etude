# 명세 — OpenStack 5차 퀴즈 세트 390·391

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-13). [spec_openstack_round4.md](spec_openstack_round4.md)에 이어 심화가 없던 두 단원(36 서비스 지도, 41 오브젝트와 자동화)에 세트를 더한다. 형식·근거 규칙은 [spec_storage_quiz_sets.md](spec_storage_quiz_sets.md)와 같다.

## 구성

| 세트 | 단원 | 제목 | 내용 |
|---|---|---|---|
| 390 | 36 서비스 지도 (끝) | 서비스 지도 깊게 | Nova API·스케줄러·컴퓨트·콘덕터의 역할, 컴퓨트의 DB 접근은 RPC 로 콘덕터가 대신, oslo.messaging, 셀(샤딩, 최소 하나), Placement 의 자원 공급자·인벤토리·트레이트, 서버 생성 요청 흐름 |
| 391 | 41 오브젝트와 자동화 (끝) | Swift 깊게 | 링(파티션 파워 2^P, 레플리카≤장치, 가중치, 링 빌더·서버의 재로드, 빌더 파일 분실), 프록시의 핸드오프, 5GB 제한, DLO·SLO, X-Delete-After, 이레이저 코딩 성격 |

각 세트 12문제(객관식 9, 빈칸 2, 순서 1). 390 은 단원 36 끝(display_order 703, 뒤 16개 이동), 391 은 단원 41 끝(720).

## 근거 문서

docs.openstack.org 의 Nova(admin/architecture), Placement(user), Swift(overview_ring, overview_architecture, overview_large_objects, overview_expiring_objects, overview_erasure_code). 위 내용은 원문에서 직접 확인했다.

## 수용 조건

- [x] 마이그레이션 적용·재실행 안전, `check-content.sh`, `check-migrations.sh`(18개) 통과 — `검증됨`
- [x] 정답 위치 분산, 보기 길이 단서 점검(경고 0), 분야 내 아이콘 중복 없음 — `검증됨`
- [ ] 화면 확인 (`미검증`)

## 알려진 한계

- 서비스 이름(nova-api 등)은 아키텍처 문서에 직접 나오지 않아 "API·스케줄러·컴퓨트·콘덕터 구성요소"로만 물었다.
- 390 순서 문제(서버 생성 흐름)는 Placement·아키텍처 문서의 설명을 이은 큰 줄기이며 콘덕터의 중간 조율은 생략했다. 391 SLO 순서 문제도 문서 내용을 이은 큰 줄기다.
- Placement 는 resource class 예시로 문서가 VCPU 만 든다. 문제는 trait·inventory 개념만 묻는다.
