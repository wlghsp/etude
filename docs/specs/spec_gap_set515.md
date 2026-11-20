# 명세 — 세트 515 서비스가 뜨지 않을 때 상황집: 203/EXEC, 환경 파일, 포트 충돌, 권한, 의존 실패

> 상태: 작성 (2026-11-19). 근거: `docs/research/content_gap_2026-11-19/gap_linux.md` N15 행과 S1 시나리오(서비스 기동 실패). 샌드박스 `linux-systemd`(실제 systemd, 세트 382 와 동일), 카테고리 `리눅스`, 단원 4, display_order 736. 선행: 24·382. 생성: `scripts/content-gen/new_sets/set515.py`.

## 환경 전제

`linux-systemd` 샌드박스에서 `systemctl`·`journalctl -xeu`·`useradd`·`python3` 가 동작함을 확인했다(`verify:quests` 통과). `ss`·`nc` 는 없으므로 포트 충돌 문제는 로그의 `Address already in use` 로 진단하고, 충돌 상대(`old6`)와 응답 확인은 `python3 -m http.server`·`urllib` 로 한다. 상황은 각 문제의 setup 이 유닛 파일을 써서 재현한다.

## 구성

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 실습 | 실패 상태·종료 코드 읽기 (`systemctl status`) | 파일에 `Active: failed`, `203/EXEC` |
| 2 | 객관식 | `203/EXEC` 의 뜻(실행 단계 실패) | |
| 3 | 실습 | ExecStart 경로 오타 → 로그의 `Failed to locate executable` 로 수정 | active, 가리키는 파일이 실행 가능 |
| 4 | 실습 | 파일은 있으나 실행 권한 없음 (`Permission denied`) → `chmod +x` | active, 유닛 불변 |
| 5 | 실습 | `EnvironmentFile=` 파일 없음 (`Result: resources`) → 파일 생성 | active, `port=9090` |
| 6 | 실습 | `Address already in use` → 새 서비스 포트 변경, 기존 서비스 유지 | 둘 다 active, 8081·8082 응답 |
| 7 | 실습 | `217/USER` 없는 서비스 계정 → `useradd -r` | active, `User=appsvc7` 유지 |
| 8 | 실습 | 서비스 계정이 쓸 디렉터리 권한 → `chown` | active, `User=nobody` 유지, 파일에 `ok` |
| 9 | 실습 | `Dependency failed` 는 의존 대상의 원인 → `back9` 설정 파일 생성 | 둘 다 active, 유닛 불변 |
| 10 | 빈칸 | `systemctl status` / `journalctl -xeu` | |
| 11 | 순서 | 증상 확인 → 원인 → 조치 → daemon-reload → restart → 확인 | |

## 수용 조건

- [x] `verify:quests --set 515` 실습 8개 전부 통과 (정답 통과, 무행동 실패)
- [x] 형식 4종(터미널·객관식·빈칸·순서), 터미널 8/11
- [ ] `check-content.sh` 통과
- [x] 현장 정보 없음 (일반 이름만)
- [ ] 정확성 점검(별도 에이전트)에서 차단 없음
