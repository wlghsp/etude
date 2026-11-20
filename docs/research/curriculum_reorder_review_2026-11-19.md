# 세트 순서 변경 검토 — 2026-11-19

커리큘럼 감사가 제안한 **세트 표시 순서 변경**을 단원별로 비교한다. 적용하면 `quest_set.display_order` 만 바뀐다(세트 ID·문제·진행 기록 영향 없음). 단원 안에서 그 단원이 쓰던 순서 자리를 다시 배분하므로 **다른 단원의 위치는 그대로**다.

- 검증: 40개 제안 모두 현재 단원의 세트 구성과 정확히 일치(빠지거나 늘어난 세트 없음), (1/2)·(2/2) 쌍은 모두 붙어 있음.
- 근거는 감사 에이전트의 판단이다. 대부분 세트 제목·설명 위주로 읽어 **"추정"이 섞여 있다.** 각 단원의 `[ ]` 를 보고 **적용 / 제외** 를 표시해 달라.
- 이동 수: 이동한 세트 수(위치가 달라진 세트).

## 한눈에 보기

| 코스 | 단원 | 점수 | 이동 | 세트 수 |
|---|---|---|---|---|
| Git | 병합과 이력 다듬기 심화 | 2 | 12 | 12 |
| Git | 설정·패치·내부 구조 | 2 | 9 | 12 |
| Git | 기초 | 3 | 8 | 10 |
| OpenStack | 인스턴스 | 3 | 5 | 5 |
| OpenStack | 인증과 운영 | 3 | 2 | 4 |
| OpenStack | 오브젝트와 자동화 | 4 | 2 | 4 |
| k8s | 컨테이너 실행·재시작·Deployment 읽기 | 2 | 13 | 13 |
| k8s | 스케줄링과 워크로드 실습 | 2 | 11 | 11 |
| k8s | 스토리지와 네트워크 | 2 | 10 | 10 |
| k8s | 롤아웃·Pod 스펙·Kustomize·ConfigMap | 2 | 8 | 12 |
| k8s | 기초 | 3 | 7 | 8 |
| k8s | kubectl 실습 기초 | 3 | 6 | 8 |
| k8s | 워크로드와 설정 | 3 | 6 | 11 |
| k8s | 운영과 트러블슈팅 | 3 | 6 | 10 |
| k8s | 클러스터 운영·보안 | 3 | 2 | 4 |
| 가상화 | qemu-img·장치 설정·virsh 객체 명령 | 3 | 4 | 10 |
| 네트워크 | ip·ss·tc 도구 다루기 | 2 | 8 | 8 |
| 네트워크 | 네트워크 기초 | 3 | 5 | 8 |
| 데이터베이스 | MariaDB 운영 | 2 | 8 | 10 |
| 도커 | 컨테이너 조회·종료 코드·실습 | 2 | 10 | 12 |
| 도커 | 컨테이너 다루기 | 2 | 8 | 11 |
| 도커 | Dockerfile 심화와 이미지 실습 | 3 | 7 | 9 |
| 도커 | Compose와 운영 | 2 | 6 | 7 |
| 도커 | 네트워크와 볼륨 | 3 | 5 | 9 |
| 도커 | Docker 기초 | 4 | 4 | 5 |
| 리눅스 | 텍스트·파일 도구 심화 | 2 | 11 | 11 |
| 리눅스 | 쉘 스크립트와 작업 제어 | 2 | 10 | 11 |
| 리눅스 | 운영과 장애 대응 | 2 | 7 | 9 |
| 리눅스 | 기초 | 2 | 6 | 10 |
| 리눅스 | 명령어 한 줄씩 2: 로그·쉘·텍스트 | 2 | 6 | 10 |
| 리눅스 | 네트워크와 통신 | 3 | 5 | 6 |
| 리눅스 | 운영 도구 한 줄씩: 성능·스케줄·sed·awk | 2 | 4 | 10 |
| 리눅스 | 도구 다루기 | 3 | 2 | 10 |
| 미들웨어 | 로드밸런서 | 3 | 5 | 7 |
| 미들웨어 | 관측 (모니터링·로그) | 3 | 4 | 5 |
| 미들웨어 | 검색·로그 저장 | 3 | 2 | 5 |
| 미들웨어 | 사내 장애 사례 | 3 | 2 | 2 |
| 스토리지 | 스토리지 기초 | 2 | 10 | 10 |
| 스토리지 | 파일시스템과 마운트 도구 | 3 | 8 | 9 |
| 스토리지 | 스왑·XFS·파티션 도구 | 2 | 7 | 8 |

## [Git] 병합과 이력 다듬기 심화  (단원 id 49, 점수 2, 이동 12/12)

- 이유: rebase(161)를 먼저 가르치고, 병합·원격(155)→충돌 도구(184)→손연습(477)→보조 도구(172)→옮기기(176)→rebase 손연습(476) 순으로. 원격 부분은 원격 단원 뒤로 옮기는 안도 검토.

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #155 병합 방식, 원격 관리, detached HEAD, 안전한 푸시 한 줄씩 (1/2) | **#161 이력 다듬기, rebase 충돌, 병합 되돌리기, 무시 규칙, 이력 검색 한 줄씩 (1/2) (↑2)** ➜ |
| 2 | #318 병합 방식, 원격 관리, detached HEAD, 안전한 푸시 한 줄씩 (2/2) | **#319 이력 다듬기, rebase 충돌, 병합 되돌리기, 무시 규칙 확인, 되살리기 한 줄씩 (2/… (↑2)** ➜ |
| 3 | #161 이력 다듬기, rebase 충돌, 병합 되돌리기, 무시 규칙, 이력 검색 한 줄씩 (1/2) | **#155 병합 방식, 원격 관리, detached HEAD, 안전한 푸시 한 줄씩 (1/2) (↓2)** ➜ |
| 4 | #319 이력 다듬기, rebase 충돌, 병합 되돌리기, 무시 규칙 확인, 되살리기 한 줄씩 (2/… | **#318 병합 방식, 원격 관리, detached HEAD, 안전한 푸시 한 줄씩 (2/2) (↓2)** ➜ |
| 5 | #172 worktree, fixup, 범위 비교(.. 와 ...), 줄바꿈 정책, 서브모듈 기본 한… | **#184 병합 전략과 충돌 도구: --ff-only, -X·-s, --ours·--theirs, re… (↑4)** ➜ |
| 6 | #321 worktree, fixup, 범위 비교(.. 와 ...), 줄바꿈 정책, 서브모듈 기본 한… | **#324 병합 전략과 충돌 도구: --ff-only, -X·-s, --ours·--theirs, re… (↑4)** ➜ |
| 7 | #176 rebase --onto, cherry-pick 옵션, 덩어리 선택(-p), log 필터와 … | **#477 Git 병합 충돌 손연습: 충돌 해결, merge --abort, --ours·--their… (↑5)** ➜ |
| 8 | #322 rebase --onto, cherry-pick 옵션, 덩어리 선택(-p), log 필터와 … | **#172 worktree, fixup, 범위 비교(.. 와 ...), 줄바꿈 정책, 서브모듈 기본 한… (↓3)** ➜ |
| 9 | #184 병합 전략과 충돌 도구: --ff-only, -X·-s, --ours·--theirs, re… | **#321 worktree, fixup, 범위 비교(.. 와 ...), 줄바꿈 정책, 서브모듈 기본 한… (↓3)** ➜ |
| 10 | #324 병합 전략과 충돌 도구: --ff-only, -X·-s, --ours·--theirs, re… | **#176 rebase --onto, cherry-pick 옵션, 덩어리 선택(-p), log 필터와 … (↓3)** ➜ |
| 11 | #476 Git rebase 손연습: --onto, fixup·autosquash, squash·re… | **#322 rebase --onto, cherry-pick 옵션, 덩어리 선택(-p), log 필터와 … (↓3)** ➜ |
| 12 | #477 Git 병합 충돌 손연습: 충돌 해결, merge --abort, --ours·--their… | **#476 Git rebase 손연습: --onto, fixup·autosquash, squash·re… (↓1)** ➜ |

## [Git] 설정·패치·내부 구조  (단원 id 50, 점수 2, 이동 9/12)

- 이유: 객관 기초(내부 구조·설정·검색/패치·참조)→손연습 486 → 보조 도구(훅·archive)·491 순으로, 개념 퀴즈 후 대응 손연습이 바로 이어지게 한다(추정, 선택 사항).

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #168 Git 객체와 이력 주소 읽기, 부분 스테이징, 브랜치 정리 한 줄씩 (1/2) | #168 Git 객체와 이력 주소 읽기, 부분 스테이징, 브랜치 정리 한 줄씩 (1/2) |
| 2 | #320 Git 객체와 이력 주소 읽기, 부분 스테이징, 브랜치 정리 한 줄씩 (2/2) | #320 Git 객체와 이력 주소 읽기, 부분 스테이징, 브랜치 정리 한 줄씩 (2/2) |
| 3 | #180 Git 훅, archive, bundle, 잃은 커밋 찾기, notes, assume-unc… | **#188 git config 다루기: 범위·우선순위, --show-origin, 별칭, include… (↑2)** ➜ |
| 4 | #323 Git 훅, archive, bundle, 잃은 커밋 찾기, notes, assume-unc… | **#325 git config 다루기: 범위·우선순위, --show-origin, 별칭, include… (↑2)** ➜ |
| 5 | #188 git config 다루기: 범위·우선순위, --show-origin, 별칭, include… | **#192 검색과 패치: git grep, rev-parse, symbolic-ref, describe… (↑2)** ➜ |
| 6 | #325 git config 다루기: 범위·우선순위, --show-origin, 별칭, include… | **#326 검색과 패치: git grep, rev-parse, symbolic-ref, describe… (↑2)** ➜ |
| 7 | #192 검색과 패치: git grep, rev-parse, symbolic-ref, describe… | **#196 참조와 변경 목록: for-each-ref, show-ref, update-ref, --na… (↑2)** ➜ |
| 8 | #326 검색과 패치: git grep, rev-parse, symbolic-ref, describe… | **#327 참조와 변경 목록: for-each-ref, show-ref, update-ref, --na… (↑2)** ➜ |
| 9 | #196 참조와 변경 목록: for-each-ref, show-ref, update-ref, --na… | **#486 Git 설정·패치·내부 구조 손연습: config --show-origin·alias·inc… (↑2)** ➜ |
| 10 | #327 참조와 변경 목록: for-each-ref, show-ref, update-ref, --na… | **#180 Git 훅, archive, bundle, 잃은 커밋 찾기, notes, assume-unc… (↓7)** ➜ |
| 11 | #486 Git 설정·패치·내부 구조 손연습: config --show-origin·alias·inc… | **#323 Git 훅, archive, bundle, 잃은 커밋 찾기, notes, assume-unc… (↓7)** ➜ |
| 12 | #491 Git 작업공간과 조회 도구 손연습: worktree, grep -n, shortlog -s… | #491 Git 작업공간과 조회 도구 손연습: worktree, grep -n, shortlog -s… |

## [Git] 기초  (단원 id 12, 점수 3, 이동 8/10)

