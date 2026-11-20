# 명세 — 세트 516 디스크 문제 상황집: 가득 참, inode, 삭제했는데 안 줄 때, 읽기 전용

> 근거: `docs/research/content_gap_2026-11-19/gap_linux.md` N16(상황 S2·S3·S4). 생성기: `scripts/content-gen/new_sets/set516.py`.
> `linux`, 리눅스, 단원 4, display_order 737. 선행: 16(큰 파일·로그 정리), 226(df·du·find 기본·inode 소개).
> 샌드박스 컨테이너는 `mount`·`losetup`·`lsof` 가 없다. 그래서 **재현 가능한 것**(inode 고갈 폴더, 열린 로그, 삭제된 열린 파일)은 직접 고치고, **재현 불가능한 것**(Read-only file system, fstab 오류)은 출력 파일(`/tmp/report/`, `/tmp/lab/fstab`)을 읽고 해석·수정하는 문제로 대체한다.

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 객관식 | 용량은 남았는데 No space left → `df -i` | |
| 2 | 실습 | df -h 출력에서 용량 가득 찬 마운트 지점 읽기 | full.txt = /data |
| 3 | 실습 | df -i 출력에서 inode 가득 찬 마운트 지점 읽기 | inode_full.txt = /var |
| 4 | 실습 | 파일 12만 개 폴더 찾기, `Argument list too long` 없이 비우기(find -delete) | culprit.txt, 폴더 비움, 다른 폴더 유지 |
| 5 | 실습 | 쓰는 중인 로그는 지우지 않고 비우기(truncate) | 같은 inode·1MB 미만·프로세스 생존 |
| 6 | 실습 | 삭제됐지만 열려 있는 파일을 `/proc/PID/fd` 로 찾기 | pid.txt, fd.txt |
| 7 | 실습 | 프로세스를 죽이지 않고 `/proc/PID/fd/N` 비워 공간 회수 | 프로세스 생존·크기 1MB 미만 |
| 8 | 실습 | dmesg 에서 Remounting read-only 의 장치·mounts 에서 마운트 지점 읽기 | dev.txt = sdb1, mp.txt = /data |
| 9 | 객관식 | 읽기 전용이 된 디스크: 원인 확인 → 언마운트 → fsck | |
| 10 | 실습 | fstab 오기(형식 오타, UUID 오타)를 blkid 와 대조해 수정 | 두 줄 수정·나머지 유지 |
| 11 | 빈칸 | 디스크가 없어도 부팅을 계속하는 옵션 `nofail` | |
| 12 | 순서 | 디스크가 찼을 때 점검 순서 | |

## 수용 조건

- [x] `verify:quests --set 516` 실습 8개 통과 (정답 통과, 무행동 실패)
- [x] `check-content.sh` 통과
- [ ] 정확성 점검(별도 에이전트)에서 차단 없음
- [ ] 화면 확인 (사용자)
