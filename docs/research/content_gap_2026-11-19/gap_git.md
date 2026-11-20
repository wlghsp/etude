# Git 분야 콘텐츠 빈틈 분석

분석 기준일 2026-11-19. 대상: category='Git' 세트 48개(단원 8개: 12 기초, 14 브랜치와 병합, 15 원격과 협업, 17 되돌리기와 복구, 42 기록 살펴보기, 49 병합과 이력 다듬기 심화, 50 설정·패치·내부 구조). 참고 기준: Pro Git 범위.

## 요약

- 현재 수준: 명령 단위 폭은 이미 넓다(Pro Git 2~7장 대부분의 명령이 한 번 이상 등장). 그러나 구조가 "한 줄씩 퀴즈 28세트(1/2·2/2 쌍) + 터미널 실습 세트 20개 미만"으로, 퀴즈 비중이 매우 높고, 입문자에게 필요한 "그림으로 이해하기"와 "팀 협업 워크플로"가 비어 있다. 공개 시 큰 구멍은 개념 폭보다 **협업/인증/내부 구조 실습/장애 대응 폭**이다.
- 가장 큰 빈틈 1: **인증·접근 (SSH 키, 자격 증명 저장, 원격 URL https/ssh, 서명 커밋)** 이 전무하다. clone/push 가 막히는 가장 흔한 현장 장애인데 세트 54·94 의 오류 시나리오에 인증 실패가 없다.
- 가장 큰 빈틈 2: **협업 워크플로 (PR/MR 흐름, 브랜치 전략, 포크, 릴리스 태그·버전 규칙, 보호 브랜치, 커밋 메시지 규약)** 개념 세트가 없다. 현재 팀 단위 흐름을 가르치는 세트 0개.
- 가장 큰 빈틈 3: **저장소 내부·유지보수 (객체 저장소/packfile/gc/fsck/prune, 큰 파일·비밀 이력 제거 filter-repo, LFS, shallow/partial clone, 서버 훅)** 가 개념 퀴즈(168·180)에 얕게만 있고 터미널 실습이 없다. 또 **상황집 95 가 하나뿐**이고 퀴즈 중심.
- 순서 문제: 단원 12 에서 핵심 실습 세트 52 가 맨 뒤, 개념 퀴즈가 먼저(감사 결과 `order_in_unit` 높음). 신규 세트보다 **재배치 + 징검다리 2~3세트**가 우선.

## 참고 커리큘럼

학습자는 사내 인프라 운영자. 활용도 낮은 것(Git 내부 프로토콜 상세, git-svn, Perforce 연동, send-email 상세, 오래된 filter-branch 세부)은 제외.

