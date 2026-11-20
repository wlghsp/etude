# 명세 — 세트 536 fstab 영구 마운트와 스왑 파일 만들기

> 근거: `docs/research/content_gap_2026-11-19/gap_linux.md` N3·N6. 생성기: `scripts/content-gen/new_sets/set536.py`.
> `linux`, 리눅스, 단원 4, display_order 757.
> 샌드박스는 비특권이라 `mount`·`swapon` 이 `Operation not permitted` 로 막힌다(확인함). 그래서 fstab 은 연습용 사본(`/tmp/lab/fstab`)을 `awk`·`sed` 로 읽고 고치고, 스왑 파일은 `fallocate`·`chmod 600`·`mkswap` 까지 직접 하며, 켜기(`swapon`)·마운트(`mount -a`)는 읽기형 문제로 대체한다. `findmnt --verify` 는 존재하지 않는 대상에 오류를 내 사본 점검에 부적합해 쓰지 않고 `awk` 의 `NF` 로 열 개수를 점검한다.

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 실습 | fstab 6열 읽기(형식·pass) | fstype.txt = xfs, pass.txt = 2 |
| 2 | 객관식 | UUID 를 쓰는 이유(장치 이름 변동) | |
| 3 | 실습 | 장치 이름 줄을 blkid 의 UUID 로 교체 | /data 첫 열 UUID, 나머지 열·다른 줄 유지 |
| 4 | 빈칸 | 옵션 noatime | |
| 5 | 객관식 | 오기·nofail 없음 → 부팅 중단(긴급 모드) | |
| 6 | 실습 | 열이 모자란/넘치는 줄 수정(NF=6) | 전 줄 6열, pass 2, defaults,nofail |
| 7 | 객관식 | 스왑의 역할 | |
| 8 | 실습 | free 출력에서 Swap total·used 읽기 | swap_total.txt = 2047, swap_used.txt = 1530 |
| 9 | 실습 | 스왑 파일 만들기(fallocate 32M·chmod 600·mkswap) | 크기·권한·SWAPSPACE2 시그니처 |
| 10 | 순서 | 파일 생성 → chmod → mkswap → swapon → fstab | |
| 11 | 실습 | fstab 에 스왑 줄 추가(none swap sw 0 0) | 6열·기존 줄 유지 |
| 12 | 객관식 | 재부팅 뒤 스왑 소실 = fstab 미등록 | |

형식: 실습 6, 객관식 4, 빈칸 1, 순서 1 (총 12).

## 수용 조건

- [x] `verify:quests --set 536` 실습 6개 통과 (정답 통과, 무행동 실패)
- [ ] `check-content.sh` 통과
- [ ] 정확성 점검(별도 에이전트)에서 차단 없음
- [ ] 화면 확인 (사용자)
