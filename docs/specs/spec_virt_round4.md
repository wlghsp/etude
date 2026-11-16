# 명세 — 가상화 4차 퀴즈 세트 416·417 (libvirt 네트워크, 스토리지 풀)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-18). [spec_virt_round3.md](spec_virt_round3.md)에 이어 단원 48 끝에 세트를 더한다. 형식·근거 규칙은 [spec_storage_quiz_sets.md](spec_storage_quiz_sets.md)와 같다.

## 구성

| 세트 | 단원 | 제목 | 내용 |
|---|---|---|---|
| 416 | 48 (633, 🌉) | libvirt 가상 네트워크 | forward 에 mode 없으면 nat, forward 요소 없으면 격리, nat·route(돌아오는 경로 필요)·open(방화벽 규칙 없음)·bridge(stp·delay 불가)·passthrough(PCI 아님)·hostdev(SR-IOV VF), default 네트워크(virbr0, 192.168.122.0/24, DHCP .2~.254), dhcp range start, 격리 네트워크 정의 순서 |
| 417 | 48 (634, 🏊) | libvirt 스토리지 풀 | 풀과 볼륨, dir·fs·netfs(auto)·logical(LVM)·disk(파티션)·iscsi(서버에서 미리 할당)·rbd(raw 만, 커널 RBD 미지원), dir 풀 포맷 raw, 풀 유형·rbd 포맷 빈칸, iSCSI 풀 사용 순서 |

각 세트 12문제(객관식 9, 빈칸 2, 순서 1).

## 근거 문서

libvirt.org 의 네트워크 XML(formatnetwork), 스토리지 풀(storage) 페이지. 위 내용은 원문에서 직접 확인했다.

## 수용 조건

- [x] 마이그레이션 적용·재실행 안전, `check-content.sh`, `check-migrations.sh`(44개) 통과, 가상화 분야 display_order·아이콘 중복 없음 — `검증됨`
- [x] 정답 위치 분산, 보기 길이 단서(경고 0) — `검증됨`
- [ ] 화면 확인 (`미검증`)

## 알려진 한계

- 스토리지 풀 문서는 target path 의 일반 정의를 담지 않고(예시만), 기본 위치 /var/lib/libvirt/images 도 원문에 없어(예시는 /var/lib/virt/images) 뺐다. 네트워크의 dnsmasq 네임스페이스(지원 보장 없음)와 IPv6 세부는 다루지 않았다.
- 두 순서 문제는 문서 설명을 이은 일반 절차다. 샌드박스에 libvirt 가 없어 퀴즈로만 다룬다.