| # | 영역 | 핵심 주제 |
|---|------|-----------|
| D1 | 시작하기·개념 | 버전관리 필요성, 3영역(작업 폴더·스테이징·저장소), 설치, config(user/editor/기본 브랜치), 도움말 |
| D2 | 기본 워크플로 | init/clone, status, add, commit, diff, log, rm/mv, .gitignore, 커밋 메시지 쓰기 |
| D3 | 브랜치 | 브랜치 개념(포인터), switch/checkout, HEAD, 브랜치 목록·삭제·이름 변경, detached HEAD |
| D4 | 병합 | fast-forward/3-way, 병합 커밋, 충돌 해결, --no-ff/--squash/--abort, 전략·옵션, rerere |
| D5 | 리베이스·이력 편집 | rebase, rebase -i, --onto, fixup/autosquash, 공유 브랜치 rebase 금지, cherry-pick, amend |
| D6 | 원격 | remote add/set-url, fetch/pull/push, 추적 브랜치, upstream, 삭제·prune, 거절·divergent, force-with-lease |
| D7 | 인증·접근 | https vs ssh, SSH 키 생성·등록, credential helper, 토큰, known_hosts, 인증 오류 읽기 |
| D8 | 되돌리기·복구 | restore, reset 3모드, revert(병합 -m), reflog, 삭제 브랜치·커밋 복구, stash, clean |
| D9 | 이력 탐색 | log 옵션/--graph/범위(..,...), show, blame/-L/log -L, -S/-G, bisect, describe, shortlog, grep |
| D10 | 태그·릴리스 | 경량/주석 태그, 태그 push·삭제, SemVer, 서명 태그, describe, archive |
| D11 | 협업 워크플로 | 중앙집중/기능 브랜치/Gitflow/트렁크 기반, PR/MR 리뷰 흐름, 포크 모델, 보호 브랜치, 커밋 규약, 패치 메일(format-patch/am) |
| D12 | 훅·자동화 | 클라이언트 훅(pre-commit/commit-msg/pre-push), core.hooksPath, 서버 훅 개념, CI 연동 개념, alias |
| D13 | 서브모듈·다중 저장소 | submodule add/update/clone --recursive, 상태 읽기, subtree 개념, worktree, 모노레포 vs 멀티레포 |
| D14 | 설정·속성 | config 범위·우선순위, includeIf, .gitattributes(줄바꿈·diff·LFS), autocrlf, mergetool/difftool |
| D15 | 내부 구조 | .git 구조, 객체(blob/tree/commit/tag), refs, packfile, cat-file/hash-object, gc/prune/fsck, 도달 가능성 |
| D16 | 저장소 유지보수·대용량 | shallow/partial clone, sparse-checkout, LFS, 큰 파일·비밀 이력 제거(filter-repo/BFG), 저장소 크기 진단 |
| D17 | 장애 대응(상황집) | 인증 실패, push 거절 계열, divergent, 병합/rebase 중단, 잃은 커밋, 비밀 유출, CRLF 이슈, 대용량 push 실패, detached HEAD, 잘못된 브랜치 커밋 |

## 커버리지 표

깊이: 없음 / 얕음(개념 한 줄·퀴즈 1문항) / 보통 / 충분. 형식: Q=개념 퀴즈만, T=터미널 실습 포함.
세트 정보: 퀴즈 세트 = 선택 14 + 빈칸 1 + 순서 1(1/2 쌍은 대부분 빈칸 10·순서 4 변형), 터미널 세트 = 터미널 4~9 + 선택/빈칸/순서 소량.

