# 명세 — 스토리지 4차 퀴즈 세트 410·411 (LVM 운영)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-15). [spec_storage_round3.md](spec_storage_round3.md)에 이어 단원 21 끝에 세트를 더한다. 형식·근거 규칙은 [spec_storage_quiz_sets.md](spec_storage_quiz_sets.md)와 같다.

## 구성

| 세트 | 단원 | 제목 | 내용 |
|---|---|---|---|
| 410 | 21 (626, 📐) | LVM 논리 볼륨 다루기 | -L 기본 단위 MB, -l 의 %FREE·%VG, -n 생략 시 lvol#, 스냅샷의 용도, thin pool(--size), lvextend 의 +·-r, lvreduce 의 파일 시스템 선축소·- 접두사, 늘리기 순서 |
| 411 | 21 (627, 🔁) | 볼륨 그룹과 PV 이동 | vgcreate PE 기본 4MiB·변경의 어려움·PV 자동 초기화·LV 수 제한 0, pvmove 의 동작·대상 생략·-n·재개·--abort, vgreduce 와 --all, PV 빼기 순서 |

각 세트 12문제(객관식 9, 빈칸 2, 순서 1).

## 근거 문서

linux.die.net 의 lvcreate·lvextend·lvreduce·vgcreate·pvmove·vgreduce(8) 매뉴얼. 위 내용은 원문에서 직접 확인했다.

## 수용 조건

- [x] 마이그레이션 적용·재실행 안전, `check-content.sh`, `check-migrations.sh`(38개) 통과, 스토리지 분야 display_order·아이콘 중복 없음 — `검증됨`
- [x] 정답 위치 분산, 보기 길이 단서(경고 0) — `검증됨`
- [ ] 화면 확인 (`미검증`)

## 알려진 한계

- 매뉴얼이 오래된 판이라 lvmcache·VDO 등 최신 기능은 다루지 않았다. pvmove 의 온라인(사용 중) 이동 가능 여부와 vgreduce 전 pvmove 필요성은 원문에 없어 뺐다.
- 411 의 "PV 를 VG 에서 빼기" 순서 문제(pvmove → vgreduce → 확인)는 두 문서가 직접 적지 않은 일반 절차다. 410 의 순서 문제도 일반 절차다.
- 샌드박스에서 LVM 을 실제로 구성하지 않아 퀴즈로만 다룬다.
