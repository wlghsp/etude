# 명세 — 세트 549 SSH 강화와 활용: sshd_config 핵심 항목·검증·포트 포워딩·tmux

> 상태: 작성 (2026-11-20). 근거: `docs/research/content_gap_2026-11-19/gap_linux.md` N23. `linux-ssh` 샌드박스, 리눅스, 단원 4, display_order 808. 선행: 세트 75(SSH 키), 124(SSH 접속 문제).
> 환경 제약(직접 확인): `etude-ssh`(Ubuntu 22.04)에는 `sshd`·`ssh` 가 있고 `tmux` 는 없으며 apt 로도 설치되지 않는다. 그래서 실제 sshd 를 띄우지 않고 임시 설정 파일에 `sshd -t/-T -f`(검사·실효값), `ssh -G -F`(클라이언트 적용값)를 쓰고, tmux 는 개념·명령 문제로 다룬다. `/etc/ssh` 는 건드리지 않는다.

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 객관식 | PermitRootLogin 값 (`no` vs `prohibit-password`) | |
| 2 | 실습 | 주석·빈 줄 제외한 적용 줄 보기 | active.txt 가 `grep -vE` 결과와 동일 |
| 3 | 실습 | PermitRootLogin no, PasswordAuthentication no 로 고치기 | `sshd -T` 실효값 + `-t` 통과 |
| 4 | 빈칸 | `sshd -t` (서버를 띄우지 않는 검사) | |
| 5 | 실습 | `sshd -t` 오류 줄로 오타 고치기 | `-t` 통과, 값 유지 |
| 6 | 실습 | 중복 항목은 먼저 읽은 값이 이긴다 (`sshd -T`) | effective.txt 두 줄 |
| 7 | 실습 | Include 조각 파일이 메인 설정을 덮는 문제 | `sshd -T` passwordauthentication no |
| 8 | 순서 | 비밀번호 로그인 안전하게 끄는 순서 | |
| 9 | 객관식 | `ssh -L 로컬:대상:포트` 의 방향 | |
| 10 | 실습 | ssh 설정 파일의 LocalForward | `ssh -G` 의 localforward |
| 11 | 객관식 | tmux detach/attach 흐름 | |
| 12 | 빈칸 | `tmux attach -t` | |

## 수용 조건

- [x] `verify:quests --set 549` 실습 6개 전부 통과 (정답 통과, 무행동 실패)
- [ ] `check-content.sh` 통과
- [x] 형식 4종(실습·객관식·빈칸·순서), 현장 정보 없음 (`example.com` 만 사용)
- [x] 힌트에 정답 값·명령 전체를 적지 않음, 객관식 정답 하나, 순서 하나로 고정
- 한계: tmux·실제 sshd 재시작·실제 터널 연결은 샌드박스에서 실행하지 않는다(개념 문제로 대체).
