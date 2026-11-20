# 세트 546 명세: 로그 체계 한눈에 (/var/log·rsyslog·logrotate)

- 근거: `docs/research/content_gap_2026-11-19/gap_linux.md` N20. 생성: `scripts/content-gen/new_sets/set546.py`
- 샌드박스 linux-systemd (Rocky 9 ubi-init). category 리눅스, unit 58, display_order 805, 12문제(실습 7).
- 선행: 세트 15(텍스트·로그 처리)·24(systemd·journal 로그).
- 컨테이너에서 직접 확인한 것: logrotate·rsyslog 는 이미지에 없어 setup 이 `dnf install`(약 8초, 이미 있으면 건너뜀). `logrotate -d/-f` 는 실제로 동작(회전·압축·보존 개수 삭제), `rsyslogd -N1` 설정 검증 동작. rsyslogd 데몬·systemd 타이머는 동작하지 않아 규칙 읽기·검증으로 대체. `/var/lib/logrotate` 는 setup 이 만든다.

## 구성

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 실습 | rsyslog.conf 에서 켜진 규칙의 로그 파일 경로 추출 | 6개 경로 일치(주석·include 제외) |
| 2 | 객관식 | 인증 로그는 /var/log/secure | |
| 3 | 실습 | messages 규칙의 `.none` 제외 종류 | mail·authpriv·cron |
| 4 | 실습 | `/etc/rsyslog.d/myapp.conf` 에 local5 규칙 추가 | local5·경로·`rsyslogd -N1` |
| 5 | 실습 | logrotate.conf 의 주기·보존 개수 읽기 | 실제 파일과 일치 |
| 6 | 빈칸 | `-d`(점검) vs `-f`(강제)·`-v`(실제 실행) | 정답 `-d` |
| 7 | 실습 | /etc/logrotate.d 설정 작성 + `-d` 점검 | 7개·daily·compress, 파일은 그대로 |
| 8 | 실습 | `logrotate -f` 강제 회전 | app.log.1.gz(50줄)·빈 app.log |
| 9 | 실습 | rotate 3→2 후 `-f`, 오래된 .3.gz 삭제 | .3.gz 없음·.1.gz 에 최신 로그 |
| 10 | 객관식 | logrotate 는 timer 가 하루 한 번 실행하는 일회성 프로그램 | |
| 11 | 객관식 | postrotate(HUP) vs copytruncate | |
| 12 | 순서 | 설정 작성 → -d → -f → ls | 순서 고정 |

## 수용 조건

- [x] 12문제, 형식 4종(실습·객관식·빈칸·순서)
- [x] 실습 7개 모두 아무것도 안 하면 실패(결과 파일·설정·회전 결과가 초기에 없음), `verify:quests` 7/7 통과
- [x] 힌트는 방향만, 현장 정보 없음, `check-content.sh` 통과
- [x] 객관식 정답 하나, 순서 문제는 설명으로 고정