| 영역·주제 | 다루는 세트 | 깊이 | 형식 |
|---|---|---|---|
| D1 3영역 개념 | 138·315 | 보통 | Q |
| D1 config 기본 | 52(config), 143, 188·325(범위·우선순위), 486 | 충분 | T(52·486)+Q |
| D1 설치·도움말·기본 브랜치명 | - | 없음 | - |
| D2 init/status/add/commit/diff/log | 52, 365, 138 | 충분 | T |
| D2 부분 커밋 -p | 52, 168(add -p), 176 | 보통 | T(52 일부)+Q |
| D2 rm/mv/clean | 149·317, 373 | 보통 | Q+T(373 clean) |
| D2 .gitignore | 96, 52, 161, 176(info/exclude) | 충분 | T |
| D2 커밋 메시지 쓰기 규약 | - (명령만, 규약은 없음) | 없음 | - |
| D3 브랜치 만들기·전환·삭제 | 53, 138, 143, 168(-vv, --merged), 491(-m) | 충분 | T |
| D3 detached HEAD | 155, 95(T) | 보통 | Q+T |
| D4 ff/병합 커밋/충돌 | 53, 477(T), 184·324 | 충분 | T |
| D4 --no-ff/--squash/--abort | 155·318, 373, 477 | 충분 | Q+T |
| D4 -X/-s/ours/theirs/rerere | 184·324, 477 | 충분 | Q+T |
| D4 mergetool/difftool | - | 없음 | - |
| D5 rebase/-i/--onto/fixup | 161·319, 373, 176·322, 172·321, 476(T) | 충분 | Q+T |
| D5 cherry-pick | 143, 368(T), 176 | 충분 | T |
| D5 amend/reword | 143, 56, 476, 495 | 보통 | T |
| D6 clone/remote/fetch/pull/push | 54(T), 94(T), 143, 149, 155, 495(T) | 충분 | T |
| D6 upstream·push -u·추적 브랜치 | 54, 149, 184, 495 | 충분 | T |
| D6 push 거절/divergent/force-with-lease | 54, 95, 155, 495, 56 | 충분 | T |
| D6 pull.rebase·ff-only 설정 정책 | 155, 184(pull --ff-only), 95 | 보통 | Q |
| D6 원격 URL 바꾸기·여러 원격(upstream 포크) | 155(remote set-url) | 얕음 | Q |
| D7 https vs ssh 개념 | - | 없음 | - |
| D7 SSH 키 생성·등록·테스트 | - | 없음 | - |
| D7 credential helper·토큰 | - | 없음 | - |
| D7 인증 오류 메시지 읽기 | - | 없음 | - |
| D8 restore/reset/revert | 56(T), 138, 143, 161, 200, 149 | 충분 | T(56)+Q |
| D8 reflog 복구·삭제 브랜치 복구 | 56, 95, 180 | 보통 | T |
| D8 stash 전반 | 368, 495, 149, 200 | 충분 | T |
| D9 log/show/diff/blame | 365(T), 149, 176, 192, 196 | 충분 | T |
| D9 -S/-G/-L/bisect | 373, 95, 180, 196 | 보통 | T |
| D9 log --graph·범위 ..· ... | 172·321, 192 | 보통 | Q |
| D9 shortlog/grep/describe | 491(T), 192 | 보통 | T |
| D10 경량·주석 태그, push·삭제 | 368(T), 143, 200, 495 | 충분 | T |
| D10 SemVer·릴리스 노트 흐름 | - | 없음 | - |
| D10 서명(GPG/SSH) 태그·커밋 | - | 없음 | - |
| D10 archive | 180, 491 | 보통 | T |
| D11 PR/MR 리뷰 흐름 | - | 없음 | - |
| D11 브랜치 전략(Gitflow/트렁크/기능) | - | 없음 | - |
| D11 포크 모델·upstream 동기화 | - | 없음 | - |
| D11 보호 브랜치·리뷰 규칙 개념 | - | 없음 | - |
| D11 패치 메일 format-patch/am/apply | 192·326, 486(T) | 보통 | T |
| D12 클라이언트 훅·hooksPath | 180·323, 491(pre-commit T) | 보통 | Q+T(1개) |
| D12 commit-msg/pre-push 실습 | 180(Q) | 얕음 | Q |
| D12 서버 훅·CI 연동 개념 | - | 없음 | - |
| D12 alias | 373, 188, 486 | 보통 | T |
| D13 submodule | 172·321 (기본 개념 Q) | 얕음 | Q |
| D13 subtree | - | 없음 | - |
| D13 worktree | 172, 491(T) | 보통 | T |
| D13 모노레포/멀티레포 | - | 없음 | - |
| D14 config 범위·includeIf·insteadOf | 188·325, 486(T) | 충분 | Q+T |
| D14 .gitattributes·줄바꿈 | 172·321 (autocrlf·.gitattributes) | 얕음 | Q |
| D14 LFS 속성 | - | 없음 | - |
| D15 객체·cat-file·tree·ls-tree | 168·320, 486(T 일부) | 보통 | Q+T |
| D15 .git 디렉터리 구조 | 188·486 일부 | 얕음 | - |
| D15 refs/update-ref/for-each-ref | 196·327, 486(T) | 보통 | Q+T |
| D15 packfile·gc·prune·fsck·도달 가능성 | 180·323(reflog expire·gc, fsck 언급) | 얕음 | Q |
| D16 shallow clone | 200 | 얕음 | Q |
| D16 sparse-checkout·partial clone | 196(제목에 sparse-checkout) | 얕음 | Q |
| D16 LFS | - | 없음 | - |
| D16 큰 파일/비밀 이력 제거 | 95(비밀 push 사고 대응, Q 1문항) | 얕음 | Q |
| D16 저장소 크기 진단(count-objects) | - | 없음 | - |
| D17 상황집(막혔을 때) | 95(T 6 + Q 8) | 보통 | T+Q |
| D17 인증 실패·대용량·CRLF 상황 | - | 없음 | - |

