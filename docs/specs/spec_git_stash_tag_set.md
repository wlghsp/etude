# 명세 — Git 임시 보관·태그·커밋 골라 가져오기 세트 (stash · tag · cherry-pick)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-12). 세트 368, Git 분야 `브랜치와 병합` 단원(id 14) 끝(세트 53 뒤), 아이콘 📦, 샌드박스 `linux`. 근거: 기존 Git 실습 52·53·54·56·94·95·96·365 는 기록·브랜치·원격·되돌리기·.gitignore·기록 읽기를 다루지만 `stash`, `tag`, `cherry-pick` 은 실습이 없다(퀴즈에서 일부 개념만 스친다).

## 목표

고정된 작은 저장소(`/tmp/lab/proj`, main 3커밋 + `feature` 브랜치 2커밋, 태그 `v0.9`·`v1.0-rc1`, README 수정 중)에서 "치우기 → 보기 → 되살리기 → 태그 달기(가벼운·메시지 있는·옛 커밋) → 태그 찾기 → 커밋 하나 가져오기 → 출처 남기기" 를 쌓는다.

## 원칙

- 터미널 9 + 객관식 1 + 빈칸 1 + 순서 1.
- setup 은 `/tmp/lab` 을 지우고 저장소를 다시 만든다. 작성자·날짜는 환경 변수로 고정해 해시가 매번 같다. `stash`·annotated 태그·cherry-pick 이 사용자 정보를 요구하므로 **이 저장소에만** `user.name`/`user.email` 을 설정한다(전역 설정은 건드리지 않는다).
- 채점은 저장소의 **실제 상태**를 본다: `git status --porcelain`, `git stash list`, `rev-parse`, `cat-file -t`(commit 인지 tag 인지), 최근 커밋 제목과 메시지, 파일 유무. 파일로 저장하는 문제(2·3·7번)는 같은 git 명령의 실제 출력과 비교한다.
- 한계: 같은 상태를 만드는 다른 방법도 통과한다(예: 3번 `stash apply` 후 `stash drop`). 8·9번은 `cherry-pick` 대신 같은 내용을 직접 만들어 커밋해도 제목이 같으면 통과할 수 있다(9번은 `cherry picked from` 문구가 있어야 해서 줄어든다).
- 가상 데이터만 쓴다. 문서 링크: git-scm.com/docs 의 git-stash·git-tag·git-cherry-pick (200 확인).

## 세트 구성 (12개)

| # | 형식 | 새로 익히는 것 |
|---|------|----------------|
| 1 | 터미널 | `git stash` |
| 2 | 터미널 | `git stash list` |
| 3 | 터미널 | `git stash pop` |
| 4 | 터미널 | `git tag 이름` (가벼운 태그) |
| 5 | 터미널 | `git tag -a ... -m` (메시지 있는 태그) |
| 6 | 터미널 | `git tag 이름 HEAD~1` (옛 커밋에) |
| 7 | 터미널 | `git tag -l "패턴"` |
| 8 | 터미널 | `git cherry-pick` (커밋 하나) |
| 9 | 터미널 | `git cherry-pick -x` |
| 10 | 객관식 | cherry-pick 이 하는 일 |
| 11 | 빈칸 | `git stash pop` |
| 12 | 순서 | 급한 수정이 끼어들 때의 흐름 |

## 수용 조건

- [x] 터미널 9문제 모두 `solution` 을 실행하면 채점이 통과한다 (`npm run verify:quests -- --set 368`, 9/9).
- [x] `check-content.sh`, `check-migrations.sh`(38개) 통과, 단원 14 끝에 배치.
- [ ] 흔한 오답(1번에서 변경을 버리기, 4번에서 -a 태그, 8번에서 두 커밋 모두 가져오기)이 걸러지는지 실행 확인 (코드상 확인만).
- [ ] 화면: Git 분야 `브랜치와 병합` 단원 끝에 보이고 1번부터 12번까지 풀린다 (수동 확인).
