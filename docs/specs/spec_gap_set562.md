# 명세 — 세트 562 복제 직접 구성하고 고장 내 보기

> 상태: 작성 (2026-11-20). 샌드박스 `linux-db`, 카테고리 `데이터베이스`, 단원 20, display_order 822. 선행: 59·91·414. 근거: `gap_db.md` R1·D13. 생성: `scripts/content-gen/new_sets/set562.py`. 한 컨테이너에 mariadbd 두 개(primary 소켓 `/tmp/r1/mysql.sock` 포트 3307, replica `/tmp/r2/mysql.sock` 포트 3308)를 띄워 실제 복제를 구성한다(로컬 컨테이너에서 복제·1062 중단·재개를 직접 확인). 메모리를 아끼려고 기본 서버(3306)는 띄우지 않고 버퍼 풀을 작게 둔다.

## 문제 구성

문제 내용·정답 확인은 세트 원본 `scripts/content-gen/new_sets/set562.py` 가 유일한 기준이다 (이 문서에는 표를 두지 않는다).

## 수용 조건

- [x] `verify:quests --set 562` 실습 6개 통과 (정답 통과, 무행동 실패)
- [x] 형식 4종, 10문제
- [x] 힌트는 방향만, 현장 정보 없음
- [x] `check-content.sh` 통과 확인
