# 명세 — 리눅스 "로그와 텍스트 처리" 세트

> 상태: **구현 완료(로컬), 화면 확인·서버 반영 대기** (2026-10-29). 결정 1·2는 추천안(이미지에 샘플 포함, 12개 목록 그대로)으로 진행했다. 바꾸려면 알려 주세요.

## 목표

장애 대응의 출발점인 "로그에서 필요한 줄과 숫자를 뽑아내는" 능력을 실습한다. 현재 리눅스 세트에는 파이프와 리다이렉션을 쓴 퀘스트가 거의 없다 (기초 1~3 세트 합쳐 2건, 제목·SQL 검색 기준).

## 환경 (확인한 사실)

- 샌드박스 타입은 기존 `linux`(`etude-linux`, Ubuntu 22.04)를 그대로 쓴다. 새 샌드박스 타입이 필요 없다. 자원은 일반 컨테이너(512MiB)라 부담이 작다.
- 이미지에 있는 도구: `awk`(mawk), `sed`, `cut`, `sort`, `uniq`, `tr`, `wc`, `head`, `tail`, `grep`/`egrep`, `xargs`, `tee`, `find`, `diff`, `comm`, `paste` (실행해서 확인함).
- 없는 도구: `less`, `column`, `logger`, `journalctl`, `crontab`. 이 도구가 필요한 퀘스트는 이 세트에 넣지 않는다 (범위 밖 참고).

## 세트 구성 (12개, 쉬운 것부터)

샘플 로그는 고정 데이터라 정답이 항상 같다: `/var/log/app/app.log`(INFO/WARN/ERROR/DEBUG 혼합), `/var/log/app/access.log`(`IP - - [시각] "요청" 상태코드`), `/etc/app/app.conf`.

| # | 제목 | 핵심 명령 | 채점 (결과 파일 vs 원본에서 다시 계산한 값) |
|---|------|-----------|-----------|
| 1 | 로그 마지막 5줄 저장하기 | `tail -n` | `/tmp/last5.txt`가 `tail -n 5 app.log`와 같다 |
| 2 | ERROR 줄만 추출하기 | `grep` | `/tmp/errors.txt`가 `grep ERROR app.log`와 같다 |
| 3 | ERROR 줄 개수 세기 | `grep -c`, `wc -l` | `/tmp/error_count.txt`의 숫자가 실제 개수와 같다 |
| 4 | ERROR 또는 WARN 줄 추출하기 | `grep -E 'A\|B'` | 결과가 `grep -E` 결과와 같다 |
| 5 | DEBUG 줄 제외하기 | `grep -v` | 결과에 DEBUG가 없고 줄 수가 맞다 |
| 6 | 에러 메시지를 파일로 저장하기 | `2>` , `2>&1` | `ls /nonexistent`의 에러가 `/tmp/err.txt`에 있다 |
| 7 | 기존 파일에 내용 이어 쓰기 | `>>` | 기존 첫 줄이 남아 있고 새 줄이 추가됐다 (`>`로 덮어쓰면 실패) |
| 8 | 접속 IP 목록 뽑기 | `cut -d' ' -f1`, `awk` | `/tmp/ips.txt`가 첫 필드 목록과 같다 |
| 9 | 고유 IP만 남기기 | `sort \| uniq` | 중복 없는 정렬된 목록 |
| 10 | 접속 많은 IP 상위 3개 | `sort \| uniq -c \| sort -rn \| head` | `/tmp/top3.txt`가 계산한 상위 3개와 같다 |
| 11 | 500 에러가 난 URL만 뽑기 | `awk '$9==500 {print $7}'` | 결과가 기대 목록과 같다 |
| 12 | 설정 값 한 줄 바꾸기 | `sed -i 's/a/b/'` | `app.conf`에서 해당 줄만 바뀌고 나머지는 그대로 |

채점 원칙: 정답 문자열이 아니라 **상태**로 판정한다 (결과 파일이 원본에서 다시 계산한 값과 같은가). 풀기 전에는 결과 파일이 없어서 실패해야 한다. 퀘스트는 서로 독립 실행이 가능해야 한다.

## 반영 절차

1. `backend/docker/samples/`에 샘플 데이터를 두고 `Dockerfile.linux`에 포함한다 → **서버에서 `etude-linux` 이미지를 다시 빌드해야 한다.** 이미지가 먼저 있어야 퀘스트가 동작하므로 **순서: 이미지 빌드 → 퀘스트 DB 반영**.
2. `backend/db/02_quest_set.sql`에 세트(id 15), `backend/db/03_quest_set15.sql`에 퀘스트 (원본).
3. 운영 DB 반영용 `backend/db/update_{날짜}_linux_text_set.sql` (기존 update 파일 방식).
4. `backend/verify/set15.json`에 퀘스트별 정답 명령.
5. 채점 검증 러너로 12개를 확인한다: 정답을 하면 통과, 풀기 전에는 실패.
6. 퀘스트는 사용자가 화면에서 한 번 풀어 보고 확인한 뒤 커밋한다.

## 수용 조건

- [x] 12개 퀘스트 모두 지문·힌트·풀이·채점이 있다
- [x] 검증 러너에서 12개 통과 — `검증됨` (`npm run verify:quests -- --set 15`: 통과 12, 실패 0, 로컬)
- [x] 퀘스트가 서로 독립적으로 실행된다 (러너가 퀘스트마다 새 컨테이너에서 실행)
- [x] 샘플 데이터가 이미지에 있다. 재빌드 절차는 [guide_post_deploy_checklist.md](../ops/guide_post_deploy_checklist.md)의 이미지 빌드 항목(`docker build -f docker/Dockerfile.linux -t etude-linux:latest .`, `backend/`에서)을 따른다 (`코드상 확인됨`)
- [ ] 사용자가 화면에서 몇 개를 풀어 확인했다

## 범위 밖

- `journalctl`, `tail -f`의 실시간 관찰, `cron`, `less`: 이 이미지에 없거나 채점이 어렵다. 필요하면 `linux-systemd` 세트(Rocky)에서 별도로 다룬다.
- 쉘 스크립트 작성, 정규식 심화.

## 결정 필요

1. **샘플 데이터를 이미지에 넣는 것에 동의하는지.** 대안은 퀘스트마다 `setup_cmd`에서 로그를 만드는 방식인데, 같은 데이터가 12곳에 중복돼 단일 진실 공급원 원칙에 어긋납니다. 이미지 방식은 서버에서 이미지를 한 번 다시 빌드해야 합니다 (사용자님이 서버에서 실행).
2. **12개 목록이 현장에 맞는지.** 빼고 싶은 것, 꼭 넣고 싶은 것(예: 특정 현장 로그 형식)이 있으면 알려 주세요.