### 형식 현황 (실측)

- 문제 총 612개: 선택 245 / 빈칸 166 / 순서 81 / 터미널 120.
- 터미널 비중 약 20%. 세트 기준: 터미널 실습 세트 14개(52·53·54·56·94·95·96·365·368·373·476·477·486·491·495 중 15개), 퀴즈 전용 세트 28개(138~200 계열 + 315~328 쌍).
- 터미널 실습이 있는 세트는 모두 전반 개념 실습이다. 인증·서브모듈·훅(commit-msg/pre-push)·태그 서명·큰 파일 이력은 실습 0.

## 빈틈 목록(우선순위)

### 필수 (없으면 공개 곤란)

1. **인증·접근 (D7)**: SSH 키 생성·등록·`ssh -T`, https vs ssh URL, credential helper·토큰, 인증 오류 메시지 읽기. 근거: 전체 Git 세트 본문에 ssh/credential/token 용어 없음. 원격 작업(54·94·495)이 모두 로컬 bare 저장소만 사용해 인증 장애를 못 겪음.
2. **협업 워크플로 (D11)**: PR/MR 기반 흐름, 브랜치 전략, 포크·upstream 동기화, 보호 브랜치. 근거: 어떤 세트에도 PR·fork·gitflow·trunk 용어 없음. 사내 운영자가 가장 먼저 만나는 "팀에서 어떻게 일하는가"가 비어 있음.
3. **입문 순서·징검다리 (D1·D3)**: 단원 12 의 실습(52)이 맨 뒤이고 개념 퀴즈가 먼저. 3영역을 손으로 확인하는 짧은 실습과 브랜치 맛보기 부재(감사 bridge_sets 와 동일). 근거: 단원 12 `order_in_unit` 높음, `prereq_gap`.
4. **상황집 확충 (D17)**: 현 상황집 95 하나. 인증 실패·대용량·CRLF·merge 후 되돌리기·원격 사고 등이 빠짐. (아래 `## 상황집` 참조.)
5. **서브모듈 실습 (D13)**: 퀴즈 1세트(172·321)에서 개념만. 현장(외부 라이브러리·차트·플레이북 포함 저장소)에서 흔히 만나며 `clone` 후 폴더가 비어 있는 증상이 대표 장애.

### 권장

6. **저장소 내부 실습 (D15)**: .git 구조 탐험, 객체 만들어 보기(hash-object·write-tree·commit-tree), packfile·gc·fsck·prune·도달 가능성. 근거: 168·320 은 퀴즈, 486 은 cat-file 일부뿐.
7. **큰 파일·비밀 이력 제거·LFS (D16)**: filter-repo 개념과 실습, LFS 기본, `count-objects`·`rev-list --objects` 로 큰 객체 찾기. 근거: 95 에 사고 대응 1문항(Q)만.
8. **훅 실습 심화 (D12)**: commit-msg·pre-push·core.hooksPath 실습, 서버 훅/CI 연동 개념. 근거: 491 의 pre-commit 1개만 실습.
9. **커밋 메시지 규약·릴리스 (D2·D10)**: 좋은 커밋 메시지, Conventional Commits 개념, SemVer 태그, 릴리스 노트 흐름. 근거: 없음.
10. **.gitattributes·줄바꿈 상황 (D14)**: CRLF/LF 혼재로 diff 전체가 바뀌는 문제 재현·해결. 근거: 172·321 Q 문항뿐.
11. **여러 원격·URL 전환 (D6)**: origin/upstream 두 원격, set-url 로 https↔ssh 전환, 원격 이름 바꾸기·삭제. 근거: 155 에서 set-url 1문항.
12. **shallow/partial clone·sparse-checkout 실습 (D16)**: 큰 저장소를 빠르게 받는 법. 근거: 200·196 Q 1~2문항.
13. **mergetool/difftool·`git add -N`·`diff --check`·`blame --ignore-rev` (D4·D9)**: 일상 보조 도구. 근거: 없음.
14. **서명 커밋·태그 (D10)**: SSH/GPG 서명, `verify`. 근거: 없음. (사내에서 요구하는 경우만 필수 → 추정)

