# 명세 — 스토리지 퀴즈 세트 376·377

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-13). 분야 분할 후 비어 있던 스토리지 분야를 채우는 첫 두 세트. 근거: [spec_infra_category_split.md](spec_infra_category_split.md).

## 목적

스토리지 분야가 세트 1개(61)뿐이라 개념 지도부터 채운다. 이 환경(`etude-linux`)은 권한이 없어 루프 장치·`mdadm`·LVM 을 실제로 돌릴 수 없으므로(코드상 확인: `01_sandbox.sql` 에 privileged 샌드박스 없음) **객관식·빈칸·순서 퀴즈**로 만든다. 실습형은 권한 있는 샌드박스가 생기면 후속.

## 세트

| 세트 | 제목 | 내용 |
|---|---|---|
| 376 | 스토리지 개념 지도: 블록·파일·오브젝트, NFS·iSCSI, RAID | 저장 방식 3종, NFS(hard 기본·포트 2049), iSCSI(타깃·이니시에이터), RAID 0·1·5, 용량 계산, RAID≠백업, 고장 복구 순서 |
| 377 | LVM 과 Ceph 구조: PV·VG·LV 와 OSD·MON·쿼럼 | PV→VG→LV, vgextend·lvextend(-r)·pvmove, Ceph 3종 저장, OSD·MON 역할, 쿼럼(과반수), 복제 3벌, RGW(S3·Swift) |

각 세트 12문제(객관식 9, 빈칸 2, 순서 1). 단원 21 `스토리지 기초` 끝, 61 → 376 → 377 순서.

## 근거 문서 (문제마다 `docs` 에 링크)

Ceph 용어집·풀 문서, 커널 md 문서, nfs(5), RFC 7143, lvm(8)·lvextend(8)(linux.die.net), 표준 RAID 레벨(위키백과). 원문에서 직접 확인한 것: 모니터 최소 3대와 쿼럼=과반수, OSD=Object Storage Daemon, RGW=S3+Swift, 복제 풀에서 손실 없이 견디는 OSD 수=복제본 수−1, NFS `hard` 기본(무한 재시도)·포트 2049, iSCSI 타깃·이니시에이터·포트 3260, lvm 명령 설명, lvextend `-r`, md raid5/6 패리티 경고. RAID 레벨별 허용 고장 수·용량 공식은 일반 지식이며 위키백과로 대조한다.

## 수용 조건

- [x] 두 세트 모두 마이그레이션 적용·재실행 안전 — `검증됨` (두 번째 실행 0개 적용)
- [x] `check-content.sh`, `check-migrations.sh` 통과 — `검증됨`
- [x] 정답 위치 분산, 정답이 유독 길지 않게 보기 길이 조정(생성기가 경고) — `검증됨`
- [ ] 화면 확인 (`미검증`)
