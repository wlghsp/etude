# 명세 — Git 작업공간과 조회 도구 손연습 세트 (491)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-18). 근거: [spec_lab_expansion.md](spec_lab_expansion.md) (Git 40% 목표). 겹치지 않는 주제: worktree, grep, shortlog, describe, archive, branch --merged·-m, 훅, diff --name-status.

## 구성 (12문제, 세트 491, sandbox `linux`, 분야 Git, 단원 `설정·패치·내부 구조`(50) 끝, 🗂️)

| # | 형식 | 내용 | 채점 |
|---|---|---|---|
| 1 | 터미널 | `worktree add` | 폴더·목록 |
| 2 | 터미널 | `git grep -n` | 줄 번호 형식 |
| 3 | 터미널 | `shortlog -sn HEAD` | alice 1등, 2명 |
| 4 | 터미널 | `describe --tags` | `v1.0-2-g…` |
| 5 | 터미널 | `archive -o` | .git 제외 |
| 6 | 터미널 | `branch --merged main` | done 있고 wip 없음 |
| 7 | 터미널 | `branch -m` | 이름 변경 |
| 8 | 터미널 | `pre-commit` 훅 | FIXME 차단, 일반 커밋 허용 |
| 9 | 터미널 | `diff --name-status v1.0 HEAD` | A b.txt, A c.txt |
| 10 | 객관식 | worktree 의 이점 | |
| 11 | 빈칸 | `git {0} add` | worktree |
| 12 | 순서 | worktree 긴급 수정 흐름 | |

- 3번: `git shortlog` 는 리비전 없이 터미널이 아니면 표준입력을 읽는다. 처음 정답(`-sn` 만)이 채점에서 실패해 `HEAD` 를 붙이도록 문제·정답을 고쳤다.
- 알려진 한계: 서브모듈, sparse-checkout, notes, bundle 은 후속 후보.

## 수용 조건

- [x] 터미널 9문제 `verify:quests` 9/9 (`검증됨`), 무행동 실패 확인.
- [x] `check-content.sh`·`check-migrations.sh` 통과.
- [ ] 화면: Git 탭에서 보이고 1~12번이 풀린다 (수동 확인).