- 이유: 개념 입문 퀴즈(138)→직접 실습(52)→설정·복제·이력(143)→.gitignore 실습(96)→비교·stash(149)→일상 명령 정리(200) 순으로 실습을 앞당긴다.

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #138 기록하고, 갈라지고, 합치고, 되돌리기 한 줄씩 (1/2) | #138 기록하고, 갈라지고, 합치고, 되돌리기 한 줄씩 (1/2) |
| 2 | #315 기록하고, 갈라지고, 합치고, 되돌리기 한 줄씩 (2/2) | #315 기록하고, 갈라지고, 합치고, 되돌리기 한 줄씩 (2/2) |
| 3 | #143 설정, 복제, 이력 다루기 한 줄씩 (1/2) | **#52 Git 기초: 저장소 만들고 기록하기 (↑6)** ➜ |
| 4 | #316 설정, 복제, 이력 다루기 한 줄씩 (2/2) | **#143 설정, 복제, 이력 다루기 한 줄씩 (1/2) (↓1)** ➜ |
| 5 | #149 이력 비교, 변경 정리, stash, 원격 연결 한 줄씩 (1/2) | **#316 설정, 복제, 이력 다루기 한 줄씩 (2/2) (↓1)** ➜ |
| 6 | #317 이력 비교, 변경 정리, stash, 원격 연결 한 줄씩 (2/2) | **#96 Git .gitignore: 올리면 안 되는 파일 다루기 (↑4)** ➜ |
| 7 | #200 Git 일상 명령 정리: commit -a, add -A, stash, restore, re… | **#149 이력 비교, 변경 정리, stash, 원격 연결 한 줄씩 (1/2) (↓2)** ➜ |
| 8 | #328 Git 일상 명령 정리: commit -a, add -A, stash, restore, re… | **#317 이력 비교, 변경 정리, stash, 원격 연결 한 줄씩 (2/2) (↓2)** ➜ |
| 9 | #52 Git 기초: 저장소 만들고 기록하기 | **#200 Git 일상 명령 정리: commit -a, add -A, stash, restore, re… (↓2)** ➜ |
| 10 | #96 Git .gitignore: 올리면 안 되는 파일 다루기 | **#328 Git 일상 명령 정리: commit -a, add -A, stash, restore, re… (↓2)** ➜ |

## [OpenStack] 인스턴스  (단원 id 37, 점수 3, 이동 5/5)

- 이유: 만들기(356) → 상태(355) → 플레이버 심화(412) → CPU 고정(413) → 스케줄링·이동(384, resize 가 플레이버에 의존)

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #355 OpenStack 인스턴스의 일생: 상태와 기본 동작 | **#356 서버를 만들 때 고르는 것들: 플레이버·이미지·키페어·보안 그룹 (↑1)** ➜ |
| 2 | #356 서버를 만들 때 고르는 것들: 플레이버·이미지·키페어·보안 그룹 | **#355 OpenStack 인스턴스의 일생: 상태와 기본 동작 (↓1)** ➜ |
| 3 | #384 Nova 스케줄링과 인스턴스 이동: 필터·Placement, 호스트 집합, 가용 영역, 서버… | **#412 Nova 플레이버 깊게: 생성 속성, extra specs, 비공개 접근, 수정·resize (↑1)** ➜ |
| 4 | #412 Nova 플레이버 깊게: 생성 속성, extra specs, 비공개 접근, 수정·resize | **#413 Nova CPU 고정과 NUMA: cpu_policy, thread policy, 토폴로지,… (↑1)** ➜ |
| 5 | #413 Nova CPU 고정과 NUMA: cpu_policy, thread policy, 토폴로지,… | **#384 Nova 스케줄링과 인스턴스 이동: 필터·Placement, 호스트 집합, 가용 영역, 서버… (↓2)** ➜ |

## [OpenStack] 인증과 운영  (단원 id 40, 점수 3, 이동 2/4)

- 이유: CLI 인증(362)을 먼저 알아야 361의 명령 문제를 풀 수 있음. 단 361 기초 개념을 먼저 두려면 현 순서 유지도 가능(중간 확신).

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #361 Keystone 기초: 도메인·프로젝트·사용자·역할과 토큰 | **#362 openstack 명령과 문제 살펴보기: 인증 정보·로그 위치·읽는 순서 (↑1)** ➜ |
| 2 | #362 openstack 명령과 문제 살펴보기: 인증 정보·로그 위치·읽는 순서 | **#361 Keystone 기초: 도메인·프로젝트·사용자·역할과 토큰 (↓1)** ➜ |
| 3 | #387 Keystone 심화: Fernet 토큰과 키 회전, 토큰 범위, 애플리케이션 자격증명, 연합 | #387 Keystone 심화: Fernet 토큰과 키 회전, 토큰 범위, 애플리케이션 자격증명, 연합 |
| 4 | #389 Nova 장애 해석과 복구: 로그, 흔한 원인, 멈춘 인스턴스, rescue, 어피니티 위반 | #389 Nova 장애 해석과 복구: 로그, 흔한 원인, 멈춘 인스턴스, rescue, 어피니티 위반 |

## [OpenStack] 오브젝트와 자동화  (단원 id 41, 점수 4, 이동 2/4)

- 이유: 같은 서비스끼리 연속 배치(Swift 기초→심화, Heat 기초→심화)해 학습 맥락 유지.

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #363 Swift 기초: 계정·컨테이너·객체와 프록시·링 | #363 Swift 기초: 계정·컨테이너·객체와 프록시·링 |
| 2 | #364 Heat 와 Horizon 기초: 템플릿·스택과 대시보드 | **#391 Swift 깊게: 링과 파티션, 핸드오프, 대용량 객체(DLO·SLO), 만료, 이레이저 코딩 (↑1)** ➜ |
| 3 | #391 Swift 깊게: 링과 파티션, 핸드오프, 대용량 객체(DLO·SLO), 만료, 이레이저 코딩 | **#364 Heat 와 Horizon 기초: 템플릿·스택과 대시보드 (↓1)** ➜ |
| 4 | #392 Heat 심화: HOT 템플릿 구조, 파라미터 제약, 내장 함수, 삭제 정책, 환경 파일 | #392 Heat 심화: HOT 템플릿 구조, 파라미터 제약, 내장 함수, 삭제 정책, 환경 파일 |

## [k8s] 컨테이너 실행·재시작·Deployment 읽기  (단원 id 64, 점수 2, 이동 13/13)

- 이유: 실행 설정→재시작→Deployment/ReplicaSet 소유→배포 옵션 순으로 의존시키고, 단원 주제와 별개인 ConfigMap·kubectl 도구 모음은 뒤로 이동

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #208 ConfigMap·Secret·볼륨 기본: --from-file, base64, string… | **#214 컨테이너 실행과 점검: command·args, workingDir, 프로브, logs -c… (↑4)** ➜ |
| 2 | #309 ConfigMap·Secret·볼륨 기본: --from-file, --from-literal… | **#311 컨테이너 실행과 점검: command·args, workingDir, 프로브, logs -c… (↑4)** ➜ |
| 3 | #211 kubectl 도구 모음: cp, wait, replace·--force, apply 출력,… | **#220 Pod 종료와 재시작 정책: restartPolicy 3가지, CrashLoopBackOff… (↑6)** ➜ |
| 4 | #310 kubectl 도구 모음: cp, wait, replace·--force, apply 출력,… | **#313 Pod 종료와 재시작 정책: restartPolicy 3가지, CrashLoopBackOff… (↑6)** ➜ |
| 5 | #214 컨테이너 실행과 점검: command·args, workingDir, 프로브, logs -c… | **#483 k8s 컨테이너 실행과 재시작 손연습: command·args, $(VAR), working… (↑6)** ➜ |
| 6 | #311 컨테이너 실행과 점검: command·args, workingDir, 프로브, logs -c… | **#217 Deployment 와 ReplicaSet: 파드 이름, 소유 관계, 재생성, 직접 scal… (↑1)** ➜ |
| 7 | #217 Deployment 와 ReplicaSet: 파드 이름, 소유 관계, 재생성, 직접 scal… | **#312 Deployment 와 ReplicaSet: 파드 이름, 소유 관계, 재생성, 직접 scal… (↑1)** ➜ |
| 8 | #312 Deployment 와 ReplicaSet: 파드 이름, 소유 관계, 재생성, 직접 scal… | **#496 k8s Deployment 배포 옵션 손연습: Recreate, rollout pause·r… (↑5)** ➜ |
| 9 | #220 Pod 종료와 재시작 정책: restartPolicy 3가지, CrashLoopBackOff… | **#493 k8s Job·프로브·수명주기 설정 손연습: backoffLimit, activeDeadli… (↑3)** ➜ |
| 10 | #313 Pod 종료와 재시작 정책: restartPolicy 3가지, CrashLoopBackOff… | **#208 ConfigMap·Secret·볼륨 기본: --from-file, base64, string… (↓9)** ➜ |
| 11 | #483 k8s 컨테이너 실행과 재시작 손연습: command·args, $(VAR), working… | **#309 ConfigMap·Secret·볼륨 기본: --from-file, --from-literal… (↓9)** ➜ |
| 12 | #493 k8s Job·프로브·수명주기 설정 손연습: backoffLimit, activeDeadli… | **#211 kubectl 도구 모음: cp, wait, replace·--force, apply 출력,… (↓9)** ➜ |
| 13 | #496 k8s Deployment 배포 옵션 손연습: Recreate, rollout pause·r… | **#310 kubectl 도구 모음: cp, wait, replace·--force, apply 출력,… (↓9)** ➜ |

## [k8s] 스케줄링과 워크로드 실습  (단원 id 65, 점수 2, 이동 11/11)

- 이유: requests·nodeSelector·initContainer 를 먼저 가르친 뒤 Pending 진단, 그 다음 우선순위·분산으로 심화; ConfigMap·Helm 은 주제 무관이라 뒤로

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #223 Pending 원인 읽기: nodeSelector·nodeName, 노드 라벨, Insuff… | **#22 k8s 워크로드 기본 (↑3)** ➜ |
| 2 | #314 Pending 원인 읽기: nodeSelector·nodeName, 노드 라벨, Insuff… | **#375 여러 컨테이너가 든 Pod 손연습: 컨테이너 둘 만들기, logs·exec -c, empty… (↑5)** ➜ |
| 3 | #12 k8s ConfigMap과 Secret | **#351 리소스 requests·limits 손연습: set resources, QoS 등급, Lim… (↑3)** ➜ |
| 4 | #22 k8s 워크로드 기본 | **#223 Pending 원인 읽기: nodeSelector·nodeName, 노드 라벨, Insuff… (↓3)** ➜ |
| 5 | #236 설정 주입 실습: ConfigMap·Secret 만들기, 환경변수와 볼륨으로 주입, 설정 오… | **#314 Pending 원인 읽기: nodeSelector·nodeName, 노드 라벨, Insuff… (↓3)** ➜ |
| 6 | #351 리소스 requests·limits 손연습: set resources, QoS 등급, Lim… | **#420 Pod 우선순위와 선점: PriorityClass, globalDefault, preempt… (↑3)** ➜ |
| 7 | #375 여러 컨테이너가 든 Pod 손연습: 컨테이너 둘 만들기, logs·exec -c, empty… | **#421 Pod 토폴로지 분산 제약: maxSkew, topologyKey, whenUnsatisfi… (↑3)** ➜ |
| 8 | #383 Helm 차트 직접 만들기 손연습: create, show values, template, … | **#12 k8s ConfigMap과 Secret (↓5)** ➜ |
| 9 | #420 Pod 우선순위와 선점: PriorityClass, globalDefault, preempt… | **#236 설정 주입 실습: ConfigMap·Secret 만들기, 환경변수와 볼륨으로 주입, 설정 오… (↓4)** ➜ |
| 10 | #421 Pod 토폴로지 분산 제약: maxSkew, topologyKey, whenUnsatisfi… | **#499 k8s 워크로드 운영 옵션 손연습: DaemonSet OnDelete, CronJob 시간대… (↑1)** ➜ |
| 11 | #499 k8s 워크로드 운영 옵션 손연습: DaemonSet OnDelete, CronJob 시간대… | **#383 Helm 차트 직접 만들기 손연습: create, show values, template, … (↓3)** ➜ |

## [k8s] 스토리지와 네트워크  (단원 id 8, 점수 2, 이동 10/10)

