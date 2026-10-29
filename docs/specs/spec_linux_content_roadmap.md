# 리눅스 콘텐츠 로드맵 — 개발자에게 필요한 순서

> 상태: 세트 15, 16은 로컬 구현·검증 완료, 화면 확인과 서버 반영 대기 (2026-10-29). 방향: 리눅스가 탄탄하면 k8s가 쉬워진다.

## 우선순위 기준

현장에서 장애가 났을 때 가장 먼저, 가장 자주 쓰는 순서로 정한다. k8s 디버깅(로그를 grep, 컨테이너 안에서 프로세스·포트·권한 확인)에도 그대로 쓰이는 능력을 앞에 둔다.

| 순서 | 주제 | 세트 | 상태 |
|---|---|---|---|
| 1 | 로그와 텍스트 처리 (grep, 리다이렉션, sort/uniq, awk, sed) | 15 (12개) | 로컬 검증 완료 (12/12) |
| 2 | 장애 진단 실전 (디스크, CPU, 포트, 권한, 종료 코드, 깨진 링크) | 16 (11개) | 로컬 검증 완료 (11/11) |
| 3 | 쉘 스크립트 기초 (변수, 인자, 조건, 반복, 종료 코드) | 17 (10개) | 로컬 검증 완료 (10/10) |
| 4 | 네트워크 진단 (`curl`, `nc`, `ss`, `/etc/hosts`, 종료 코드) | 18 (10개) | 로컬 검증 완료 (10/10). `etude-linux`에 `curl`, `netcat-openbsd`와 퀘스트용 HTTP 서버 `etude-httpd`(perl) 추가 → 이미지 재빌드 필요(배포가 자동 수행) |
| 5 | systemd 서비스와 로그 (`journalctl`, unit 파일) | 10 확장 | 미착수. Rocky systemd 샌드박스(자원 큼) 필요 |

## 세트 16 구성

퀘스트마다 `setup_cmd`로 장애 상황을 만들고, 결과 **상태**로 채점한다. 이미지 변경은 없다 (기존 `etude-linux` 도구만 사용: `find`, `du`, `ps`, `ss`, `kill`, `su`, `useradd`, `perl`).

1. 큰 파일 찾기 / 2. 용량 큰 디렉토리 찾기 / 3. 오래된 로그 정리 (`find -mtime -delete`)
4. CPU 점유 프로세스 찾기 / 5. 종료하기
6. 포트 점유 프로세스 PID 찾기 / 7. 포트 비우기
8. 실행 권한 오류(`Permission denied`) 해결 / 9. 쓰기 권한 오류 해결 (777 금지)
10. 종료 코드(`$?`) 확인 / 11. 깨진 심볼릭 링크 찾기

알려진 주의: CPU 점유 퀘스트(4, 5)는 프로세스가 CPU 사용률에 반영될 때까지 setup이 2초 기다린다. 전체 `etude-linux` 세트 중 이 퀘스트만 백그라운드 프로세스를 띄운다.

## 서버 반영

세트 15는 이미지 재빌드가 필요하며 배포가 자동으로 빌드한다 ([spec_linux_text_processing_set.md](spec_linux_text_processing_set.md)). 세트 16은 이미지 변경이 없고 `backend/db/migrations/`의 파일이 배포 때 자동 적용된다 ([guide_db_migrations.md](../ops/guide_db_migrations.md)).

## 세트 18 메모

- DNS(`dig`)는 외부 네트워크에 의존해 채점이 불안정하므로 넣지 않았다. 이름 해석은 `/etc/hosts`로 다룬다.
- `etude-httpd`는 `backend/docker/samples/bin/`에 한 벌만 있고(단일 진실 공급원) 퀘스트 setup은 이름으로 호출한다. 동작: `/health`→503, POST→`got:<본문>`, 그 외 200 `healthy`(헤더 `X-Env: prod`).

## 기본기 점검 (2026-10-29, 퀘스트 정답 텍스트의 키워드 검색)

방법: 로컬 DB의 `quest.solution`에서 명령어를 검색했다 (`검증됨`: 실행한 쿼리 결과). 키워드 매칭이라 오탐/누락이 있을 수 있다 (예: `mount`는 k8s의 `volumeMounts`에도 걸린다).

- **0건 (정답에 한 번도 나오지 않음):** `wc`, `id`/`groups`/`whoami`, `su`, `usermod`/`groupadd`, 하드링크(`ln` 옵션 없음), 와일드카드(glob) 활용, `alias`, `history`, `which`/`type`, `diff`, `stat`, `xargs`, `umask`, `rpm`, `apt`/`dnf`/`yum`, `firewall-cmd`, `journalctl`, `ssh-keygen`
- **1~3건뿐:** `sudo`(1), `tee`(1), `chown`(2), `useradd`(2), `systemctl`(2), `ssh`(2)
- **불일치:** 세트 10(리눅스 현장 운영)의 설명은 "systemd, rpm, 환경변수, 방화벽"이라고 하지만 퀘스트에는 `rpm`과 방화벽이 없다.
- **충분함:** `chmod`, `export`, `head`/`tail`(15~16에서 추가), `grep`/`sed`/`awk`/`sort`/`uniq`(15에서 추가)

→ 부족한 기본기를 묶은 세트 후보: "쉘 기본기와 사용자·권한"(glob, 인용부호, alias, history, which, wc, diff, xargs, tee, id, su, umask, stat, 하드링크) / "패키지·방화벽·로그"(rpm, dnf, firewall-cmd, journalctl; Rocky systemd 샌드박스 필요).
