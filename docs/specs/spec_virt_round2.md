# 명세 — 가상화 2차 퀴즈 세트 394·395

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-13). [spec_virt_quiz_sets.md](spec_virt_quiz_sets.md)에 이어 단원 48 `가상화 기초` 끝에 세트를 더한다. 형식·근거 규칙은 [spec_storage_quiz_sets.md](spec_storage_quiz_sets.md)와 같다.

## 구성

| 세트 | 단원 | 제목 | 내용 |
|---|---|---|---|
| 394 | 48 가상화 기초 (629) | VM 상태 보존 | managed save(메모리, libvirt 관리, 게스트 정지)와 save(사용자 관리), 스냅샷이 담는 것(메모리·디스크·둘 다), 체크포인트(상태 없이 변경 추적), 백업(디스크만, 메모리 없음), FSFreeze 와 게스트 에이전트, 메모리 없는 캡처=전원 차단과 비슷, 오버레이, qcow2 백킹 형식, `-F`, DISK_ONLY |
| 395 | 48 가상화 기초 (630) | libvirt 마이그레이션 | p2p 제어, 터널링(암호화 가능, 일부 기능 제한), 오프라인(비활성 정의), 기본은 설정 불변, --undefinesource·--persistent, 공유 스토리지 기본 가정, --copy-storage-all·inc(최상위 이미지, 도착지 이미지 사전 생성), qemu+ssh URI |

각 세트 12문제(객관식 9, 빈칸 2, 순서 1).

## 근거 문서

libvirt.org 의 kbase/domainstatecapture, kbase/backing_chains, migration. 위 내용은 원문에서 직접 확인했다.

## 수용 조건

- [x] 마이그레이션 적용·재실행 안전, `check-content.sh`, `check-migrations.sh`(22개) 통과, 가상화 분야 display_order 중복 없음 — `검증됨`
- [x] 정답 위치 분산, 보기 길이 단서 점검(경고 0) — `검증됨`
- [ ] 화면 확인 (`미검증`)

## 알려진 한계

- 마이그레이션 문서에 `--live`, CPU 호환성 검사, 포트 범위(49152–49215)가 없어 뺐다. 백킹 체인 문서에 blockcommit·blockpull·외부 스냅샷 설명이 없어 뺐다.
- 두 세트의 순서 문제(동결→캡처→해제, 비공유 디스크 이동)는 문서 설명을 이은 큰 줄기다. `--copy-storage-all` 은 문서상 저장 풀 경로면 도착지 이미지 사전 생성이 필요 없어 순서 문제에는 inc 를 썼다.
- 실제 마이그레이션·스냅샷은 샌드박스에 libvirt 가 없어 실습 세트가 아니라 퀴즈로만 다룬다.