### 선택

15. subtree 개념, 모노레포/멀티레포 비교 (D13).
16. `git notes`·`replace`·`bundle` 심화 (현 180에서 얕게 다룸).
17. 설치·`git help`·`init.defaultBranch` 같은 환경 세팅 (D1) — 기존 config 세트로 부분 커버.
18. packed-refs·pack 인덱스 상세, `git cat-file --batch` (D15).

## 신규 세트 백로그

세트 번호는 미정. "들어갈 단원"의 id 는 기존 단원 id. 터미널 실습 세트는 선택 2~3 + 터미널 6~9 구성 권장(기존 53·54 형식).

| 우선순위 | 제목 | 형식 | 들어갈 단원 | 선행 | 핵심 개념(계단식) | 예상 문제 수 |
|---|---|---|---|---|---|---|
| 필수 | Git 저장소 한눈에: 작업 폴더·스테이징·저장소를 직접 확인 | 터미널 실습(짧게) | 12 기초, 세트 52 바로 뒤 | 52 | status 로 3영역 이동 보기 → add 전/후, commit 후 비교 → diff vs diff --staged | 6~7 |
| 필수 | 브랜치·병합 맛보기: 만들고 커밋하고 합치기 | 터미널 실습(짧게) | 12 기초 마지막(143 뒤) 또는 14 앞머리 | 52 | switch -c, 브랜치별 커밋, merge fast-forward, branch -d | 6 |
| 필수 | Git 인증 첫걸음: https 와 ssh, 어느 쪽으로 연결됐나 | 개념 퀴즈+터미널(원격 -v) | 15 원격과 협업 (54 뒤, 94 앞) | 54 | 원격 URL 두 형태 → remote -v 읽기 → set-url 로 전환 → 인증 방식이 다르면 생기는 일 | 8~9 |
| 필수 | SSH 키로 연결하기: 키 만들고 등록하고 확인하기 | 터미널 실습 | 15 | 위 세트 | ssh-keygen(ed25519) → 공개키·비밀키 구분 → ~/.ssh/config → ssh -T 로 확인 → known_hosts | 9 |
| 필수 | 인증 오류 상황집: Permission denied, Authentication failed, Host key | 상황집 | 17 (95 와 별도 세트) | SSH 실습 | 오류 메시지 읽기 → 키 미등록/권한(chmod 600)/잘못된 사용자 → credential helper 오염 → 토큰 만료 → host key 변경 경고 | 8~9 |
| 필수 | 팀에서 Git 쓰는 흐름: 기능 브랜치와 PR 리뷰 | 개념 퀴즈(순서·사례형) | 신규 단원 "협업 워크플로"(15 뒤, 17 앞) | 54, 53 | 기능 브랜치 → PR/MR 흐름 → 리뷰 후 squash/rebase/merge 선택 → 보호 브랜치 → 병합 후 브랜치 정리 | 14 |
| 필수 | 포크·upstream 동기화 실습 | 터미널 실습 | 신규 단원 "협업 워크플로" | 위 세트, 54 | 원격 두 개(origin·upstream) → fetch upstream → 내 main 맞추기 → 기능 브랜치 rebase → force-with-lease | 8~9 |
| 필수 | 브랜치 전략 비교: 기능 브랜치·Gitflow·트렁크 기반 | 개념 퀴즈(사례형) | 신규 단원 "협업 워크플로" | 팀 흐름 퀴즈 | 장기 브랜치 vs 짧은 브랜치 → 릴리스 브랜치 → hotfix 흐름 → 언제 어떤 전략 | 12 |
| 필수 | Git 서브모듈 손연습: 추가·복제·갱신 | 터미널 실습 | 신규 또는 49(172 뒤)·15 근처 | 54, 172 | submodule add → clone 후 폴더가 빈 이유 → --recursive/update --init → 서브모듈 커밋 위치 고정 → status 로 포인터 변경 읽기 | 8~9 |
| 필수 | Git 상황집 2: 원격·병합·되돌리기 사고에서 빠져나오기 | 상황집(터미널) | 17 (95 뒤) | 56, 95 | non-fast-forward, 병합 후 잘못 push, revert -m 1, 잘못된 force push 복구(reflog+원격), CRLF 로 전체 diff, 커밋 작성자 정정 | 8~9 |
| 권장 | .git 안을 열어 보기: 객체·refs·HEAD 손으로 만들기 | 터미널 실습 | 50 (168 뒤) | 168 | .git 폴더 구성 → hash-object·cat-file → write-tree·commit-tree·update-ref 로 커밋 직접 만들기 | 8~9 |
| 권장 | 저장소 정리와 건강 진단: gc·fsck·prune·count-objects | 터미널 실습 | 50 | 위 세트, 180 | loose vs packed → gc → unreachable → reflog expire + prune → fsck 로 dangling 찾기 | 8 |
| 권장 | 큰 파일과 비밀이 이력에 들어갔을 때: filter-repo 와 LFS | 터미널 실습+개념 | 17 또는 50 | 95, 위 세트 | rev-list --objects 로 큰 객체 찾기 → filter-repo 로 파일 제거 → 강제 push 와 협업자 재동기화 → LFS 추적 → .gitattributes | 9 |
| 권장 | Git 훅 손연습 2: commit-msg·pre-push·hooksPath | 터미널 실습 | 50 (491 뒤) | 180, 491 | commit-msg 형식 검사 → pre-push 로 테스트 강제 → core.hooksPath 로 팀 공유 → --no-verify 의 위험 → 서버 훅 개념 | 8 |
| 권장 | 좋은 커밋 메시지와 릴리스 태그 | 개념 퀴즈+터미널 | 12 기초 또는 14(368 뒤) | 52, 368 | 제목·본문 규칙 → Conventional Commits → SemVer 태그 → 릴리스 노트(log 범위) | 10 |
| 권장 | 줄바꿈·.gitattributes 상황집: CRLF 와 LF | 상황집(터미널) | 50 (188 뒤) | 188, 172 | 전체 줄이 바뀐 diff 재현 → autocrlf 와 .gitattributes eol → renormalize → 실행 비트 mode 변경 | 7~8 |
| 권장 | 원격 여러 개·URL 정리 | 터미널 실습 | 15 | 54 | remote add/rename/remove → 원격별 fetch → pull.rebase·ff-only 기본값 | 7 |
| 권장 | 큰 저장소 빨리 받기: shallow·partial·sparse | 터미널 실습 | 50 또는 15 | 54, 200 | clone --depth → fetch --unshallow → --filter=blob:none → sparse-checkout | 7 |
| 선택 | 병합·diff 도구: mergetool, difftool, add -N, diff --check, blame --ignore-rev | 터미널 실습 | 49 | 477 | 보조 도구 | 7 |
| 선택 | 서명 커밋·태그 | 개념+터미널 | 14 또는 15 | 368 | commit -S, tag -s, verify | 6 |
| 선택 | 복습: Git 기본기 종합(기초~원격) | 복습 | 15 끝 | 54, 95 | 시험형 혼합 | 14~16 |
| 선택 | 복습: 되돌리기·이력 편집 종합 | 복습 | 17 끝 | 56, 476, 95 | 시험형 혼합 | 14~16 |

