# 명세 — 가상화 3차 퀴즈 세트 406·407 (CPU 설정, 메모리·virtiofs)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-14). [spec_virt_round2.md](spec_virt_round2.md)에 이어 단원 48 `가상화 기초` 끝에 세트를 더한다. 형식·근거 규칙은 [spec_storage_quiz_sets.md](spec_storage_quiz_sets.md)와 같다.

## 구성

| 세트 | 단원 | 제목 | 내용 |
|---|---|---|---|
| 406 | 48 (631) | libvirt CPU 설정 | vcpu current·hotpluggable, vcpupin 기본(전체 CPU), emulatorpin(vCPU·IOThread 제외), shares(상대값)·period(μs, 1000~1000000)·quota(음수=무한), cpu mode 기본 custom, host-passthrough 의 마이그레이션 위험, placement 기본 static, vCPU 고정 순서 |
| 407 | 48 (632) | libvirt 메모리와 공유 | memory(부팅 최대)·currentMemory(생략 시 memory)·maxMemory(핫플러그), hugepages, numatune 기본 strict, virtiofs 정의·shared 메모리 전제·마운트 태그·스냅샷 제약, `mount -t virtiofs`, 공유 순서 |

각 세트 12문제(객관식 9, 빈칸 2, 순서 1).

## 근거 문서

libvirt.org 의 formatdomain(앞 100KB 범위), kbase/virtiofs. 위 내용은 원문에서 직접 확인했다.

## 수용 조건

- [x] 마이그레이션 적용·재실행 안전, `check-content.sh`, `check-migrations.sh`(34개) 통과, 가상화 분야 display_order 중복 없음 — `검증됨`
- [x] 정답 위치 분산, 보기 길이 단서(경고 0) — `검증됨`
- [ ] 화면 확인 (`미검증`)

## 알려진 한계

- formatdomain 은 415KB 중 앞 100KB 만 읽었다. `<memballoon>` 장치 설명은 읽지 못해 뺐다. 9p 와의 비교는 virtiofs 문서에 없어 뺐다.
- `maximum` cpu mode 는 host-passthrough 와 사실상 같다고 문서가 설명해 빈칸 보기에서 뺐다(정답이 겹칠 수 있어서).
- 두 순서 문제는 문서 설명을 이은 큰 줄기다. 실제 CPU 고정·virtiofs 는 샌드박스에 libvirt 가 없어 퀴즈로만 다룬다.
