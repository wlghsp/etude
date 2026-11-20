# 명세 — 세트 540 방화벽과 SELinux 읽기: 허용 포트·컨텍스트·거부 로그

> 상태: 작성 (2026-11-19). 근거: `docs/research/content_gap_2026-11-19/gap_linux.md` N9(방화벽)·N10(SELinux). `linux-systemd` 샌드박스, 리눅스, 단원 59, display_order 761. 선행: 세트 517(접근이 막힐 때 상황집, 접속 거부 vs 시간 초과), 포트 확인(`ss`).
> 환경 제약(직접 확인): `rockylinux/rockylinux:9-ubi-init` 에는 `firewall-cmd`·`getenforce`·`sestatus`·`restorecon`·`semanage`·`ausearch`·`iptables`·`ufw` 가 모두 없다. `dnf` 로 설치해도 D-Bus 가 없어 firewalld 가 동작하지 않고 SELinux 는 Disabled(커널 지원 없음). `ls -Z` 는 `?` 를 출력한다. 따라서 **실제 명령 출력과 같은 모양의 샘플 파일**(`/srv/lab/fw`, `/srv/lab/se`)을 `grep`/`awk`/`tr` 로 읽는 실습과 읽기형 문제로 대체한다.

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 실습 | `--list-all` 읽기: 존(zone)·services 줄 뽑기 | services.txt 가 3개 정확 |
| 2 | 객관식 | runtime vs permanent (`--permanent` 빠뜨리면 reload 때 사라짐) | |
| 3 | 실습 | runtime 에만 있는 포트 찾기 (두 목록 비교) | lost.txt = 9090/tcp |
| 4 | 빈칸 | 저장한 설정 적용 `--reload` | |
| 5 | 객관식 | ufw·iptables ↔ firewall-cmd 대응(개념) | |
| 6 | 객관식 | SELinux 모드, `setenforce 0` = Permissive 임시 | |
| 7 | 실습 | `sestatus` 에서 현재 모드 vs 설정 파일 모드 | current=permissive, config=enforcing |
| 8 | 실습 | `ls -lZ` 컨텍스트 타입 읽기, httpd_sys_content_t 아닌 파일 | wrong.txt = logo.png, report.html |
| 9 | 실습 | audit.log 의 denied AVC 줄에서 `comm` 뽑기 | denied.txt = httpd, nginx |
| 10 | 객관식 | AVC 한 줄(scontext/tcontext/tclass) 해석, restorecon | |
| 11 | 객관식 | 파일 라벨이 아닌 boolean(`setsebool -P`) | |
| 12 | 순서 | SELinux 의심 점검 순서 | |

샘플 출력 형식: `firewall-cmd --list-all`(Rocky 9, `forward: yes` 포함), `sestatus`, `ls -lZ`(모드 끝 `.`), `type=AVC ... avc:  denied  { ... } ... permissive=0`.

## 수용 조건

- [ ] `verify:quests --set 540` 실습 5개 전부 통과 (정답 통과, 무행동 실패)
- [ ] `check-content.sh` 통과
- [ ] 형식 3종 이상(실습·객관식·빈칸·순서), 현장 정보 없음
- [ ] 샘플 출력이 실제 명령 출력 형식과 일치