- 이유: Service 입문→통신 손연습→DNS→CNI 개념 순으로 네트워크 블록을 묶고, 스토리지 실습→개념, 단원 주제와 무관한 26 은 맨 끝(또는 스케줄링 단원으로 이동)

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #80 k8s 네트워크와 외부 노출: CNI, Service, NodePort, NFS | **#108 k8s 통신 입문: Pod IP, Service, 이름 (↑4)** ➜ |
| 2 | #13 k8s 스토리지와 네트워크 | **#37 k8s 통신 방법 익히기 (↑4)** ➜ |
| 3 | #122 k8s 스토리지 개념: PV, PVC, StorageClass, 접근 모드 | **#25 k8s 서비스와 네트워킹 (↑1)** ➜ |
| 4 | #25 k8s 서비스와 네트워킹 | **#348 Service 손연습: expose, 엔드포인트와 EndpointSlice, 셀렉터·라벨, … (↑4)** ➜ |
| 5 | #108 k8s 통신 입문: Pod IP, Service, 이름 | **#422 Service 와 Pod 의 DNS: 이름 형식, search 목록, Headless, SR… (↑4)** ➜ |
| 6 | #37 k8s 통신 방법 익히기 | **#80 k8s 네트워크와 외부 노출: CNI, Service, NodePort, NFS (↓5)** ➜ |
| 7 | #26 k8s 스케줄링과 배포 전략 | **#489 k8s 서비스 노출과 볼륨 설정 손연습: Ingress 규칙·pathType, Externa… (↑3)** ➜ |
| 8 | #348 Service 손연습: expose, 엔드포인트와 EndpointSlice, 셀렉터·라벨, … | **#13 k8s 스토리지와 네트워크 (↓6)** ➜ |
| 9 | #422 Service 와 Pod 의 DNS: 이름 형식, search 목록, Headless, SR… | **#122 k8s 스토리지 개념: PV, PVC, StorageClass, 접근 모드 (↓6)** ➜ |
| 10 | #489 k8s 서비스 노출과 볼륨 설정 손연습: Ingress 규칙·pathType, Externa… | **#26 k8s 스케줄링과 배포 전략 (↓3)** ➜ |

## [k8s] 롤아웃·Pod 스펙·Kustomize·ConfigMap  (단원 id 63, 점수 2, 이동 8/12)

- 이유: 기초 kubectl(네임스페이스·조회·컨텍스트) → Pod 스펙 → 롤아웃·설정 주입 → Kustomize(개념→손연습) → 복합 손연습 순으로 의존이 쌓이도록

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #190 kubectl 컨텍스트·출력·삭제: config, --no-headers, 셀렉터, api-… | **#205 네임스페이스·조회·권한 기본: -n·-A, get all 범위, -o name, -w, --… (↑8)** ➜ |
| 2 | #304 kubectl 컨텍스트·출력·삭제: config, --no-headers, 셀렉터, api-… | **#308 네임스페이스·조회·권한 기본: -n·-A, get all 범위, -o name, -w, --… (↑8)** ➜ |
| 3 | #194 롤아웃 제어와 설정 주입: pause·resume, set env, undo, 진행 기한, … | **#190 kubectl 컨텍스트·출력·삭제: config, --no-headers, 셀렉터, api-… (↓2)** ➜ |
| 4 | #305 롤아웃 제어와 설정 주입: pause·resume, set env, undo, 진행 기한, … | **#304 kubectl 컨텍스트·출력·삭제: config, --no-headers, 셀렉터, api-… (↓2)** ➜ |
| 5 | #198 Pod 스펙 필드 읽기: command·args, $(VAR), startupProbe, t… | #198 Pod 스펙 필드 읽기: command·args, $(VAR), startupProbe, t… |
| 6 | #306 Pod 스펙 필드 읽기: command·args, startupProbe, fsGroup, … | #306 Pod 스펙 필드 읽기: command·args, startupProbe, fsGroup, … |
| 7 | #202 Kustomize 와 일회성 실행: apply -k, namePrefix, images, c… | **#194 롤아웃 제어와 설정 주입: pause·resume, set env, undo, 진행 기한, … (↓4)** ➜ |
| 8 | #307 Kustomize 와 일회성 실행: apply -k, namePrefix, images, c… | **#305 롤아웃 제어와 설정 주입: pause·resume, set env, undo, 진행 기한, … (↓4)** ➜ |
| 9 | #205 네임스페이스·조회·권한 기본: -n·-A, get all 범위, -o name, -w, --… | **#202 Kustomize 와 일회성 실행: apply -k, namePrefix, images, c… (↓2)** ➜ |
| 10 | #308 네임스페이스·조회·권한 기본: -n·-A, get all 범위, -o name, -w, --… | **#307 Kustomize 와 일회성 실행: apply -k, namePrefix, images, c… (↓2)** ➜ |
| 11 | #482 k8s Kustomize 손연습: kubectl kustomize, namePrefix, i… | #482 k8s Kustomize 손연습: kubectl kustomize, namePrefix, i… |
| 12 | #494 k8s Pod·볼륨·네트워크 설정 손연습: port-forward, emptyDir Memo… | #494 k8s Pod·볼륨·네트워크 설정 손연습: port-forward, emptyDir Memo… |

## [k8s] 기초  (단원 id 6, 점수 3, 이동 7/8)

- 이유: 개념 입문(41)→용어·명령(128/287)→YAML 읽기(46)→YAML 필드·상태(130/288)→구조(78)→운영 개념(79) 순으로 의존 순서에 맞춤.

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #128 용어와 kubectl 기본 명령 한 줄씩 (1/2) | **#41 k8s 개념 먼저 이해하기 (↑4)** ➜ |
| 2 | #287 용어와 kubectl 기본 명령 한 줄씩 (2/2) | **#128 용어와 kubectl 기본 명령 한 줄씩 (1/2) (↓1)** ➜ |
| 3 | #130 YAML 필드와 Pod 상태 읽기 (1/2) | **#287 용어와 kubectl 기본 명령 한 줄씩 (2/2) (↓1)** ➜ |
| 4 | #288 YAML 필드와 Pod 상태 읽기 (2/2) | **#46 kubectl 명령과 YAML 해부하기 (↑3)** ➜ |
| 5 | #41 k8s 개념 먼저 이해하기 | **#130 YAML 필드와 Pod 상태 읽기 (1/2) (↓2)** ➜ |
| 6 | #78 k8s 구조 이해하기: 컨트롤 플레인, 노드, 선언형 모델 | **#288 YAML 필드와 Pod 상태 읽기 (2/2) (↓2)** ➜ |
| 7 | #46 kubectl 명령과 YAML 해부하기 | **#78 k8s 구조 이해하기: 컨트롤 플레인, 노드, 선언형 모델 (↓1)** ➜ |
| 8 | #79 k8s 스케줄링 운영 개념: Taint, drain, DaemonSet, Ingress | #79 k8s 스케줄링 운영 개념: Taint, drain, DaemonSet, Ingress |

## [k8s] kubectl 실습 기초  (단원 id 60, 점수 3, 이동 6/8)

- 이유: 라벨(336)을 20 직후로 당겨 셀렉터 전제를 해소하고, 개요(19)→워크플로(342)→jsonpath 심화(224)로 정렬.

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #6 k8s 기초 | #6 k8s 기초 |
| 2 | #20 k8s 일상 운영 기본기 | #20 k8s 일상 운영 기본기 |
| 3 | #107 k8s 장애 읽기 입문: Pod 상태 한마디씩 | **#336 라벨·셀렉터·어노테이션 실습: 라벨 조회와 셀렉터(-l, in), 라벨 붙이기·바꾸기·떼기,… (↑4)** ➜ |
| 4 | #33 k8s 쉬운 장애 고치기 | **#107 k8s 장애 읽기 입문: Pod 상태 한마디씩 (↓1)** ➜ |
| 5 | #19 kubectl 속도와 실전 | **#33 k8s 쉬운 장애 고치기 (↓1)** ➜ |
| 6 | #224 kubectl 출력에서 원하는 값만 뽑기: jsonpath, range, 필터, custom… | **#19 kubectl 속도와 실전 (↓1)** ➜ |
| 7 | #336 라벨·셀렉터·어노테이션 실습: 라벨 조회와 셀렉터(-l, in), 라벨 붙이기·바꾸기·떼기,… | **#342 YAML 작성 워크플로 실습: dry-run 으로 뼈대 만들고, 고치고, diff 로 보고,… (↑1)** ➜ |
| 8 | #342 YAML 작성 워크플로 실습: dry-run 으로 뼈대 만들고, 고치고, diff 로 보고,… | **#224 kubectl 출력에서 원하는 값만 뽑기: jsonpath, range, 필터, custom… (↓2)** ➜ |

## [k8s] 워크로드와 설정  (단원 id 7, 점수 3, 이동 6/11)

- 이유: Deployment-RS-Pod 관계(145)를 롤링 업데이트(134) 앞으로 옮겨 전제를 먼저 가르침. (1/2)(2/2) 쌍은 유지.

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #132 네임스페이스, ConfigMap, Secret 한 줄씩 (1/2) | #132 네임스페이스, ConfigMap, Secret 한 줄씩 (1/2) |
| 2 | #289 네임스페이스, ConfigMap, Secret 한 줄씩 (2/2) | #289 네임스페이스, ConfigMap, Secret 한 줄씩 (2/2) |
| 3 | #134 Deployment 업데이트, Job, 상태 읽기 한 줄씩 (1/2) | **#145 워크로드 관계, 리소스 단위, kubectl 작업 도구 한 줄씩 (1/2) (↑4)** ➜ |
| 4 | #290 Deployment 업데이트, Job, 상태 읽기 한 줄씩 (2/2) | **#292 워크로드 관계, 리소스 단위, kubectl 작업 도구 한 줄씩 (2/2) (↑4)** ➜ |
| 5 | #136 Service 종류, 헬스 체크, 스케줄링, 스토리지 읽기 한 줄씩 (1/2) | **#134 Deployment 업데이트, Job, 상태 읽기 한 줄씩 (1/2) (↓2)** ➜ |
| 6 | #291 Service 종류, 헬스 체크, 스케줄링, 스토리지 읽기 한 줄씩 (2/2) | **#290 Deployment 업데이트, Job, 상태 읽기 한 줄씩 (2/2) (↓2)** ➜ |
| 7 | #145 워크로드 관계, 리소스 단위, kubectl 작업 도구 한 줄씩 (1/2) | **#136 Service 종류, 헬스 체크, 스케줄링, 스토리지 읽기 한 줄씩 (1/2) (↓2)** ➜ |
| 8 | #292 워크로드 관계, 리소스 단위, kubectl 작업 도구 한 줄씩 (2/2) | **#291 Service 종류, 헬스 체크, 스케줄링, 스토리지 읽기 한 줄씩 (2/2) (↓2)** ➜ |
| 9 | #147 Helm 기본, 오토스케일(HPA), 이벤트·로그 읽기 한 줄씩 (1/2) | #147 Helm 기본, 오토스케일(HPA), 이벤트·로그 읽기 한 줄씩 (1/2) |
| 10 | #293 Helm 기본, 오토스케일(HPA), 이벤트·로그 읽기 한 줄씩 (2/2) | #293 Helm 기본, 오토스케일(HPA), 이벤트·로그 읽기 한 줄씩 (2/2) |
| 11 | #487 k8s 워크로드 관계와 설정 손연습: ownerReferences, envFrom prefi… | #487 k8s 워크로드 관계와 설정 손연습: ownerReferences, envFrom prefi… |

## [k8s] 운영과 트러블슈팅  (단원 id 9, 점수 3, 이동 6/10)

