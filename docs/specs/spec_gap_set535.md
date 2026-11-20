# 명세 — 세트 535 파일시스템 만들고 점검하기: mkfs·마운트 개념

> 근거: `docs/research/content_gap_2026-11-19/gap_linux.md` N2. 생성기: `scripts/content-gen/new_sets/set535.py`.
> `linux`, 리눅스, 단원 4, display_order 756. 534(파티션)와 독립이며 사전지식으로 가정하지 않는다.
> 샌드박스(비특권 컨테이너)는 `mount`·`losetup` 이 막혀 있고 `mkfs.xfs` 가 없다. **직접 확인한 것**: `truncate`, `mkfs.ext4 -F`, `tune2fs -L`, `blkid`, `dumpe2fs -h`, `e2fsck -fn` 은 이미지 파일에 대해 동작한다. mount·umount·busy 오류·df 확인·xfs 는 출력 읽기(객관식·순서·빈칸)로 대체한다.

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 객관식 | 파일시스템이란, 새 디스크는 mkfs 가 먼저 | |
| 2 | 실습 | truncate 로 16M 이미지 파일 만들기 | 크기 16777216 |
| 3 | 객관식 | mkfs.ext4 -F (일반 파일 확인 건너뜀) | |
| 4 | 실습 | mkfs.ext4 -F 로 ext4 만들기 | blkid TYPE=ext4 |
| 5 | 실습 | tune2fs -L 로 레이블 붙이기 | LABEL=backup |
| 6 | 실습 | blkid 로 UUID 값만 저장 | uuid.txt |
| 7 | 실습 | dumpe2fs -h 로 블록 크기·개수 읽기 | 1024, 8192 |
| 8 | 실습 | e2fsck -f -n 점검 출력 저장 | Pass 5, 요약 줄 |
| 9 | 순서 | 준비 → mkfs → mount → 사용 → umount | |
| 10 | 빈칸 | mount 장치 마운트지점 | |
| 11 | 객관식 | target is busy 해석(fuser 출력) | |
| 12 | 객관식 | df -hT 읽기(형식·남은 용량) | |

## 수용 조건

- [x] `verify:quests --set 535` 실습 6개 통과 (정답 통과, 무행동 실패)
- [ ] 정확성 점검(별도 에이전트)에서 차단 없음
- [ ] 화면 확인 (사용자)
