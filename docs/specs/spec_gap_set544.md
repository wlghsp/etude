# 세트 544 명세: 계정 정책 (shadow 필드·잠금·만료·nologin·로그인 기록)

- 근거: `docs/research/content_gap_2026-11-19/gap_linux.md` N14. 생성: `scripts/content-gen/new_sets/set544.py`
- 샌드박스 linux (Ubuntu 22.04, root). category 리눅스, unit 58, display_order 803, 12문제(실습 8). 선행: 세트 232.
- 직접 확인: `chage`·`passwd`·`usermod`·`lastlog`·`last`·`nologin` 동작. linux-systemd(Rocky)는 `passwd` 명령이 없어 쓰지 않음. 실제 로그인 기록은 만들 수 없어 `lastlog` 는 `Never logged in` 필터로 실습.

## 구성

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 객관식 | shadow 해시 칸의 `!`·`*` | |
| 2 | 실습 | shadow 5번째 칸(최대 사용일) 추출 | 파일 값 60 |
| 3 | 실습 | `passwd -l`(또는 `usermod -L`) 잠금 | 상태 L, 해시 보존, 홈 유지 |
| 4 | 빈칸 | passwd 잠금 `-l` / usermod 해제 `-U` | |
| 5 | 실습 | 잠긴 계정 해제 | 상태 P, 해시 정상 |
| 6 | 객관식 | 비밀번호 잠금은 키 인증을 막지 못함 | |
| 7 | 실습 | `chage -l` 읽기 | 최대 30·최소 3 줄 |
| 8 | 실습 | `chage -M 90 -W 14` | 5·6번째 칸, 최소일 불변 |
| 9 | 실습 | `chage -E 2030-01-01` | 8번째 칸, 해시 불변 |
| 10 | 실습 | `usermod -s nologin` | 셸·계정 유지·로그인 거부 |
| 11 | 실습 | `lastlog -u 1000-60000` + Never 필터 | ops01·ops02, root 제외 |
| 12 | 객관식 | last / lastlog / lastb | |

## 수용 조건

- [x] 12문제, 형식 3종(실습·객관식·빈칸)
- [x] 실습 8개 모두 초기 상태에서 실패(파일 없음, 잠금·값·셸이 초기와 다름)
- [x] 힌트는 방향만, 현장 정보 없음, 객관식·빈칸 정답 하나
- [x] 로컬 `verify:quests` 8/8 통과, `check-content.sh` 통과