- 이유: 읽기(31) → 개별 진단(339) → 종합 수리(23) → Service → 롤아웃 → Job → 퀴즈(29) → 삭제·디버깅 심화 순으로 계단화

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #23 k8s 트러블슈팅 실전 | **#31 k8s 터미널로 확인하고 고르기 (↑1)** ➜ |
| 2 | #31 k8s 터미널로 확인하고 고르기 | **#339 깨진 Pod 진단 실습: ImagePullBackOff·CrashLoopBackOff·OOM… (↑5)** ➜ |
| 3 | #29 k8s CKA 개념·명령 퀴즈 | **#23 k8s 트러블슈팅 실전 (↓2)** ➜ |
| 4 | #227 Service 가 연결 안 될 때 원인 좁히기: Endpoints, selector 와 라벨… | #227 Service 가 연결 안 될 때 원인 좁히기: Endpoints, selector 와 라벨… |
| 5 | #230 Deployment 롤아웃과 복구: 이미지 업데이트, 이력 읽기, 잘못된 이미지 되돌리기, … | #230 Deployment 롤아웃과 복구: 이미지 업데이트, 이력 읽기, 잘못된 이미지 되돌리기, … |
| 6 | #233 Job 과 CronJob 실습: 만들기, 로그 읽기, 실패 고치기, 병렬 실행, 정해진 때 … | **#345 Deployment 롤아웃 손연습: set image, rollout status, hist… (↑2)** ➜ |
| 7 | #339 깨진 Pod 진단 실습: ImagePullBackOff·CrashLoopBackOff·OOM… | **#233 Job 과 CronJob 실습: 만들기, 로그 읽기, 실패 고치기, 병렬 실행, 정해진 때 … (↓1)** ➜ |
| 8 | #345 Deployment 롤아웃 손연습: set image, rollout status, hist… | **#29 k8s CKA 개념·명령 퀴즈 (↓5)** ➜ |
| 9 | #423 Finalizer 와 삭제가 멈출 때: deletionTimestamp, Terminatin… | #423 Finalizer 와 삭제가 멈출 때: deletionTimestamp, Terminatin… |
| 10 | #425 임시 컨테이너와 커스텀 리소스: 디버깅용 컨테이너, 서브리소스 권한, Operator 패턴 | #425 임시 컨테이너와 커스텀 리소스: 디버깅용 컨테이너, 서브리소스 권한, Operator 패턴 |

## [k8s] 클러스터 운영·보안  (단원 id 29, 점수 3, 이동 2/4)

- 이유: 121이 cordon·컨트롤 플레인 점검 위치를 먼저 가르쳐 120의 업그레이드·설정 변경 전제를 충족

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #119 k8s 권한(RBAC) 읽기: Role, RoleBinding, ServiceAccount | #119 k8s 권한(RBAC) 읽기: Role, RoleBinding, ServiceAccount |
| 2 | #120 k8s 클러스터 관리 읽기: etcd 백업·복원, 업그레이드, 인증서 | **#121 k8s 노드·컨트롤 플레인 장애 읽기: NotReady, kubelet, apiserver (↑1)** ➜ |
| 3 | #121 k8s 노드·컨트롤 플레인 장애 읽기: NotReady, kubelet, apiserver | **#120 k8s 클러스터 관리 읽기: etcd 백업·복원, 업그레이드, 인증서 (↓1)** ➜ |
| 4 | #424 Pod Security Admission: 세 레벨, enforce·audit·warn, 네… | #424 Pod Security Admission: 세 레벨, enforce·audit·warn, 네… |

## [가상화] qemu-img·장치 설정·virsh 객체 명령  (단원 id 72, 점수 3, 이동 4/10)

- 이유: 디스크 계열(이미지→disk XML→driver→볼륨 명령)과 네트워크 계열(인터페이스→옵션→net 명령)을 각각 묶고 이벤트·호스트 인터페이스는 뒤로.

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #459 qemu-img 기본: 오프라인 원칙, info 의 virtual·disk size, che… | #459 qemu-img 기본: 오프라인 원칙, info 의 virtual·disk size, che… |
| 2 | #460 qemu-img 백킹 체인: create -b, commit, rebase, snapshot… | #460 qemu-img 백킹 체인: create -b, commit, rebase, snapshot… |
| 3 | #461 libvirt 이벤트 동작: on_poweroff·on_reboot·on_crash, 금지 … | **#462 libvirt disk 요소: type·device, lun, snapshot 모드, sta… (↑1)** ➜ |
| 4 | #462 libvirt disk 요소: type·device, lun, snapshot 모드, sta… | **#463 libvirt 디스크 driver: cache·error_policy·io·discard·c… (↑1)** ➜ |
| 5 | #463 libvirt 디스크 driver: cache·error_policy·io·discard·c… | **#474 virsh 로 스토리지 볼륨 다루기: vol-create·create-as·clone·del… (↑4)** ➜ |
| 6 | #464 libvirt 인터페이스 유형: network·bridge·ethernet·direct, 권… | #464 libvirt 인터페이스 유형: network·bridge·ethernet·direct, 권… |
| 7 | #465 libvirt 인터페이스 옵션: model, target 이름, bandwidth, vlan… | #465 libvirt 인터페이스 옵션: model, target 이름, bandwidth, vlan… |
| 8 | #473 virsh 로 가상 네트워크 다루기: net-create·define·start·destro… | #473 virsh 로 가상 네트워크 다루기: net-create·define·start·destro… |
| 9 | #474 virsh 로 스토리지 볼륨 다루기: vol-create·create-as·clone·del… | **#461 libvirt 이벤트 동작: on_poweroff·on_reboot·on_crash, 금지 … (↓6)** ➜ |
| 10 | #475 virsh 로 호스트 인터페이스 다루기: iface-bridge·unbridge, defin… | #475 virsh 로 호스트 인터페이스 다루기: iface-bridge·unbridge, defin… |

## [네트워크] ip·ss·tc 도구 다루기  (단원 id 68, 점수 2, 이동 8/8)

- 이유: ip 기본 → ss·neigh → netns를 가르친 뒤 veth·link → NIC·tc → 소켓 옵션(418)은 맨 끝(가능하면 466·467 뒤로 이동)

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #418 TCP 옵션과 sysctl: NODELAY·CORK, keep-alive, syncookie… | **#419 ip address 깊게: scope, label, valid_lft·preferred_lf… (↑1)** ➜ |
| 2 | #419 ip address 깊게: scope, label, valid_lft·preferred_lf… | **#434 ss 로 소켓 살펴보기: -l·-a·-n·-p·-s, 연결 상태 필터, 포트 조건 (↑1)** ➜ |
| 3 | #434 ss 로 소켓 살펴보기: -l·-a·-n·-p·-s, 연결 상태 필터, 포트 조건 | **#435 ip neighbour 로 이웃 테이블 다루기: NUD 상태, show·flush 기본, a… (↑1)** ➜ |
| 4 | #435 ip neighbour 로 이웃 테이블 다루기: NUD 상태, show·flush 기본, a… | **#439 ip netns 로 네트워크 네임스페이스 다루기: /var/run/netns, exec, p… (↑4)** ➜ |
| 5 | #436 ethtool 로 NIC 살펴보기: 설정 조회·변경(-s), 오프로드(-k·-K), 드라이버… | **#438 ip link 로 인터페이스 다루기: set 옵션(flag·master·netns), vet… (↑2)** ➜ |
| 6 | #437 tc 로 트래픽 제어하기: qdisc·class·filter, handle, ingress,… | **#436 ethtool 로 NIC 살펴보기: 설정 조회·변경(-s), 오프로드(-k·-K), 드라이버… (↓1)** ➜ |
| 7 | #438 ip link 로 인터페이스 다루기: set 옵션(flag·master·netns), vet… | **#437 tc 로 트래픽 제어하기: qdisc·class·filter, handle, ingress,… (↓1)** ➜ |
| 8 | #439 ip netns 로 네트워크 네임스페이스 다루기: /var/run/netns, exec, p… | **#418 TCP 옵션과 sysctl: NODELAY·CORK, keep-alive, syncookie… (↓7)** ➜ |

## [네트워크] 네트워크 기초  (단원 id 47, 점수 3, 이동 5/8)

- 이유: 경로 기초→경로 심화·정책 라우팅을 연속시키고, DNS 기본(405)을 dnsmasq(397)보다 앞에 둠. 404 iptables는 NAT·마킹 사전지식이 필요하므로 마지막.

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #378 네트워크 연결 요소: VLAN·브리지·본딩·MTU | #378 네트워크 연결 요소: VLAN·브리지·본딩·MTU |
| 2 | #379 네트워크 주소와 경로: 사설 주소·CIDR·게이트웨이·라우팅·ARP | #379 네트워크 주소와 경로: 사설 주소·CIDR·게이트웨이·라우팅·ARP |
| 3 | #396 DHCP 동작: 메시지 흐름, 포트, 임대 갱신(T1·T2), 릴레이, 주소 충돌 | **#408 ip route 깊게: 경로 타입, metric, scope, proto, nexthop 조회 (↑4)** ➜ |
| 4 | #397 dnsmasq 로 DHCP·DNS·PXE: 주소 범위, 임대, TFTP, 업스트림, 캐시 | **#409 정책 라우팅: ip rule, 기본 규칙 3개, 선택자와 동작 (↑4)** ➜ |
| 5 | #404 iptables 기본: 테이블·체인, 타깃, 규칙 순서, 자주 쓰는 옵션 | **#396 DHCP 동작: 메시지 흐름, 포트, 임대 갱신(T1·T2), 릴레이, 주소 충돌 (↓2)** ➜ |
| 6 | #405 DNS 기본: 레코드 타입, TTL, UDP 512바이트, 재귀 비트, 이름 길이 | #405 DNS 기본: 레코드 타입, TTL, UDP 512바이트, 재귀 비트, 이름 길이 |
| 7 | #408 ip route 깊게: 경로 타입, metric, scope, proto, nexthop 조회 | **#397 dnsmasq 로 DHCP·DNS·PXE: 주소 범위, 임대, TFTP, 업스트림, 캐시 (↓3)** ➜ |
| 8 | #409 정책 라우팅: ip rule, 기본 규칙 3개, 선택자와 동작 | **#404 iptables 기본: 테이블·체인, 타깃, 규칙 순서, 자주 쓰는 옵션 (↓3)** ➜ |

## [데이터베이스] MariaDB 운영  (단원 id 20, 점수 2, 이동 8/10)

- 이유: 운영 기초→로그→백업→복제 개념→GTID→반동기→복제 점검 실습→내부 원리 순으로, 실습(91)은 개념(59·414·415) 뒤에 둔다.

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #158 DB 기초 5 (개념): 운영자가 자주 쓰는 SQL, 세션·설정·권한·실행 계획 (1/2) | #158 DB 기초 5 (개념): 운영자가 자주 쓰는 SQL, 세션·설정·권한·실행 계획 (1/2) |
| 2 | #332 DB 기초 5 (개념): 운영자가 자주 쓰는 SQL, 세션·설정·권한·실행 계획 (2/2) | #332 DB 기초 5 (개념): 운영자가 자주 쓰는 SQL, 세션·설정·권한·실행 계획 (2/2) |
| 3 | #59 MariaDB 복제·Galera·복구: 무엇이 어긋났는지 읽기 | **#402 MariaDB 슬로우 쿼리 로그: 켜기, long_query_time, 출력 방식, 필터와 … (↑4)** ➜ |
| 4 | #87 DB 내부 이해: 격리 수준, MVCC, 로그, 인덱스, EXPLAIN | **#403 MariaDB 바이너리 로그 형식과 InnoDB 버퍼 풀: STATEMENT·ROW·MIXE… (↑4)** ➜ |
| 5 | #91 MariaDB 복제·Galera 점검하기: 명령 채우고, 상태 읽고, 설정 고치기 | **#109 MariaDB 백업과 복원: 덤프 뜨고, 되살리고, 검증하기 (↑1)** ➜ |
| 6 | #109 MariaDB 백업과 복원: 덤프 뜨고, 되살리고, 검증하기 | **#59 MariaDB 복제·Galera·복구: 무엇이 어긋났는지 읽기 (↓3)** ➜ |
| 7 | #402 MariaDB 슬로우 쿼리 로그: 켜기, long_query_time, 출력 방식, 필터와 … | **#414 MariaDB GTID: 형식, gtid_slave_pos, MASTER_USE_GTID, … (↑2)** ➜ |
| 8 | #403 MariaDB 바이너리 로그 형식과 InnoDB 버퍼 풀: STATEMENT·ROW·MIXE… | **#415 MariaDB 반동기 복제와 mariadb-dump: 타임아웃, AFTER_SYNC, sin… (↑2)** ➜ |
| 9 | #414 MariaDB GTID: 형식, gtid_slave_pos, MASTER_USE_GTID, … | **#91 MariaDB 복제·Galera 점검하기: 명령 채우고, 상태 읽고, 설정 고치기 (↓4)** ➜ |
| 10 | #415 MariaDB 반동기 복제와 mariadb-dump: 타임아웃, AFTER_SYNC, sin… | **#87 DB 내부 이해: 격리 수준, MVCC, 로그, 인덱스, EXPLAIN (↓6)** ➜ |

