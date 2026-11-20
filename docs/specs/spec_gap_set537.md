# 명세 — 세트 537 LVM 첫걸음: PV·VG·LV 개념과 확장 절차

> 근거: `docs/research/content_gap_2026-11-19/gap_linux.md` N5. 생성기: `scripts/content-gen/new_sets/set537.py`.
> `linux`, 리눅스, 단원 4, display_order 758. 선행: 파일시스템·마운트 기본, 세트 377·410(LVM 퀴즈)과 겹치지 않게 손으로 출력을 읽는 쪽에 집중.
> 샌드박스(비특권)에는 lvm2·xfsprogs 가 없고 device-mapper 를 쓸 수 없어 `pvcreate`·`lvextend` 를 실행할 수 없다. 그래서 **pvs·vgs·lvs·df -T 출력을 파일로 주고 읽기·계산**하며, 파일시스템 확장은 `resize2fs` 를 **이미지 파일**에 직접 실행한다. (`mkfs.ext4`·`resize2fs`·`e2fsck`·`dumpe2fs` 는 있음)

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 객관식 | PV·VG·LV 3계층 역할 | |
| 2 | 실습 | pvs 출력에서 PFree 가 남은 PV 찾기 | pv_free.txt = /dev/sdc1 |
| 3 | 실습 | lvs 출력에서 한 VG 의 LV 이름 뽑기 | lv_data.txt = data, logs |
| 4 | 객관식 | VG 여유 0 → pvcreate + vgextend 후 lvextend | |
| 5 | 순서 | 만드는 순서 pvcreate → vgcreate → lvcreate → mkfs → mount | |
| 6 | 빈칸 | `lvcreate -n` | |
| 7 | 실습 | vgs 의 VFree 에서 20G 확장 후 남을 여유 계산 | left.txt = 30 |
| 8 | 순서 | 확장 순서 vgs → lvextend → resize2fs → df | |
| 9 | 빈칸 | `lvextend -r` | |
| 10 | 실습 | df -T 에서 ext4/xfs 별 확장 명령 매핑 | grow.txt 4줄 |
| 11 | 실습 | 이미지 파일 128M 로 키우고 e2fsck·resize2fs 로 파일시스템 확장 | 크기·블록 수·fsck |
| 12 | 객관식 | xfs 는 축소 불가(백업·재생성) | |

## 수용 조건

- [x] 문제 12개, 형식 4종(실습 5·객관식 3·빈칸 2·순서 2)
- [x] `verify:quests --set 537` 실습 5개 통과 (정답 통과, 무행동 실패)
- [x] 실제 LVM 장치는 불가능해 출력 파일·이미지 파일로 대체
- [x] `check-content.sh` 통과
- [ ] 정확성 점검(별도 에이전트)에서 차단 없음
