# 명세 — 세트 543 ACL과 특수 권한 직접 해 보기: setfacl·default ACL·setgid·sticky

> 상태: 작성 (2026-11-20). 근거: `docs/research/content_gap_2026-11-19/gap_linux.md` N13. `linux-systemd` 샌드박스, 리눅스, 단원 59, display_order 802. 선행: 세트 427(ACL 읽기), 65(권한), 232(사용자·그룹).
> 환경(직접 확인): `rockylinux/rockylinux:9-ubi-init` 은 root 로 동작하고 `getfacl`·`setfacl`·`useradd`·`su` 가 있으며 파일시스템 ACL·setgid·sticky 가 실제로 동작한다. 그래서 읽기형이 아닌 직접 실행 실습으로 구성한다. 사용자 kim·lee·outsider 와 그룹 dev 는 문제 setup 에서 만든다.

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 실습 | `ls -l` 끝의 `+` 로 ACL 있는 파일 찾기 | acl_files.txt = a.txt, c.txt |
| 2 | 실습 | `setfacl -m u:kim:rw` 로 한 사람만 허용 | kim 쓰기 가능, lee 읽기 불가 |
| 3 | 빈칸 | `setfacl -x u:lee` 항목 하나 제거(-b·-k 구분) | |
| 4 | 실습 | `-R -m u:lee:rwX` 기존 폴더 전체, 대문자 X | 파일 rw-, 폴더 rwx |
| 5 | 실습 | `-d` default ACL: 앞으로 만들 파일에 상속 | default 항목, umask 027 로 만든 새 파일을 lee 가 씀 |
| 6 | 객관식 | default ACL 은 기존 파일에 적용 안 됨 | |
| 7 | 실습 | 폴더 setgid(`chmod g+s`/`2770`): 새 파일 그룹 상속 | 모드 2770, kim 파일 그룹 dev |
| 8 | 객관식 | 대문자 `S` = setgid 켜짐 + 그룹 x 없음 | |
| 9 | 객관식 | setgid 만으로는 그룹 쓰기가 안 됨(umask 022) → umask/default ACL | |
| 10 | 실습 | sticky(`chmod +t`): 남의 파일 삭제 방지 | t 표시, lee 가 kim 파일 못 지움·자기 파일은 가능 |
| 11 | 순서 | groupadd → usermod → mkdir → chgrp → chmod 2770 → ls -ld | |
| 12 | 실습 | 종합: setgid + 그룹 default ACL 협업 폴더 | 그룹 dev 상속, lee 쓰기 가능, outsider 읽기 불가 |

## 수용 조건

- [x] 12문제, 형식 4종(실습·객관식·빈칸·순서), 실습 7개
- [x] 실습 모두 아무것도 안 하면 실패(검사가 초기에 없는 ACL·비트·그룹을 봄), `verify:quests --set 543` 7/7 통과
- [x] 힌트는 방향만, 현장 정보 없음
- [x] 객관식·빈칸 정답이 하나, 순서 문제는 설명으로 순서 고정