## [도커] 컨테이너 조회·종료 코드·실습  (단원 id 66, 점수 2, 이동 10/12)

- 이유: 수명주기·종료 코드 기본을 먼저(478 앞당김), 조회/출력 뒤 실습, 보안·자원·헬스체크는 뒤로 모음.

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #212 컨테이너 상태와 종료 코드: ps -q·--filter, 125·126·127, wait, … | #212 컨테이너 상태와 종료 코드: ps -q·--filter, 125·126·127, wait, … |
| 2 | #255 컨테이너 상태와 종료 코드: ps --filter, 종료 코드, wait, rename, p… | #255 컨테이너 상태와 종료 코드: ps --filter, 종료 코드, wait, rename, p… |
| 3 | #215 조회와 출력 형식: inspect·--format, ps --format·-n·-l·-s, … | **#478 도커 컨테이너 수명주기 실습: create·start, pause, stop -t, kill… (↑9)** ➜ |
| 4 | #256 조회와 출력 형식: inspect·--format, port, -n·-l·-s, 필터 2종,… | **#215 조회와 출력 형식: inspect·--format, ps --format·-n·-l·-s, … (↓1)** ➜ |
| 5 | #160 종료 코드 읽기, 컨테이너 보안 기본, 레지스트리와 digest 한 줄씩 (1/2) | **#256 조회와 출력 형식: inspect·--format, port, -n·-l·-s, 필터 2종,… (↓1)** ➜ |
| 6 | #242 종료 코드 읽기, 컨테이너 보안 기본, 레지스트리와 digest 한 줄씩 (2/2) | **#225 도커 출력에서 원하는 값만 뽑기: inspect -f, range, index, ps --f… (↑1)** ➜ |
| 7 | #225 도커 출력에서 원하는 값만 뽑기: inspect -f, range, index, ps --f… | **#231 도커 컨테이너 들여다보기 실습: 로그, 프로세스, 자원, 파일 복사, 변경 내역 (↑1)** ➜ |
| 8 | #231 도커 컨테이너 들여다보기 실습: 로그, 프로세스, 자원, 파일 복사, 변경 내역 | **#349 도커 run 옵션 드릴 실습: -w, --hostname, --env-file, -e 우선순… (↑3)** ➜ |
| 9 | #340 도커 자원 제한과 컨테이너 보안 기본 실습: --memory, --cpus, --pids-l… | **#160 종료 코드 읽기, 컨테이너 보안 기본, 레지스트리와 digest 한 줄씩 (1/2) (↓4)** ➜ |
| 10 | #343 도커 헬스체크와 재시작 정책 실습: --health-cmd, State.Health, hea… | **#242 종료 코드 읽기, 컨테이너 보안 기본, 레지스트리와 digest 한 줄씩 (2/2) (↓4)** ➜ |
| 11 | #349 도커 run 옵션 드릴 실습: -w, --hostname, --env-file, -e 우선순… | **#340 도커 자원 제한과 컨테이너 보안 기본 실습: --memory, --cpus, --pids-l… (↓2)** ➜ |
| 12 | #478 도커 컨테이너 수명주기 실습: create·start, pause, stop -t, kill… | **#343 도커 헬스체크와 재시작 정책 실습: --health-cmd, State.Health, hea… (↓2)** ➜ |

## [도커] 컨테이너 다루기  (단원 id 32, 점수 2, 이동 8/11)

- 이유: 기본 조작(cp·restart·kill·rm)→상태·종료→실행 중 조작→exec/attach→run 옵션→종합 손연습 순.

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #171 컨테이너 상태와 종료 신호: create·pause, stop 의 SIGTERM, PID 1… | **#203 컨테이너 복사·재시작·정리: docker cp, restart, kill, rm -f, di… (↑8)** ➜ |
| 2 | #244 컨테이너 상태와 종료 신호: create·pause, stop 의 SIGTERM, PID 1… | **#252 컨테이너 복사·재시작·정리: docker cp, restart, kill, rm -f, di… (↑8)** ➜ |
| 3 | #191 실행 중 컨테이너 다루기: rename, update, 재시작 정책, --pids-limit… | **#171 컨테이너 상태와 종료 신호: create·pause, stop 의 SIGTERM, PID 1… (↓2)** ➜ |
| 4 | #249 실행 중 컨테이너 다루기: rename, update, 재시작 정책, --pids-limit… | **#244 컨테이너 상태와 종료 신호: create·pause, stop 의 SIGTERM, PID 1… (↓2)** ➜ |
| 5 | #195 docker run 옵션 모음: --network, --hostname, --volumes-… | **#191 실행 중 컨테이너 다루기: rename, update, 재시작 정책, --pids-limit… (↓2)** ➜ |
| 6 | #250 docker run 옵션 모음: --network, --hostname, --volumes-… | **#249 실행 중 컨테이너 다루기: rename, update, 재시작 정책, --pids-limit… (↓2)** ➜ |
| 7 | #199 컨테이너에 붙기·찾기·만들기: exec -e/-w/-u/-d, attach, create/s… | #199 컨테이너에 붙기·찾기·만들기: exec -e/-w/-u/-d, attach, create/s… |
| 8 | #251 컨테이너에 붙기·찾기·만들기: exec -e/-w/-u/-d, attach, create/s… | #251 컨테이너에 붙기·찾기·만들기: exec -e/-w/-u/-d, attach, create/s… |
| 9 | #203 컨테이너 복사·재시작·정리: docker cp, restart, kill, rm -f, di… | **#195 docker run 옵션 모음: --network, --hostname, --volumes-… (↓4)** ➜ |
| 10 | #252 컨테이너 복사·재시작·정리: docker cp, restart, kill, rm -f, di… | **#250 docker run 옵션 모음: --network, --hostname, --volumes-… (↓4)** ➜ |
| 11 | #488 도커 컨테이너 다루기 손연습: exec -u·-w·-e, rename, --volumes-f… | #488 도커 컨테이너 다루기 손연습: exec -u·-w·-e, rename, --volumes-f… |

## [도커] Dockerfile 심화와 이미지 실습  (단원 id 67, 점수 3, 이동 7/9)

- 이유: Dockerfile 개념 퀴즈 후 바로 직접 쓰기 실습(234, 346), 그 뒤 특수 지시어(187/248/501), 이미지 옮기기(8, 337)는 마지막으로 분리.

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #154 Dockerfile 심화, 변수와 명령, 멀티스테이지, 이미지 옮기기 한 줄씩 (1/2) | #154 Dockerfile 심화, 변수와 명령, 멀티스테이지, 이미지 옮기기 한 줄씩 (1/2) |
| 2 | #241 Dockerfile 심화, 변수와 명령, 멀티스테이지, 이미지 옮기기 한 줄씩 (2/2) | #241 Dockerfile 심화, 변수와 명령, 멀티스테이지, 이미지 옮기기 한 줄씩 (2/2) |
| 3 | #187 Dockerfile 지시어와 헬스체크·정지: HEALTHCHECK, STOPSIGNAL, O… | **#234 도커 이미지 손으로 만들기 실습: Dockerfile, build, tag, ENV·ARG,… (↑3)** ➜ |
| 4 | #248 Dockerfile 지시어와 헬스체크·정지: HEALTHCHECK, STOPSIGNAL, O… | **#346 도커 Dockerfile 직접 쓰기 실습: FROM·RUN·LABEL, WORKDIR, CM… (↑4)** ➜ |
| 5 | #8 Docker 이미지 오프라인 반입 | **#187 Dockerfile 지시어와 헬스체크·정지: HEALTHCHECK, STOPSIGNAL, O… (↓2)** ➜ |
| 6 | #234 도커 이미지 손으로 만들기 실습: Dockerfile, build, tag, ENV·ARG,… | **#248 Dockerfile 지시어와 헬스체크·정지: HEALTHCHECK, STOPSIGNAL, O… (↓2)** ➜ |
| 7 | #337 도커 이미지 관리와 옮기기 실습: pull 태그, images --format, tag, r… | **#501 Dockerfile·빌드 옵션 손연습: --target, STOPSIGNAL, ONBUILD… (↑2)** ➜ |
| 8 | #346 도커 Dockerfile 직접 쓰기 실습: FROM·RUN·LABEL, WORKDIR, CM… | **#8 Docker 이미지 오프라인 반입 (↓3)** ➜ |
| 9 | #501 Dockerfile·빌드 옵션 손연습: --target, STOPSIGNAL, ONBUILD… | **#337 도커 이미지 관리와 옮기기 실습: pull 태그, images --format, tag, r… (↓2)** ➜ |

## [도커] Compose와 운영  (단원 id 35, 점수 2, 이동 6/7)

- 이유: 기본 명령·프로젝트 이름(206/253) → 운영 명령(148/240) → 변수·의존성·profiles(175/245) → 종합 실습(237)

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #148 compose 운영 명령, Dockerfile 한 줄, 자원 제한, 상태 점검 한 줄씩 (1… | **#206 Compose 기본 명령과 필드: up -d, -p·-f, down -v, stop·star… (↑4)** ➜ |
| 2 | #240 compose 운영 명령, Dockerfile 한 줄, 자원 제한, 상태 점검 한 줄씩 (2… | **#253 Compose 기본 명령과 필드: up -d, -p·-f, down -v, stop·star… (↑4)** ➜ |
| 3 | #175 compose 읽기: 변수 우선순위, depends_on 조건, profiles, scale… | **#148 compose 운영 명령, Dockerfile 한 줄, 자원 제한, 상태 점검 한 줄씩 (1… (↓2)** ➜ |
| 4 | #245 compose 읽기: 변수 우선순위, depends_on 조건, profiles, scale… | **#240 compose 운영 명령, Dockerfile 한 줄, 자원 제한, 상태 점검 한 줄씩 (2… (↓2)** ➜ |
| 5 | #206 Compose 기본 명령과 필드: up -d, -p·-f, down -v, stop·star… | **#175 compose 읽기: 변수 우선순위, depends_on 조건, profiles, scale… (↓2)** ➜ |
| 6 | #253 Compose 기본 명령과 필드: up -d, -p·-f, down -v, stop·star… | **#245 compose 읽기: 변수 우선순위, depends_on 조건, profiles, scale… (↓2)** ➜ |
| 7 | #237 도커 Compose 손으로 해 보기 실습: compose.yaml, up, ps, logs,… | #237 도커 Compose 손으로 해 보기 실습: compose.yaml, up, ps, logs,… |

## [도커] 네트워크와 볼륨  (단원 id 34, 점수 3, 이동 5/9)