신규 세트 합계: 필수 10개, 권장 8개, 선택 4개 = 22개. 단, 필수 10개 중 2개(징검다리)는 짧은 세트이고 우선 제작 대상이다. 제작 순서 권고는 징검다리 2 → 인증 3(URL·SSH·오류 상황집) → 협업 3 → 서브모듈 → 상황집 2.

## 형식 균형

- 현황: 터미널 약 20%(120/612). 분야 성격상(명령 중심) 목표는 **터미널 40~50%**. 현재 퀴즈 28세트는 객관식/빈칸 중심으로 명령 이름 암기에 치우친다.
- 퀴즈 전용이지만 실습이 필요한 영역: ① 3영역·status 해석(138·315 만으로 처음 접함) ② 서브모듈(172·321) ③ 클라이언트 훅 commit-msg/pre-push(180·323) ④ 객체/packfile/gc/fsck(168·180) ⑤ .gitattributes·줄바꿈(172) ⑥ config 범위·includeIf·insteadOf(188·325 만 퀴즈, 486 이 일부 보완) ⑦ 로그 그래프·범위 `..`/`...`(172·192) ⑧ shallow·sparse.
- 권고: 각 퀴즈 쌍(1/2·2/2) 뒤에 짝이 되는 실습 세트를 1개씩 두는 현재 흐름(476·477·486·491·495)을 유지하되, 위 ①~⑧ 은 실습으로 전환. 쌍 세트의 (2/2) 는 같은 개념 반복(빈칸 10·순서 4)이므로 **새 쌍 퀴즈를 늘리기보다 터미널 실습을 우선**.
- 한 세트 형식 3종 이상 원칙: 기존 퀴즈 28세트는 선택+빈칸+순서 3종 충족. 터미널 세트는 터미널+선택 위주(담당 94·95·96 제외)라 순서/빈칸 보강 여지(추정).
- 권장 비율(신규): 터미널 실습 6 : 상황집 2 : 개념 퀴즈 2 정도.

