# 명세 — 가상화 퀴즈 세트 380·381

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-13). 형식·근거 규칙은 [spec_storage_quiz_sets.md](spec_storage_quiz_sets.md)와 같다.

## 구성

새 단원 48 `가상화 기초`(display_order 5)를 만들어 기존 단원 16 `용어 지도`(10) 앞에 둔다. 구조를 익힌 뒤 운영 명령으로, 그 뒤에 용어 지도(55)로 간다.

| 세트 | 제목 | 내용 |
|---|---|---|
| 380 | 가상화 구조: KVM·QEMU·libvirt 와 디스크 이미지 | KVM=QEMU 가속기, TCG, KVM API(ioctl), libvirt·도메인, virtio, qcow2·VM 스냅샷, raw 이미지 공간, 비공유 디스크 마이그레이션, `virsh list`·`shutdown` |
| 381 | virsh 로 VM 운영하기 | `list` 범위, shutdown↔destroy, 정상 종료가 안 끝나는 이유, suspend·resume, define↔start, undefine 과 스토리지, autostart, save, console, domstate |

각 세트 12문제(객관식 9, 빈칸 2, 순서 1). 실습형이 아닌 이유: 샌드박스에서 KVM·libvirt 를 실제로 돌릴 수 없다.

## 근거 문서

virsh 매뉴얼(libvirt.org), QEMU 시스템 소개·디스크 이미지, 커널 KVM API, libvirt virtio·마이그레이션 문서. 원문에서 확인: virsh 각 명령 설명(list 기본 범위, shutdown 협조, destroy=전원 뽑기·스토리지 안 지움, suspend=paused, define=등록만, autostart, save=RAM, console, domstate), QEMU 가속기 표와 TCG, VM 스냅샷의 qcow2 조건, raw 이미지의 구멍, KVM ioctl 구조, 비공유 디스크 마이그레이션 플래그.

## 수용 조건

- [x] 마이그레이션 적용·재실행 안전, `check-content.sh`, `check-migrations.sh`(8개) 통과 — `검증됨`
- [x] 정답 위치 분산, 보기 길이 단서 점검 — `검증됨`
- [ ] 화면 확인 (`미검증`)

## 알려진 한계

- `undefine` 이 옵션 없이는 스토리지를 지우지 않는다는 점은 문서의 옵션 문법에서 읽은 것이다(직접 실행해 확인하지 않음). 공유 스토리지 마이그레이션 시 "메모리와 상태만 옮긴다"는 일반 지식이다.