- 이유: 기본 볼륨·네트워크 퀴즈 뒤에 기초 실습(228)을 두고 심화 퀴즈로 올라가며 맨 뒤에 정리·고급 옵션을 배치

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #142 볼륨, 네트워크, 이미지 만들기, 정리 한 줄씩 (1/2) | #142 볼륨, 네트워크, 이미지 만들기, 정리 한 줄씩 (1/2) |
| 2 | #239 볼륨, 네트워크, 이미지 만들기, 정리 한 줄씩 (2/2) | #239 볼륨, 네트워크, 이미지 만들기, 정리 한 줄씩 (2/2) |
| 3 | #179 네트워크와 볼륨 심화: 사용자 정의 네트워크, 격리, 볼륨 수명, :ro, --mount, … | **#228 도커 볼륨과 네트워크 실습: 데이터 보존, 바인드 마운트, 읽기 전용, 이름으로 통신 (↑4)** ➜ |
| 4 | #246 네트워크와 볼륨 심화: 사용자 정의 네트워크, 격리, 볼륨 수명, :ro, --mount, … | **#179 네트워크와 볼륨 심화: 사용자 정의 네트워크, 격리, 볼륨 수명, :ro, --mount, … (↓1)** ➜ |
| 5 | #209 포트·네트워크·실행 옵션: -p 형식, -P 와 EXPOSE, 포트 충돌, network c… | **#246 네트워크와 볼륨 심화: 사용자 정의 네트워크, 격리, 볼륨 수명, :ro, --mount, … (↓1)** ➜ |
| 6 | #254 포트·네트워크·실행 옵션: -p 형식, -P 와 EXPOSE, 포트 충돌, network c… | **#209 포트·네트워크·실행 옵션: -p 형식, -P 와 EXPOSE, 포트 충돌, network c… (↓1)** ➜ |
| 7 | #228 도커 볼륨과 네트워크 실습: 데이터 보존, 바인드 마운트, 읽기 전용, 이름으로 통신 | **#254 포트·네트워크·실행 옵션: -p 형식, -P 와 EXPOSE, 포트 충돌, network c… (↓1)** ➜ |
| 8 | #352 도커 정리와 디스크 사용량 실습: system df, container·image·volum… | #352 도커 정리와 디스크 사용량 실습: system df, container·image·volum… |
| 9 | #498 도커 네트워크·로그·종료·보안 옵션 손연습: --network-alias, --ip, --d… | #498 도커 네트워크·로그·종료·보안 옵션 손연습: --network-alias, --ip, --d… |

## [도커] Docker 기초  (단원 id 5, 점수 4, 이동 4/5)

- 이유: 기본 개념→기본 실습→옵션 반복→심화 원리 순.

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #40 Docker 개념 먼저 이해하기 | #40 Docker 개념 먼저 이해하기 |
| 2 | #77 컨테이너의 정체: 격리된 프로세스, 네임스페이스와 cgroup, 이미지 레이어 | **#5 Docker 기초 (↑1)** ➜ |
| 3 | #5 Docker 기초 | **#137 이미지, 컨테이너, docker run 옵션 한 줄씩 (1/2) (↑1)** ➜ |
| 4 | #137 이미지, 컨테이너, docker run 옵션 한 줄씩 (1/2) | **#238 이미지, 컨테이너, docker run 옵션 한 줄씩 (2/2) (↑1)** ➜ |
| 5 | #238 이미지, 컨테이너, docker run 옵션 한 줄씩 (2/2) | **#77 컨테이너의 정체: 격리된 프로세스, 네임스페이스와 cgroup, 이미지 레이어 (↓3)** ➜ |

## [리눅스] 텍스트·파일 도구 심화  (단원 id 54, 점수 2, 이동 11/11)

- 이유: 파일 옵션→열 다루기→정규식→압축·검증 순으로 기초에서 심화, 스크립트 인자(197)는 쉘 스크립트 단원 쪽에 붙임. 480은 텍스트 도구 뒤.

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #181 압축과 파일 검증: gzip·tar·zip, 체크섬, diff·patch, split 한 줄… | **#193 파일 다루기 옵션: ls 정렬, stat, touch, cp·mv 덮어쓰기, ln, real… (↑6)** ➜ |
| 2 | #274 압축과 파일 검증: gzip·tar·zip, 체크섬, diff·patch, split 한 줄… | **#277 파일 다루기 옵션: ls 정렬, stat, touch, cp·mv 덮어쓰기, ln, real… (↑6)** ➜ |
| 3 | #185 grep 과 정규식 심화: BRE·ERE, -o, -P, 앵커·클래스, 역참조, -F, 종료… | **#189 정렬과 열 다루기: sort -k·-n·-h·-u, uniq, cut, paste, join… (↑2)** ➜ |
| 4 | #275 grep 과 정규식 심화: BRE·ERE, -o, -P, 앵커·클래스, 역참조, -F, 종료… | **#276 정렬과 열 다루기: sort -k·-n·-h·-u, uniq, cut, paste, join… (↑2)** ➜ |
| 5 | #189 정렬과 열 다루기: sort -k·-n·-h·-u, uniq, cut, paste, join… | **#185 grep 과 정규식 심화: BRE·ERE, -o, -P, 앵커·클래스, 역참조, -F, 종료… (↓2)** ➜ |
| 6 | #276 정렬과 열 다루기: sort -k·-n·-h·-u, uniq, cut, paste, join… | **#275 grep 과 정규식 심화: BRE·ERE, -o, -P, 앵커·클래스, 역참조, -F, 종료… (↓2)** ➜ |
| 7 | #193 파일 다루기 옵션: ls 정렬, stat, touch, cp·mv 덮어쓰기, ln, real… | **#181 압축과 파일 검증: gzip·tar·zip, 체크섬, diff·patch, split 한 줄… (↓6)** ➜ |
| 8 | #277 파일 다루기 옵션: ls 정렬, stat, touch, cp·mv 덮어쓰기, ln, real… | **#274 압축과 파일 검증: gzip·tar·zip, 체크섬, diff·patch, split 한 줄… (↓6)** ➜ |
| 9 | #197 쉘 스크립트 인자와 상태: "$@", shift, getopts, set -e·-u, pip… | **#480 텍스트 도구 손연습: grep -E·-o·-vc·-nw, sort -k·-h, uniq -c… (↑2)** ➜ |
| 10 | #278 쉘 스크립트 인자와 상태: "$@", shift, getopts, set -e·-u, pip… | **#197 쉘 스크립트 인자와 상태: "$@", shift, getopts, set -e·-u, pip… (↓1)** ➜ |
| 11 | #480 텍스트 도구 손연습: grep -E·-o·-vc·-nw, sort -k·-h, uniq -c… | **#278 쉘 스크립트 인자와 상태: "$@", shift, getopts, set -e·-u, pip… (↓1)** ➜ |

## [리눅스] 쉘 스크립트와 작업 제어  (단원 id 55, 점수 2, 이동 10/11)

- 이유: 신호·종료 코드(210)와 함수·read·local(213)을 먼저 두고 배열(201)·작업 제어(204)·trap(207)·종합 손연습(479) 순으로. 각 (1/2)·(2/2) 쌍은 붙여 유지.

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #201 배열과 xargs: 배열 인덱스·+=·unset, 연관 배열, here-string, map… | **#210 내용 비교와 신호·시간: diff -r·-q·-u, cmp, cat -A, fold, tr … (↑6)** ➜ |
| 2 | #279 배열과 xargs: 배열 인덱스·+=·unset, 연관 배열, here-string, map… | **#282 내용 비교와 신호·시간: diff -r·-q·-u, cmp, cat -A, fold, tr … (↑6)** ➜ |
| 3 | #204 쉘 편의 기능과 작업 제어: echo -e, cat -n, tail -f, basename,… | **#213 함수·산술·입력과 파일 다루기: 함수 인자·local, 산술, expr, read, type… (↑6)** ➜ |
| 4 | #280 쉘 편의 기능과 작업 제어: echo -e, cat -n, tail -f, basename,… | **#283 함수·산술·입력과 파일 다루기: 함수 인자·local, 산술, expr, read, type… (↑6)** ➜ |
| 5 | #207 스크립트 기본기 2와 사용자·그룹: [ -f -d -z ], case, until, set … | **#201 배열과 xargs: 배열 인덱스·+=·unset, 연관 배열, here-string, map… (↓4)** ➜ |
| 6 | #281 스크립트 기본기 2와 사용자·그룹: [ -f -d -z ], case, until, set … | **#279 배열과 xargs: 배열 인덱스·+=·unset, 연관 배열, here-string, map… (↓4)** ➜ |
| 7 | #210 내용 비교와 신호·시간: diff -r·-q·-u, cmp, cat -A, fold, tr … | **#204 쉘 편의 기능과 작업 제어: echo -e, cat -n, tail -f, basename,… (↓4)** ➜ |
| 8 | #282 내용 비교와 신호·시간: diff -r·-q·-u, cmp, cat -A, fold, tr … | **#280 쉘 편의 기능과 작업 제어: echo -e, cat -n, tail -f, basename,… (↓4)** ➜ |
| 9 | #213 함수·산술·입력과 파일 다루기: 함수 인자·local, 산술, expr, read, type… | **#207 스크립트 기본기 2와 사용자·그룹: [ -f -d -z ], case, until, set … (↓4)** ➜ |
| 10 | #283 함수·산술·입력과 파일 다루기: 함수 인자·local, 산술, expr, read, type… | **#281 스크립트 기본기 2와 사용자·그룹: [ -f -d -z ], case, until, set … (↓4)** ➜ |
| 11 | #479 쉘 스크립트 손연습: "$@"·shift, getopts, set -eu, 배열·연관 배열,… | #479 쉘 스크립트 손연습: "$@"·shift, getopts, set -eu, 배열·연관 배열,… |

## [리눅스] 운영과 장애 대응  (단원 id 4, 점수 2, 이동 7/9)

- 이유: 10 을 먼저, NFS 기초(75)를 27 앞에, SSH 키(75) 뒤에 124, 원리·퀴즈(32, 28)는 맨 뒤로

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #24 리눅스 패키지와 systemd 로그 | **#10 리눅스 현장 운영 (↑2)** ➜ |
| 2 | #123 cron 작업 예약: 문법, 환경 차이, 로그, 겹침 방지 | **#24 리눅스 패키지와 systemd 로그 (↓1)** ➜ |
| 3 | #10 리눅스 현장 운영 | **#123 cron 작업 예약: 문법, 환경 차이, 로그, 겹침 방지 (↓1)** ➜ |
| 4 | #16 리눅스 장애 진단 실전 | #16 리눅스 장애 진단 실전 |
| 5 | #27 리눅스 성능과 스토리지(NFS) 점검 | **#75 리눅스 운영 기본기: SSH 키, 시간 동기화, NFS, 정책 라우팅 (↑2)** ➜ |
| 6 | #32 리눅스 증상의 원인을 원리로 풀기 | **#124 SSH 접속 문제 해결 상황집: publickey, 권한, 호스트 키, 설정 파일 (↑2)** ➜ |
| 7 | #75 리눅스 운영 기본기: SSH 키, 시간 동기화, NFS, 정책 라우팅 | **#27 리눅스 성능과 스토리지(NFS) 점검 (↓2)** ➜ |
| 8 | #124 SSH 접속 문제 해결 상황집: publickey, 권한, 호스트 키, 설정 파일 | **#32 리눅스 증상의 원인을 원리로 풀기 (↓2)** ➜ |
| 9 | #28 리눅스 명령어 확인 퀴즈 | #28 리눅스 명령어 확인 퀴즈 |

## [리눅스] 기초  (단원 id 1, 점수 2, 이동 6/10)

