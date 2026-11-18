# 명세 — Git rebase 손연습 세트 (476)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-18). 근거: [spec_lab_expansion.md](spec_lab_expansion.md) (Git 실습 비중 26% → 40%). 퀴즈 172/321·176/322·161/319 가 `rebase`·`fixup`·`--onto` 를 읽기만 해서, 같은 주제를 손으로 해 보는 짝 세트로 만든다.

## 목표

`git rebase` 의 일상 작업(옮기기, 합치기, 고치기, 버리기, 순서 바꾸기, 충돌 해결, 취소, 커밋마다 명령 실행)을 직접 쳐서 익힌다. 에디터를 열지 않고 `GIT_SEQUENCE_EDITOR`·`GIT_EDITOR` 로 자동화하는 법을 함께 익힌다.

## 구성 (12문제, 세트 476, sandbox `linux`, 분야 Git)

| # | 형식 | 내용 | 채점 (저장소 상태) |
|---|---|---|---|
| 1 | 터미널 | `rebase --onto main dev topic` | topic 이 main 위, 2커밋, dev 커밋 제외 |
| 2 | 터미널 | `commit --fixup` + `rebase -i --autosquash` | 3커밋, fixup! 없음, 오타 수정이 add a 에 흡수 |
| 3 | 터미널 | `squash` 로 3→1 | 1커밋, 파일 3개, 메시지에 제목 3개 |
| 4 | 터미널 | `reword` | 제목이 add a, add b, add c 순서 |
| 5 | 터미널 | `drop` | add b 없음, b.txt 없음 |
| 6 | 터미널 | todo 줄 순서 바꾸기 | add b, add a, add c |
| 7 | 터미널 | 충돌 해결 → `--continue` | rebase 종료, 내용 mode=both, 병합 커밋 없음 |
| 8 | 터미널 | `--abort` | reflog 에 abort 기록, feature 가 원래 해시 |
| 9 | 터미널 | `rebase -x` | 커밋 제목이 순서대로 한 줄씩 |
| 10 | 객관식 | 공유한 브랜치를 rebase 하면 | 새 해시로 갈라진다 |
| 11 | 빈칸 | `git rebase --{0}` (continue) | |
| 12 | 순서 | 충돌 해결 순서 | |

- 모든 터미널 문제의 환경은 `/tmp/lab/proj` 에 setup 이 만든다 (저장소 작업은 이 안으로 한정, 8번은 원래 해시를 `/tmp/lab/orig.txt` 에 둔다).
- 8번은 아무것도 안 해도 저장소가 원래 상태라, "abort 를 실제로 실행했는지"를 `git reflog` 의 `rebase (abort)` 기록으로 확인한다 (거짓 통과 방지).
- 근거: git-rebase 공식 문서, Pro Git "이력 다시 쓰기".

## 알려진 한계

`--rebase-merges`(`-r`), `--interactive` 의 `edit`·`exec` 세부, `rebase --update-refs`, `git pull --rebase` 는 다루지 않았다.

## 배치

Git 단원 `병합과 이력 다듬기 심화`(49) 끝, display_order 428, 아이콘 🪜.

## 수용 조건

- [x] 터미널 9문제의 `solution` 이 `verify:quests` 에서 통과한다 (9/9, `검증됨`).
- [x] 터미널 9문제가 setup 만 한 상태에서는 채점에 실패한다 (`verify:quests` 가 "무행동" 으로 함께 검사).
- [x] 각 문제의 `docs` 에 git-rebase 문서·Pro Git 링크가 있다.
- [x] `check-content.sh`·`check-migrations.sh` 통과 (아래 실행 결과 참조).
- [ ] 화면: 세트가 Git 탭 단원 `병합과 이력 다듬기 심화` 끝에 보이고 1~12번이 풀린다 (수동 확인).
