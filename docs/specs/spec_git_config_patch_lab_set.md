# 명세 — Git 설정·패치·내부 구조 손연습 세트 (486)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-18). 근거: [spec_lab_expansion.md](spec_lab_expansion.md) 단원 단위 목표(단원 `설정·패치·내부 구조`는 실습 0개였다). 짝 퀴즈: 188/325(config 다루기), 192/326(검색과 패치: format-patch·apply·am), 196/327(참조와 변경 목록).

## 구성 (12문제, 세트 486, sandbox `linux`, 분야 Git)

| # | 형식 | 내용 | 채점 |
|---|---|---|---|
| 1 | 터미널 | `config --local` + `--show-origin` | 값, 출처 `.git/config` |
| 2 | 터미널 | `alias.lg` | `git lg` 3줄, 전역 설정에 있음 |
| 3 | 터미널 | `includeIf "gitdir:"` | work 아래만 work@, other 는 그대로 |
| 4 | 터미널 | `url.insteadOf` | `ls-remote --get-url` 결과 |
| 5 | 터미널 | `format-patch -2 -o` | 패치 2개, 번호, c5 포함 |
| 6 | 터미널 | `git am` | 제목, 작성자 alice 유지 |
| 7 | 터미널 | `git apply --check` → `apply` | 내용 변경, 커밋 불변, 수정(M) |
| 8 | 터미널 | `rev-parse HEAD^{tree}` | `cat-file -p` 의 tree 와 일치 |
| 9 | 터미널 | `update-ref` + `for-each-ref` | main·saved, 이름만 |
| 10 | 객관식 | `am` 과 `apply` 의 차이 | |
| 11 | 빈칸 | `git {0} --show-origin` (config) | |
| 12 | 순서 | 패치로 커밋 옮기기 순서 | |

- setup 은 `~/.gitconfig` 와 `/tmp/lab` 을 초기화한다. 3번은 `work/proj`·`other/proj` 두 저장소, 6번은 alice 작성 커밋 2개를 패치로 만들어 둔 `target` 저장소, 7번은 diff 파일을 준비한다.
- 근거: git-config·format-patch·am·apply·rev-parse·update-ref 공식 문서, Pro Git "Git 내부".

## 알려진 한계

`git config` 의 `--system`·`--worktree` 범위, `conditional includeIf onbranch:`, `git describe`·`symbolic-ref`, `sparse-checkout`, `git bundle`, 서브모듈은 다루지 않았다.

## 배치

Git 단원 `설정·패치·내부 구조`(50) 끝, display_order 445, 아이콘 🔬.

## 수용 조건

- [x] 터미널 9문제가 `verify:quests` 에서 통과하고 무행동 상태에서는 실패한다 (9/9, `검증됨`).
- [x] 객관식 정답을 DB 에서 확인한다. `check-content.sh`·`check-migrations.sh` 통과.
- [ ] 화면: Git 탭에서 보이고 1~12번이 풀린다 (수동 확인).