- 이유: 경로·권한 개념 퀴즈와 연결 개념(43)을 먼저, 파일 실습(1·2) 뒤 연결 실습(34)을 앞당겨 3 의 파이프를 해결, 프로세스(3) 뒤에 fork·exec(85)

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #42 리눅스 기초 개념 먼저 이해하기 | #42 리눅스 기초 개념 먼저 이해하기 |
| 2 | #85 프로세스와 파일시스템 이해하기: fork·exec, /proc, 커널 모드 | **#43 명령 연결 개념 먼저 이해하기: 출력·오류·파이프 (↑3)** ➜ |
| 3 | #1 리눅스 기초 1 — 파일 탐색과 생성 | #1 리눅스 기초 1 — 파일 탐색과 생성 |
| 4 | #2 리눅스 기초 2 — 삭제·검색·권한 | #2 리눅스 기초 2 — 삭제·검색·권한 |
| 5 | #43 명령 연결 개념 먼저 이해하기: 출력·오류·파이프 | **#45 명령어 해부하기: 복사하기 전에 읽는 법 (↑1)** ➜ |
| 6 | #45 명령어 해부하기: 복사하기 전에 읽는 법 | **#34 리눅스 명령 연결하기: 파이프와 리다이렉션 (↑2)** ➜ |
| 7 | #3 리눅스 기초 3 — 프로세스와 시스템 | **#65 권한과 소유자: chmod, chown, umask (↑2)** ➜ |
| 8 | #34 리눅스 명령 연결하기: 파이프와 리다이렉션 | **#3 리눅스 기초 3 — 프로세스와 시스템 (↓1)** ➜ |
| 9 | #65 권한과 소유자: chmod, chown, umask | **#85 프로세스와 파일시스템 이해하기: fork·exec, /proc, 커널 모드 (↓7)** ➜ |
| 10 | #21 리눅스 쉘 기본기와 사용자·권한 | #21 리눅스 쉘 기본기와 사용자·권한 |

## [리눅스] 명령어 한 줄씩 2: 로그·쉘·텍스트  (단원 id 52, 점수 2, 이동 6/10)

- 이유: 쉘 문법(와일드카드·따옴표)을 먼저, 로그·링크, 접속 도구, 스크립트 제어구조, 네트워크 읽기 순으로 의존 순서 정렬.

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #144 로그 읽기, 파일 찾기, 링크, inode, 신호 한 줄씩 (1/2) | **#150 와일드카드, 따옴표, 명령 연결, 텍스트 도구 한 줄씩 (1/2) (↑4)** ➜ |
| 2 | #264 로그 읽기, 파일 찾기, 링크, inode, 신호 한 줄씩 (2/2) | **#266 와일드카드, 따옴표, 명령 연결, 텍스트 도구 한 줄씩 (2/2) (↑4)** ➜ |
| 3 | #146 vi 편집기, ssh·scp, 날짜 형식, 방화벽, 서버 정보 한 줄씩 (1/2) | **#144 로그 읽기, 파일 찾기, 링크, inode, 신호 한 줄씩 (1/2) (↓2)** ➜ |
| 4 | #265 vi 편집기, ssh·scp, 날짜 형식, 방화벽, 서버 정보 한 줄씩 (2/2) | **#264 로그 읽기, 파일 찾기, 링크, inode, 신호 한 줄씩 (2/2) (↓2)** ➜ |
| 5 | #150 와일드카드, 따옴표, 명령 연결, 텍스트 도구 한 줄씩 (1/2) | **#146 vi 편집기, ssh·scp, 날짜 형식, 방화벽, 서버 정보 한 줄씩 (1/2) (↓2)** ➜ |
| 6 | #266 와일드카드, 따옴표, 명령 연결, 텍스트 도구 한 줄씩 (2/2) | **#265 vi 편집기, ssh·scp, 날짜 형식, 방화벽, 서버 정보 한 줄씩 (2/2) (↓2)** ➜ |
| 7 | #152 쉘 스크립트 조건, 반복, 함수, 백그라운드 한 줄씩 (1/2) | #152 쉘 스크립트 조건, 반복, 함수, 백그라운드 한 줄씩 (1/2) |
| 8 | #267 쉘 스크립트 조건, 반복, 함수, 백그라운드 한 줄씩 (2/2) | #267 쉘 스크립트 조건, 반복, 함수, 백그라운드 한 줄씩 (2/2) |
| 9 | #156 네트워크 읽기(경로, DNS, curl, LISTEN)와 텍스트 도구 심화 한 줄씩 (1/2) | #156 네트워크 읽기(경로, DNS, curl, LISTEN)와 텍스트 도구 심화 한 줄씩 (1/2) |
| 10 | #268 네트워크 읽기(경로, DNS, curl, LISTEN)와 텍스트 도구 심화 한 줄씩 (2/2) | #268 네트워크 읽기(경로, DNS, curl, LISTEN)와 텍스트 도구 심화 한 줄씩 (2/2) |

## [리눅스] 네트워크와 통신  (단원 id 3, 점수 3, 이동 5/6)

- 이유: 106 입문을 18 앞으로, 235 진단 점검은 36 이후로 옮겨 개념 의존 순서에 맞춤

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #4 리눅스 네트워크/파일 전송 | **#106 이름으로 통신 입문: 이름표, 전화번호부, 포트 (↑2)** ➜ |
| 2 | #18 리눅스 네트워크 진단 | **#4 리눅스 네트워크/파일 전송 (↓1)** ➜ |
| 3 | #106 이름으로 통신 입문: 이름표, 전화번호부, 포트 | **#18 리눅스 네트워크 진단 (↓1)** ➜ |
| 4 | #36 리눅스 이름으로 통신하기 | #36 리눅스 이름으로 통신하기 |
| 5 | #81 DNS 와 이름 해석: 왜 깨지고 어떻게 확인하나 | **#235 내 서버의 네트워크 직접 점검하기: ip, hostname, getent, /etc/host… (↑1)** ➜ |
| 6 | #235 내 서버의 네트워크 직접 점검하기: ip, hostname, getent, /etc/host… | **#81 DNS 와 이름 해석: 왜 깨지고 어떻게 확인하나 (↓1)** ➜ |

## [리눅스] 운영 도구 한 줄씩: 성능·스케줄·sed·awk  (단원 id 53, 점수 2, 이동 4/10)

- 이유: 프로세스·권한 → 찾기 → 스케줄 → sed/awk 순으로 의존 정렬.

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #162 성능 읽기, top·ps·free·vmstat 와 좀비 프로세스 한 줄씩 (1/2) | #162 성능 읽기, top·ps·free·vmstat 와 좀비 프로세스 한 줄씩 (1/2) |
| 2 | #269 성능 읽기, top·ps·free·vmstat 와 좀비 프로세스 한 줄씩 (2/2) | #269 성능 읽기, top·ps·free·vmstat 와 좀비 프로세스 한 줄씩 (2/2) |
| 3 | #165 스케줄과 시간 읽기: cron 식, cron 의 환경, date 계산 한 줄씩 (1/2) | **#173 권한 비트와 프로세스 한도: umask, setuid·sticky, nohup·nice, u… (↑4)** ➜ |
| 4 | #270 스케줄과 시간 읽기: cron 식, cron 의 환경, date 계산 한 줄씩 (2/2) | **#272 권한 비트와 프로세스 한도: umask, setuid·sticky, nohup·nice, u… (↑4)** ➜ |
| 5 | #169 찾아서 처리하기: find 조건, -exec 와 xargs, tee·tr·uniq 한 줄씩 … | #169 찾아서 처리하기: find 조건, -exec 와 xargs, tee·tr·uniq 한 줄씩 … |
| 6 | #271 찾아서 처리하기: find 조건, -exec 와 xargs, tee·tr·uniq 한 줄씩 … | #271 찾아서 처리하기: find 조건, -exec 와 xargs, tee·tr·uniq 한 줄씩 … |
| 7 | #173 권한 비트와 프로세스 한도: umask, setuid·sticky, nohup·nice, u… | **#165 스케줄과 시간 읽기: cron 식, cron 의 환경, date 계산 한 줄씩 (1/2) (↓4)** ➜ |
| 8 | #272 권한 비트와 프로세스 한도: umask, setuid·sticky, nohup·nice, u… | **#270 스케줄과 시간 읽기: cron 식, cron 의 환경, date 계산 한 줄씩 (2/2) (↓4)** ➜ |
| 9 | #177 sed 와 awk 심화: 주소 범위, s 플래그, -i, 필드와 NR·NF, 배열·print… | #177 sed 와 awk 심화: 주소 범위, s 플래그, -i, 필드와 NR·NF, 배열·print… |
| 10 | #273 sed 와 awk 심화: 주소 범위, s 플래그, -i, 필드와 NR·NF, 배열·print… | #273 sed 와 awk 심화: 주소 범위, s 플래그, -i, 필드와 NR·NF, 배열·print… |

## [리눅스] 도구 다루기  (단원 id 2, 점수 3, 이동 2/10)

- 이유: 파이프·텍스트 도구(49)를 find(44)보다 앞에 두고, 도움말로 찾는 47 은 도구들을 익힌 뒤로 이동.

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #50 따옴표·변수·치환 익히기: 쉘이 먼저 해석하는 것들 | #50 따옴표·변수·치환 익히기: 쉘이 먼저 해석하는 것들 |
| 2 | #47 도움말로 명령 완성하기: --help 읽고 직접 찾기 | **#49 텍스트 도구 입문: 센다, 정렬한다, 뽑는다 (↑3)** ➜ |
| 3 | #44 find 천천히 익히기: 찾고, 걸러내고, 실행하기 | #44 find 천천히 익히기: 찾고, 걸러내고, 실행하기 |
| 4 | #48 grep 천천히 익히기: 글자로 줄 찾기 | #48 grep 천천히 익히기: 글자로 줄 찾기 |
| 5 | #49 텍스트 도구 입문: 센다, 정렬한다, 뽑는다 | **#47 도움말로 명령 완성하기: --help 읽고 직접 찾기 (↓3)** ➜ |
| 6 | #9 Vim 기초 | #9 Vim 기초 |
| 7 | #7 리눅스 압축과 아카이브 | #7 리눅스 압축과 아카이브 |
| 8 | #15 리눅스 로그와 텍스트 처리 | #15 리눅스 로그와 텍스트 처리 |
| 9 | #30 리눅스 터미널로 확인하고 고르기 | #30 리눅스 터미널로 확인하고 고르기 |
| 10 | #17 리눅스 쉘 스크립트 기초 | #17 리눅스 쉘 스크립트 기초 |

## [미들웨어] 로드밸런서  (단원 id 13, 점수 3, 이동 5/7)

- 이유: HAProxy 입문→심화→TCP·도메인 실습→로그·제한→문제 해결로 이어 마친 뒤, Istio 읽기(70)→YAML 고치기(92)를 묶어 배치.

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #51 HAProxy 로드밸런서 익히기: 나누고, 거르고, 확인하기 | #51 HAProxy 로드밸런서 익히기: 나누고, 거르고, 확인하기 |
| 2 | #63 HAProxy 심화: 분산 방식, 연결 제한, TLS, 이중화 | #63 HAProxy 심화: 분산 방식, 연결 제한, TLS, 이중화 |
| 3 | #70 HAProxy 와 Istio 함께 읽기: Gateway·VirtualService | **#72 HAProxy 활용 케이스 실습: TCP 포워딩, 도메인 분기, 이중화 (↑1)** ➜ |
| 4 | #72 HAProxy 활용 케이스 실습: TCP 포워딩, 도메인 분기, 이중화 | **#84 HAProxy 운영 심화: 로그 읽기, 요청 제한, 차단, URI 분산 (↑1)** ➜ |
| 5 | #84 HAProxy 운영 심화: 로그 읽기, 요청 제한, 차단, URI 분산 | **#98 HAProxy 문제 해결 상황집: 503, DOWN, 안 뜰 때 (↑2)** ➜ |
| 6 | #92 서비스 메시 YAML 읽고 고치기: Gateway, VirtualService | **#70 HAProxy 와 Istio 함께 읽기: Gateway·VirtualService (↓3)** ➜ |
| 7 | #98 HAProxy 문제 해결 상황집: 503, DOWN, 안 뜰 때 | **#92 서비스 메시 YAML 읽고 고치기: Gateway, VirtualService (↓1)** ➜ |

