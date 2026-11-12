# 명세 — 도커 run 옵션 드릴 세트 (-w·--hostname·--env-file·-e 우선순위·--entrypoint·--add-host·--label 필터·create/start·--init/--rm)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-12). 근거: 세트 340 이 `--read-only`·`--tmpfs`·`--user`·자원 제한을, 세트 225 가 `inspect -f`·`ps --format·--filter` 를, 세트 346 이 Dockerfile 의 ENV·WORKDIR·ENTRYPOINT 를 다룬다. 이 세트는 이미지가 아니라 **`docker run` 옵션**으로 환경·작업 폴더·실행 파일·이름·라벨을 바꾸는 것에 집중한 드릴이다. 340 과 겹치는 `--read-only`·`--user` 는 일부러 제외했다.

## 목표

`alpine` 만 써서 `docker run` 옵션을 하나씩 익힌다. `-w` 로 작업 폴더, `--hostname`, `--env-file` 과 `-e` 덮어쓰기 우선순위(`-e` > 뒤쪽 파일 > 앞쪽 파일), `--entrypoint` 로 실행 파일 교체, `--add-host ...:host-gateway`, `--label` 과 `docker ps -a --filter label=키=값`, `docker create` 후 `docker start -a`, `--init`·`--rm` 을 직접 해 보고 `docker inspect` 의 `Config`·`HostConfig` 값과 컨테이너 출력으로 확인한다.

## 원칙

- 터미널 실습은 **결과 상태**(`Config.WorkingDir`·`Config.Hostname`·`Config.Env`·`Config.Entrypoint`·`Config.Cmd`·`Config.Labels`·`HostConfig.ExtraHosts`·`HostConfig.Init`·`HostConfig.AutoRemove`·`State.Running`, `docker logs` 출력, 저장한 파일)로 채점한다. 컨테이너 안의 IP 같은 환경 의존 값은 쓰지 않는다 (`host-gateway` 예약어로 숫자 주소를 피한다).
- setup 만 한 상태에서는 반드시 실패한다. 컨테이너를 만들게 하는 문제는 컨테이너가 없으므로 실패하고, 9번은 `blue.txt` 가 없으므로 실패한다.
- 4번의 `Config.Env` 에는 파일 값(`MODE=prod`)과 `-e` 값(`MODE=dev`)이 둘 다 남고 **마지막 값이 적용**된다. 채점은 출력(`dev-ap`)과 마지막 `MODE=` 항목으로 한다.
- 새 개념은 한 문제에 하나. 쉬운 것에서 어려운 것으로. 이미지는 `alpine` 만 쓴다. setup 은 컨테이너·이미지·`/tmp/work` 를 비우고 `alpine` 을 다시 받아 여러 번 실행해도 안전하다.
- 빈칸 10번 칩에는 두 번째 정답이 없다 (`start` 만 유효: `-a` 는 start 옵션이고 attach 는 `-a` 가 없다). 객관식 5번은 정답을 첫 보기로 쓰고 헬퍼가 위치를 섞는다.

## 세트 구성 (12개: 터미널 9 + 빈칸 1 + 객관식 1 + 순서 1)

