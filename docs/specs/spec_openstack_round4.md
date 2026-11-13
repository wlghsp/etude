# 명세 — OpenStack 4차 퀴즈 세트 388·389

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-13). [spec_openstack_round3.md](spec_openstack_round3.md)에 이어 기존 단원 끝에 세트를 더한다. 형식·근거 규칙은 [spec_storage_quiz_sets.md](spec_storage_quiz_sets.md)와 같다.

## 구성

| 세트 | 단원 | 제목 | 내용 |
|---|---|---|---|
| 388 | 39 스토리지와 이미지 (끝) | Glance 심화 | 가져오기 방식 4가지(glance-direct·web-download·glance-download·copy-image), web-download=원격 URL, URL 허용·차단 목록(둘 다면 허용 목록 적용), deactivated·killed 상태, 이미지 공유(멤버 pending→accepted, 소유자만 멤버 생성, 본인만 상태 변경, 기본 목록은 accepted 만), 공통 속성 os_distro |
| 389 | 40 인증과 운영 (끝) | Nova 장애 해석과 복구 | `/var/log/nova`, 흔한 원인(네트워크·인증 정보·32비트 이미지), KVM 플래그(vmx/svm)와 BUILD→ERROR, 볼륨 재연결 실패(장치 이름), 콘솔 로그가 빌 때 커널 인자, 멈춘 인스턴스 `reset-state`, rescue 기본·안정 장치 모드, 병렬 생성의 어피니티 위반과 `--min` |

각 세트 12문제(객관식 9, 빈칸 2, 순서 1). 단원 끝에 놓으면서 뒤 세트의 `display_order` 를 밀었다.

## 근거 문서

docs.openstack.org 의 Glance(interoperable-image-import, statuses, glanceapi, common-image-properties), Nova(support-compute, user/rescue, admin/troubleshooting/affinity-policy-violated). 위 내용은 원문에서 직접 확인했다.

## 수용 조건

- [x] 마이그레이션 적용·재실행 안전, `check-content.sh`, `check-migrations.sh`(16개) 통과, 같은 분야 display_order 중복 없음 — `검증됨`
- [x] 정답 위치 분산, 보기 길이 단서 점검(경고 0) — `검증됨`
- [ ] 화면 확인 (`미검증`)

## 알려진 한계

- 389 순서 문제(ERROR 인스턴스 살피기)는 문서가 한 줄로 제시한 절차가 아니라 일반적인 큰 줄기다(`server show` 의 fault 확인 → 로그 → 원인 수정 → 재시도).
- Glance 문서 일부 설명(공유 멤버)은 Images API v1 예시 URL 이 섞인 페이지에서 가져온 것이며 멤버 상태 규칙은 v2 에서도 같은 의미로 쓰인다.
