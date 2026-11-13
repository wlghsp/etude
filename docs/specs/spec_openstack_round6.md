# 명세 — Heat 심화 392, Ceph 운영 393

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-13). [spec_openstack_round5.md](spec_openstack_round5.md)에 이어 OpenStack 한 세트와 스토리지 한 세트를 더한다. 형식·근거 규칙은 [spec_storage_quiz_sets.md](spec_storage_quiz_sets.md)와 같다.

## 구성

| 세트 | 분야·단원 | 제목 | 내용 |
|---|---|---|---|
| 392 | OpenStack, 단원 41 끝 (721) | Heat 심화 | resources 필수, 파라미터 타입 5종, hidden·immutable, range(경계 포함)·custom_constraint, 내장 함수는 properties·outputs 에서만, deletion_policy(Delete·Retain·Snapshot), resource_registry 와 환경 파일(-e), get_param·get_resource |
| 393 | 스토리지, 단원 21 끝 (623) | Ceph 운영 | OSD up/down·in/out, mon_osd_down_out_interval 600초와 noout, down+in 은 문제, PG 상태(active+clean·degraded·stale), 풀 size(기본 3)·min_size, mon_allow_pool_delete, ceph osd tree, down OSD 복구 순서 |

각 세트 12문제(객관식 9, 빈칸 2, 순서 1).

## 근거 문서

Heat(template_guide hot_spec·composition), Ceph(rados/operations monitoring-osd-pg·pools). 위 내용은 원문에서 직접 확인했다.

## 수용 조건

- [x] 마이그레이션 적용·재실행 안전, `check-content.sh`, `check-migrations.sh`(20개) 통과 — `검증됨`
- [x] 정답 위치 분산, 보기 길이 단서(경고 0), 분야 내 `display_order`·아이콘 중복 없음 — `검증됨`
- [ ] 화면 확인 (`미검증`)

## 알려진 한계

- HOT 문서가 `heat_template_version` 을 "필수"라고 명시하지 않아 필수 섹션 문제는 resources 만 묻는다. ResourceGroup·parameter_defaults 는 조합 문서에 없어 뺐다.
- Ceph 문서에서 nearfull(85%)·full(95%) 비율 값은 확인되지 않아 뺐다(backfillfull 기본 90% 만 확인). `ceph health detail` 도 뺐다.
- 392·393 의 순서 문제와 `noout` 사용 맥락("점검 시 일시 정지")은 문서 설명을 이은 일반 절차다.
