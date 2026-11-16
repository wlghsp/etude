# 명세 — OpenStack 7차 퀴즈 세트 412·413 (Nova 플레이버, CPU 고정·NUMA)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-16). [spec_openstack_round6.md](spec_openstack_round6.md)에 이어 단원 37 `인스턴스` 끝에 세트를 더한다(뒤 세트 15개의 display_order 는 밀렸다). 형식·근거 규칙은 [spec_storage_quiz_sets.md](spec_storage_quiz_sets.md)와 같다.

## 구성

| 세트 | 단원 | 제목 | 내용 |
|---|---|---|---|
| 412 | 37 (707, 🏷️) | Nova 플레이버 깊게 | 생성 때 정하는 속성, disk 0, 기본 플레이버 제거(Newton), extra specs 와 quota 키, flavor set --project, description 만 수정 가능(2.55), 기존 인스턴스는 갱신되지 않음, resize 는 cold migration, 비공개 플레이버 준비 순서 |
| 413 | 37 (708, 🧲) | Nova CPU 고정과 NUMA | cpu_policy 세 값·기본 shared, dedicated 의미, thread policy 기본 prefer, numa_nodes 기본(떠다님)·1, 소켓·코어·스레드 곱, 기본 토폴로지, cpu_dedicated_set(PCPU)·cpu_shared_set(VCPU), 오버커밋(8.0 대 1.0), 고정 준비 순서 |

각 세트 12문제(객관식 9, 빈칸 2, 순서 1).

## 근거 문서

Nova 관리자 문서의 Flavors, CPU topologies 페이지. 위 내용은 원문에서 직접 확인했다.

## 수용 조건

- [x] 마이그레이션 적용·재실행 안전, `check-content.sh`, `check-migrations.sh`(40개) 통과, OpenStack 분야 display_order·아이콘 중복 없음 — `검증됨`
- [x] 정답 위치 분산, 보기 길이 단서(경고 0) — `검증됨`
- [ ] 화면 확인 (`미검증`)

## 알려진 한계

- 플레이버 문서는 hw:cpu_policy·hw:mem_page_size·hw:numa_nodes·hw_rng 의 상세를 담지 않아(User Guide 참조) 412 에서 뺐다. is_public 의 기본값, 기본 플레이버의 현재 상태도 원문에 없어 뺐다.
- 413 은 CPU 토폴로지 문서의 libvirt/KVM 기준 내용이며, 같은 호스트에서 고정·비고정 혼합의 일반 허용 여부는 원문에 없어 뺐다.
- 두 순서 문제는 문서 설명을 이은 일반 절차다. 샌드박스에서 실제 클라우드를 띄우지 않아 퀴즈로만 다룬다.
