# 명세 — OpenStack 3차 퀴즈 세트 386·387

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-13). [spec_openstack_round2.md](spec_openstack_round2.md)에 이어 기존 단원 끝에 심화 세트를 더한다. 형식·근거 규칙은 [spec_storage_quiz_sets.md](spec_storage_quiz_sets.md)와 같다.

## 구성

| 세트 | 단원 | 제목 | 내용 |
|---|---|---|---|
| 386 | 39 스토리지와 이미지 (끝) | Cinder 심화 | 멀티어태치(볼륨 타입 `multiattach=<is> True`, 클러스터 파일시스템 책임, 보조 연결 RW, 부팅 볼륨 정책), 볼륨 마이그레이션(관리자 기능, 붙은 볼륨은 Compute 가 복사·libvirt 만), 백업(기본 전체·`--incremental`·붙은 볼륨 `--force`=충돌 일관성), `cinder get-pools` |
| 387 | 40 인증과 운영 (끝) | Keystone 심화 | Fernet(저장 불필요·기본 공급자), 토큰 범위(프로젝트·도메인·시스템 중 하나), 키 상태(기본 하나·보조 복호화만·대기), 키 회전과 다중 노드, 애플리케이션 자격증명(비밀번호 대신 ID+비밀, 역할 부분집합), 연합(IdP, SAML 2.0·OpenID Connect) |

각 세트 12문제(객관식 9, 빈칸 2, 순서 1). 단원 끝에 놓으면서 뒤 세트의 `display_order` 를 밀었다.

## 근거 문서

docs.openstack.org 의 Cinder(volume-multiattach, volume-migration, volume-backups), Keystone(tokens-overview, fernet-token-faq, user/application_credentials, federation/introduction). 위 내용은 모두 원문에서 직접 확인했다.

## 수용 조건

- [x] 마이그레이션 적용·재실행 안전, `check-content.sh`, `check-migrations.sh`(14개) 통과, 같은 분야 display_order 중복 없음 — `검증됨`
- [x] 정답 위치 분산, 보기 길이 단서 점검(경고 0) — `검증됨`
- [ ] 화면 확인 (`미검증`)

## 알려진 한계

- 387 순서 문제(Fernet 키 회전)의 "퍼뜨리기" 단계 위치는 문서가 키 상태(대기→기본→보조)를 설명한 것을 이은 큰 줄기이며, 단계 순서를 한 문장으로 못 박은 문서는 없다.
- 386·387 각 보기에는 문서에 없는 그럴듯한 오답을 썼다(오답이 문서의 사실을 반대로 말하지 않는지는 작성 때 대조).