## [미들웨어] 관측 (모니터링·로그)  (단원 id 18, 점수 3, 이동 4/5)

- 이유: 개념→PromQL/LogQL→알림→상황집으로 기본기를 쌓고, 고급 파이프라인(74)은 마지막.

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #57 관측 입문: 메트릭·로그·트레이스와 도구 구분 | #57 관측 입문: 메트릭·로그·트레이스와 도구 구분 |
| 2 | #74 메트릭 파이프라인 읽기: Prometheus → Vector → Kafka | **#90 관측 쿼리와 설정 다루기: PromQL, LogQL, 메트릭 읽기 (↑1)** ➜ |
| 3 | #90 관측 쿼리와 설정 다루기: PromQL, LogQL, 메트릭 읽기 | **#103 Prometheus 알림 기본기: up, 알림 규칙, Alertmanager (↑1)** ➜ |
| 4 | #103 Prometheus 알림 기본기: up, 알림 규칙, Alertmanager | **#104 Prometheus 문제 해결 상황집: 타깃 DOWN, 빈 쿼리, 알림 안 옴 (↑1)** ➜ |
| 5 | #104 Prometheus 문제 해결 상황집: 타깃 DOWN, 빈 쿼리, 알림 안 옴 | **#74 메트릭 파이프라인 읽기: Prometheus → Vector → Kafka (↓3)** ➜ |

## [미들웨어] 검색·로그 저장  (단원 id 22, 점수 3, 이동 2/5)

- 이유: 검색 개념→REST 실습→검색 심화(분석기·샤드 운영)→ILM 저장 운영→문제 해결로 검색과 운영을 구분.

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #62 Elasticsearch 입문: 역색인, 샤드, refresh 와 flush | #62 Elasticsearch 입문: 역색인, 샤드, refresh 와 flush |
| 2 | #112 Elasticsearch REST 기본기: curl 로 상태 보고 넣고 검색하기 | #112 Elasticsearch REST 기본기: curl 로 상태 보고 넣고 검색하기 |
| 3 | #71 Elasticsearch ILM 운영: 인덱스의 일생과 저장소 | **#76 Elasticsearch 심화: 검색 점수, 분석기, 샤드 운영 (↑1)** ➜ |
| 4 | #76 Elasticsearch 심화: 검색 점수, 분석기, 샤드 운영 | **#71 Elasticsearch ILM 운영: 인덱스의 일생과 저장소 (↓1)** ➜ |
| 5 | #113 Elasticsearch 문제 해결 상황집: yellow/red, 미할당 샤드, 디스크 | #113 Elasticsearch 문제 해결 상황집: yellow/red, 미할당 샤드, 디스크 |

## [미들웨어] 사내 장애 사례  (단원 id 24, 점수 3, 이동 2/2)

- 이유: 복구 절차와 용어(SST/IST, 쿼럼)를 먼저 익히고 연쇄 장애 읽기(69)로 종합한다.

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #69 연쇄 장애 읽기: 증상 뒤의 원인 찾기 | **#73 장애 복구 절차 읽기: Galera 와 Kafka (↑1)** ➜ |
| 2 | #73 장애 복구 절차 읽기: Galera 와 Kafka | **#69 연쇄 장애 읽기: 증상 뒤의 원인 찾기 (↓1)** ➜ |

## [스토리지] 스토리지 기초  (단원 id 21, 점수 2, 이동 10/10)

- 이유: 개념→NFS→LVM→RAID→Ceph 운영→OpenStack 구분 순으로 의존 순서에 맞춤

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #61 인프라 스토리지·네트워크: Ceph, Cinder, Neutron 구분하기 | **#376 스토리지 개념 지도: 블록·파일·오브젝트, NFS·iSCSI, RAID (↑1)** ➜ |
| 2 | #376 스토리지 개념 지도: 블록·파일·오브젝트, NFS·iSCSI, RAID | **#377 LVM 과 Ceph 구조: PV·VG·LV 와 OSD·MON·쿼럼 (↑1)** ➜ |
| 3 | #377 LVM 과 Ceph 구조: PV·VG·LV 와 OSD·MON·쿼럼 | **#398 NFS 서버 내보내기: exports 형식, ro·sync, squash, 포트, expor… (↑2)** ➜ |
| 4 | #393 Ceph 운영: OSD up/down·in/out, PG 상태, 풀 size·min_size | **#399 NFS 클라이언트 마운트: hard·soft, timeo·retrans, rsize·wsiz… (↑2)** ➜ |
| 5 | #398 NFS 서버 내보내기: exports 형식, ro·sync, squash, 포트, expor… | **#410 LVM 논리 볼륨 다루기: lvcreate, lvextend, lvreduce (↑2)** ➜ |
| 6 | #399 NFS 클라이언트 마운트: hard·soft, timeo·retrans, rsize·wsiz… | **#411 LVM 볼륨 그룹과 PV 이동: vgcreate, pvmove, vgreduce (↑2)** ➜ |
| 7 | #410 LVM 논리 볼륨 다루기: lvcreate, lvextend, lvreduce | **#440 mdadm 으로 소프트웨어 RAID 만들기: 모드, RAID 수준, create 옵션 (↑2)** ➜ |
| 8 | #411 LVM 볼륨 그룹과 PV 이동: vgcreate, pvmove, vgreduce | **#441 mdadm 으로 배열 운영하기: 디스크 교체, detail·examine, 메타데이터, 비트맵 (↑2)** ➜ |
| 9 | #440 mdadm 으로 소프트웨어 RAID 만들기: 모드, RAID 수준, create 옵션 | **#393 Ceph 운영: OSD up/down·in/out, PG 상태, 풀 size·min_size (↓5)** ➜ |
| 10 | #441 mdadm 으로 배열 운영하기: 디스크 교체, detail·examine, 메타데이터, 비트맵 | **#61 인프라 스토리지·네트워크: Ceph, Cinder, Neutron 구분하기 (↓9)** ➜ |

## [스토리지] 파일시스템과 마운트 도구  (단원 id 70, 점수 3, 이동 8/9)

- 이유: 파일시스템 생성→식별·조회→fstab→점검·조정→분리 순, 442 는 410 중복이라 후순위/통합 권고

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #442 lvcreate 로 LV 만들기: -L·-l, %FREE·%VG, 스냅샷, 미러·줄무늬, -Z | **#443 mke2fs 로 ext 파일시스템 만들기: -t·-b·-m·-i·-N·-L, -n 시험, m… (↑1)** ➜ |
| 2 | #443 mke2fs 로 ext 파일시스템 만들기: -t·-b·-m·-i·-N·-L, -n 시험, m… | **#446 blkid 로 장치 식별하기: LABEL·UUID·TYPE, -o 출력 형식, 캐시와 -p,… (↑3)** ➜ |
| 3 | #444 fsck 로 파일시스템 점검하기: -A·-R·-N·-s, 종료 코드, fs_passno, 유… | **#450 lsblk 로 블록 장치 보기: 트리 출력, -f 파일시스템, -d·-l·-s, --outp… (↑6)** ➜ |
| 4 | #445 tune2fs 로 ext 파일시스템 조정하기: 점검 주기, -e 오류 동작, 예약 블록, 저널 | **#447 /etc/fstab 읽기: 여섯 필드, UUID 권장, defaults·noauto·nofa… (↑2)** ➜ |
| 5 | #446 blkid 로 장치 식별하기: LABEL·UUID·TYPE, -o 출력 형식, 캐시와 -p,… | **#448 findmnt 로 마운트 살펴보기: 트리 출력, -s·-T·-R, --output, --ve… (↑2)** ➜ |
| 6 | #447 /etc/fstab 읽기: 여섯 필드, UUID 권장, defaults·noauto·nofa… | **#444 fsck 로 파일시스템 점검하기: -A·-R·-N·-s, 종료 코드, fs_passno, 유… (↓3)** ➜ |
| 7 | #448 findmnt 로 마운트 살펴보기: 트리 출력, -s·-T·-R, --output, --ve… | **#445 tune2fs 로 ext 파일시스템 조정하기: 점검 주기, -e 오류 동작, 예약 블록, 저널 (↓3)** ➜ |
| 8 | #449 umount 로 안전하게 분리하기: busy, -l 지연, -f 강제, -r, -R, 종료 … | #449 umount 로 안전하게 분리하기: busy, -l 지연, -f 강제, -r, -R, 종료 … |
| 9 | #450 lsblk 로 블록 장치 보기: 트리 출력, -f 파일시스템, -d·-l·-s, --outp… | **#442 lvcreate 로 LV 만들기: -L·-l, %FREE·%VG, 스냅샷, 미러·줄무늬, -Z (↓8)** ➜ |

## [스토리지] 스왑·XFS·파티션 도구  (단원 id 71, 점수 2, 이동 7/8)

- 이유: 파티션 테이블→시그니처 삭제→스왑→XFS 순으로 의존 순서 확보

- [ ] 적용  - [ ] 제외

| # | 현재 | 제안 |
|---|---|---|
| 1 | #451 mkswap 으로 스왑 영역 만들기: swapon 필요, 첫 블록, -L·-F·-f·-c | **#457 fdisk 로 파티션 테이블 보기: 지원 형식, 섹터 0, 기본값 정렬, -l·-x·-o (↑6)** ➜ |
| 2 | #452 swapon·swapoff 로 스왑 켜고 끄기: -a, 우선순위, fstab pri=, --… | **#458 fdisk 크기 표기와 시그니처: +/- 크기, 단위 접미사, 정렬, -w·-B·-n, 스크… (↑6)** ➜ |
| 3 | #453 wipefs 로 시그니처 지우기: 조회, -a·-n·-b·-f, 파티션 테이블, 오프셋 | #453 wipefs 로 시그니처 지우기: 조회, -a·-n·-b·-f, 파티션 테이블, 오프셋 |
| 4 | #454 mkfs.xfs 로 XFS 만들기: 기본 사용, -f·-L·-N·-K, 할당 그룹, 외부 로그 | **#451 mkswap 으로 스왑 영역 만들기: swapon 필요, 첫 블록, -L·-F·-f·-c (↓3)** ➜ |
| 5 | #455 xfs_repair 로 XFS 수리하기: 언마운트, -n, dirty log 와 -L, lo… | **#452 swapon·swapoff 로 스왑 켜고 끄기: -a, 우선순위, fstab pri=, --… (↓3)** ➜ |
| 6 | #456 xfs_growfs 로 XFS 늘리기: 마운트 필요, -d·-D, -n 미리 보기, 논리 볼륨 | **#454 mkfs.xfs 로 XFS 만들기: 기본 사용, -f·-L·-N·-K, 할당 그룹, 외부 로그 (↓2)** ➜ |
| 7 | #457 fdisk 로 파티션 테이블 보기: 지원 형식, 섹터 0, 기본값 정렬, -l·-x·-o | **#455 xfs_repair 로 XFS 수리하기: 언마운트, -n, dirty log 와 -L, lo… (↓2)** ➜ |
| 8 | #458 fdisk 크기 표기와 시그니처: +/- 크기, 단위 접미사, 정렬, -w·-B·-n, 스크… | **#456 xfs_growfs 로 XFS 늘리기: 마운트 필요, -d·-D, -n 미리 보기, 논리 볼륨 (↓2)** ➜ |