| # | 형식 | 제목 | 새로 익히는 것 |
|---|------|------|----------------|
| 1 | 터미널 | 작업 폴더를 정해서 실행하기 (-w) | `-w`, `Config.WorkingDir`, `docker logs` |
| 2 | 터미널 | 컨테이너 호스트 이름 붙이기 (--hostname) | `--hostname` vs `--name`, `Config.Hostname` |
| 3 | 터미널 | 환경 변수 파일로 한 번에 넣기 (--env-file) | `--env-file`, `sh -c` 따옴표 |
| 4 | 터미널 | -e 로 파일 값 덮어쓰기 | `-e` 가 `--env-file` 보다 우선, 파일은 그대로 |
| 5 | 객관식 | env-file 이 두 개일 때 같은 이름의 값은 | 나중 파일이 이김, 우선순위 정리 |
| 6 | 터미널 | 이미지의 실행 파일 바꿔 실행하기 (--entrypoint) | `--entrypoint` 위치(이미지 이름 앞), `Config.Entrypoint`·`Cmd` |
| 7 | 터미널 | 이름에 주소 직접 연결하기 (--add-host) | `--add-host 이름:host-gateway`, `HostConfig.ExtraHosts` |
| 8 | 터미널 | 라벨 붙여 띄우기 (--label) | `--label 키=값`, `-d`, `Config.Labels` |
| 9 | 터미널 | 라벨로 컨테이너 골라내기 (--filter label=) | `ps -a --filter label=키=값 --format`, 종료된 것 포함 |
| 10 | 빈칸 | 만들어 두고 나중에 시작하기 | `docker create` + `docker start -a` |
| 11 | 터미널 | --init 과 --rm 으로 깔끔하게 돌리기 | `--init`, `--rm`, `HostConfig.Init`·`AutoRemove` |
| 12 | 순서 | 옵션을 주어 띄우고 확인하는 흐름 | 파일 작성 → run → ps 필터 → inspect → exec → rm -f |

## 겹침 점검

- **세트 340(자원 제한·보안)**: `--read-only`·`--tmpfs`·`--user` 는 340 의 7~9번이 이미 다루므로 이 세트에서 뺐다. 옵션 드릴이라는 같은 성격이지만 겹치는 개념은 없다.
- **세트 225(출력 뽑기)**: `inspect -f`·`ps --filter` 를 다루지만 `label=` 필터와 컨테이너에 `--label` 붙이기를 직접 해 보는 것은 8·9번이 새롭다. 225 7번(레이블 값 읽기)과 각도가 다르다(읽기 vs 붙이고 골라내기).
- **세트 346(Dockerfile)·234**: ENV·WORKDIR·ENTRYPOINT 를 **이미지 쪽**에서 다룬다. 이 세트는 같은 값을 `docker run` 옵션으로 덮어쓰는 쪽이다(346 3·5번과 주제가 인접하지만 `--env-file`·`-w`·`--entrypoint`·`--hostname` 은 새롭다). 234 8·9번(`--entrypoint` 빈칸·실행 인자)과 6번이 일부 겹친다. 6번은 `Config.Entrypoint`·`Cmd` 를 inspect 로 확인하는 점이 다르다.
- 세트 343(헬스체크·재시작)은 `--health-*`·`--restart` 를 다루고 이 세트와 옵션이 겹치지 않는다. 세트 231(들여다보기)과 `docker logs`·`exec` 만 공통이다.

## 배치

- 세트 349, `sandbox_type = docker`, 분야 `도커`. 단원·display_order 는 통합 시 정한다. 구현: 스크래치패드 `gen349.py`(산출물은 `backend/db/03_quest_set349.sql`, `02_quest_set.sql` 한 줄, `backend/verify/set349.json`, `backend/db/migrations/2026-11-13_docker_run_options_set349.sql`), 검증 하네스 `h349.py`.

## 수용 조건

- [x] 터미널 9문제 모두 `solution` 을 실행하면 채점이 통과한다 (`verify:quests --set 349`).
- [x] 터미널 9문제 모두 setup 만 한 상태에서는 채점이 실패한다.
- [ ] 4번은 `-e` 없이 파일만 쓰면(`prod-ap`) 채점이 실패한다.
- [x] 객관식 5번 정답 번호를 DB 에서 보기 글자로 확인한다.
- [x] 빈칸 10번 칩에 두 번째 정답이 없다 (`start` 만 유효).
- [ ] 채점이 컨테이너 IP·호스트 환경에 의존하지 않는다 (`host-gateway`, 출력·inspect 값만 사용).
- [ ] 각 문제 `docs` 의 Docker 공식 문서 링크가 HTTP 200 이다.
- [x] `check-content.sh`, `check-migrations.sh` 통과.
- [ ] 화면: 세트가 도커 탭에 보이고 1~12번이 순서대로 풀린다 (수동 확인, 배치 후).
