# 명세 — 세트 534 디스크와 파티션 읽기·나누기

> 근거: `docs/research/content_gap_2026-11-19/gap_linux.md` N1(블록 장치·파티션 읽기), N4(파티션 나누기 입문). 생성기: `scripts/content-gen/new_sets/set534.py`.
> `linux`, 리눅스, 단원 4, display_order 755. 선행: 226(df/du), 516(blkid 출력 읽기).
> 샌드박스에는 실제 디스크·`mount`·`losetup` 이 없고 `fdisk`·`sfdisk`·`parted`·`file` 도 없다. 있는 것: `truncate`, `mkfs.ext3/ext4`, `blkid`, `partx`, `xxd`, `perl`. 그래서 **이미지 파일**을 대상으로 만들기·포맷·읽기는 직접 하고(파티션 테이블이 든 이미지는 setup 이 perl 로 만든다), fdisk/sfdisk/parted 로 나누는 흐름은 읽기형(객관식·빈칸·순서)으로 대체했다.

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 객관식 | 장치 이름 규칙: nvme0n1p2 | |
| 2 | 실습 | lsblk 출력 읽기: 파티션 없는 디스크, 마운트 안 된 파티션 | nopart.txt = vdb, unmounted.txt = nvme0n1p1 |
| 3 | 빈칸 | vdb / sdb3 / nvme0n1p3 이름 만들기 | |
| 4 | 실습 | truncate 로 64MiB 이미지 만들기 | 크기 67108864 |
| 5 | 실습 | mkfs.ext4 -L 로 포맷 | blkid TYPE=ext4, LABEL=backup |
| 6 | 실습 | blkid 로 UUID·TYPE 읽기 (이미지는 ext3, 매번 UUID 다름) | uuid.txt, fstype.txt |
| 7 | 객관식 | MBR 4개·2TB 한계, 4TB 는 GPT | |
| 8 | 실습 | blkid -p PTTYPE 로 GPT 이미지 구분 | gpt_image.txt = b.img |
| 9 | 실습 | partx -s 로 파티션 표 읽기(가장 큰 파티션) | big_nr=3, big_sectors=79872 |
| 10 | 순서 | fdisk 대화 흐름(g → n → p → w) | |
| 11 | 객관식 | 파티션이 안 보일 때 partprobe | |

## 수용 조건

- [x] `verify:quests --set 534` 실습 6개 통과 (정답 통과, 무행동 실패)
- [x] 형식 4종(실습·객관식·빈칸·순서), 실습 6/11
- [x] 현장 정보 없음
- [ ] 정확성 점검(별도 에이전트)
- [ ] 화면 확인 (사용자)
