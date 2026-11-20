# 명세 — 세트 548 성능 병목 찾기 심화: iostat·sar·OOM 로그·열린 파일

> 상태: 작성 (2026-11-20). 근거: `docs/research/content_gap_2026-11-19/gap_linux.md` N22(성능 병목 심화)·S8(OOM)·S9(열린 파일 한도). `linux` 샌드박스, 리눅스, 단원 4, display_order 807. 선행: 세트 162(top·vmstat·free), 27(리눅스 기본 실습).
> 환경 제약(직접 확인): `etude-linux`(Ubuntu 22.04)에는 `iostat`·`sar`·`lsof` 가 없고 `dmesg` 는 `read kernel buffer failed: Operation not permitted` 로 막혀 있다. 따라서 iostat -x·sar -u·dmesg(OOM)·lsof 는 **실제 출력과 같은 모양의 샘플 파일**(`/srv/lab/...`)을 읽는 실습으로, `/proc/PID/fd` 와 `ulimit -n` 은 **실제 명령** 실습으로 구성한다.

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 객관식 | iostat -x 의 await(지연 ms)·%util(바빴던 시간 비율), 간격 없는 첫 보고는 부팅 이후 평균 | |
| 2 | 실습 | iostat 샘플에서 await 20ms 이상 디스크 | slow.txt = sda |
| 3 | 객관식 | %util 높아도 await·aqu-sz 낮은 NVMe 는 포화 아님, %iowait 는 디스크 신호 | |
| 4 | 실습 | sar -u 샘플에서 %idle 최저 시각 | peak.txt = 10:30:01 |
| 5 | 빈칸 | sar -r (메모리), -u·-d 와 구분 | |
| 6 | 실습 | dmesg 샘플에서 OOM 으로 죽은 프로세스 이름·PID (invoked 한 쪽과 구분) | victim = mysqld, pid = 2210 |
| 7 | 객관식 | 로그 없이 `Killed` 로 끝난 프로세스 → 커널 로그 확인 | |
| 8 | 실습 | `/proc/PID/fd` 로 특정 프로세스가 연 파일 확인 (lsof 대체) | data.csv·app.log 있고 other.log 없음 |
| 9 | 실습 | lsof 샘플에서 8080 LISTEN 프로세스 PID | pid8080.txt = 4321 |
| 10 | 실습 | 서브셸 `ulimit -n 12` 로 Too many open files 재현 | err.txt 에 메시지 |
| 11 | 객관식 | 서비스 한도는 유닛 `LimitNOFILE`, `ulimit`·limits.conf 와의 차이 | |
| 12 | 순서 | Too many open files 점검 순서 | |

## 수용 조건

- [x] `verify:quests --set 548` 실습 6개 전부 통과 (정답 통과, 무행동 실패)
- [ ] `check-content.sh` 통과
- [x] 형식 3종 이상(실습·객관식·빈칸·순서), 현장 정보 없음(예시 IP 는 192.0.2.x)
- [x] 샘플 출력이 실제 명령 출력 형식과 일치 (iostat 은 열을 줄인 축약 샘플임을 문제에 명시)