## 상황집

- 현재: **95 "Git 문제 해결 상황집"** 1개. 구성은 터미널 6(잘못된 브랜치 커밋 옮기기, detached HEAD 커밋 살리기, 추적 중인 로그 끊기, 병합 중단, 문자열이 처음 들어온 커밋 찾기, 삭제 브랜치 복구) + 퀴즈 8(would be overwritten, divergent branches, 비밀 push 등). 질이 높으나 1개뿐이라 "오류 메시지 → 원인 → 해결" 폭이 부족. 94 도 첫 push 오류 4종(user 미설정·src refspec·remote already exists·거절)을 다루는 소형 상황집 역할.
- 보강 필요한 시나리오(우선순위 순):
  1. **인증 계열**: `Permission denied (publickey)`, `Authentication failed`/토큰 만료, `Host key verification failed`, `REMOTE HOST IDENTIFICATION HAS CHANGED`, credential helper 가 옛 비밀번호 기억.
  2. **push 계열**: `non-fast-forward`(rejected), 보호 브랜치 거절, 100MB 초과 파일 거절, 잘못된 force push 후 복구.
  3. **병합·rebase 계열**: 병합 후 문제 발견 → revert -m 1 → 다시 병합할 때 "이미 반영됨" 현상, rebase 중 `detached HEAD`·`You are in the middle of a rebase`, `fatal: refusing to merge unrelated histories`.
  4. **작업 폴더 계열**: `index.lock` 존재, `fatal: not a git repository`, `.git` 손상(fsck), 서브모듈 폴더가 빈 문제, CRLF 로 전체 diff, 파일 권한 비트 diff, 한글 파일명 `\355\225...` 이스케이프.
  5. **이력 사고**: 비밀·대용량 파일 이력 제거, 작성자 이름·이메일 잘못 커밋(`--amend --reset-author`, rebase -x), 커밋 시간·타임존.
- 권고: 상황집 세트 최소 3개로 확대(현 95 + 인증 + 원격·병합 사고) 후 필요 시 장애 계열별 추가.
