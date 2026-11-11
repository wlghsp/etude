# 명세 — k8s 깨진 Pod 진단 실습 세트 (ImagePullBackOff · CrashLoopBackOff · OOMKilled · readiness 실패)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-11). 세트 339. 근거: 장애 Pod 를 고치는 문제는 세트 23(트러블슈팅 실전, 12문제 전부 "고치기"), 33(이미지 태그·주소 고치기), 107·220·313(상태 읽기·종료 코드 퀴즈)에 있다. 이 세트는 **고치기보다 "읽는 도구"**(`describe` 의 Events·Last State, `logs --previous`, `logs -c`, `get events --sort-by`, `exec`)를 한 문제에 하나씩 익히고, 읽은 결과를 파일로 저장해 내용으로 채점한 뒤 고치는 것까지 이어 간다.

## 목표

깨진 Pod 의 증상(ImagePullBackOff, CrashLoopBackOff, OOMKilled, READY 0/1)을 보고 `describe` 의 Events 와 Last State(Reason·Exit Code), `logs --previous`, `logs -c`, `get events --sort-by=.lastTimestamp`, `exec` 로 원인을 읽고, 이미지 태그·명령·메모리 한도·readiness 조건을 고쳐 Pod 를 Ready 로 만든다. 12문제, 쉬운 것부터.

## 원칙

- 터미널 9문제는 **결과 기반 채점**이다. "저장한 describe 파일에 Events 와 `Failed to pull image` 가 있다", "이미지가 `busybox:1.36` 이고 Ready 다", "저장한 로그에 `config file not found` 가 있다", "`/tmp/exitcode.txt` 가 `42` 다", "새 Pod(uid 가 setup 때와 다름)가 Ready, 재시작 0 이다", "`/tmp/reason.txt` 가 `OOMKilled` 다", "메모리 한도가 `128Mi` 이고 Ready 다", "컨테이너 안에 `/tmp/ready` 가 있고 Ready, 재시작 0, probe 가 남아 있다", "sidecar 로그만 저장됐다" 처럼 상태·파일 내용을 확인한다. 풀기 전(setup 만 한 상태)에는 모두 실패해야 한다.
- 새 개념은 한 문제에 하나만. `describe` 로 이미지 오류 읽기 → `set image` → (빈칸 `--sort-by`) → `logs --previous` → Last State 종료 코드 → 명령 고쳐 다시 만들기 → (객관식 137/OOMKilled) → OOM Reason 읽기 → 메모리 한도 키우기 → readiness 실패와 `exec` → `logs -c` → 진단 순서로 쌓는다.
- 학습자 권한은 자기 네임스페이스 `edit` 뿐이다 ([spec_k8s_session_permissions.md](spec_k8s_session_permissions.md)). Pod 조회·생성·삭제·`exec`·`logs` 만 쓴다.
- 이미지는 `busybox:1.36` 만 정상으로 쓴다. 이미지 오류용 `busybox:1.99` 는 일부러 없는 태그다. nginx 는 쓰지 않는다.
- 일부러 고장 낸 Pod 를 기다릴 때는 고정 `sleep` 대신 **결정적 조건을 최대 90초 폴링**한다 (CrashLoopBackOff 간격 때문에 sleep 은 불안정). 이미지 오류는 `state.waiting.reason` 이 `ErrImagePull|ImagePullBackOff`, 크래시는 `lastState.terminated.exitCode` 가 생길 때까지, OOM 은 `lastState.terminated.reason=OOMKilled` 가 될 때까지, readiness 는 phase `Running` 까지.
- 연습용 Pod 는 전부 `etude=lab339` 라벨을 달고, setup 정리는 이 라벨과 고정 이름(`diag-img`, `diag-exit`, `diag-crash`, `diag-fix`, `diag-oom`, `diag-ready`, `diag-multi`)만 지운다 (`--all` 은 쓰지 않는다).
- 기본 ServiceAccount 가 모든 Pod 에 volumeMount 를 하나 더 붙이므로 volumeMounts 는 검사하지 않는다. `kubectl` 플래그의 부수 효과에 기대지 않고 `jsonpath` 로 관찰 가능한 값(이미지, 메모리 한도, `ready`, `restartCount`, `uid`)만 본다. 다시 만든 Pod 인지는 setup 이 `/tmp/uid339` 에 적어 둔 uid 와 비교한다.

  | Pod | 증상 | 쓰는 문제 |
  |-----|------|-----------|
  | `diag-img` | 이미지 `busybox:1.99` (없는 태그), 컨테이너 `main` | 1, 2 |
  | `diag-crash` | `echo 'boom: config file not found'` 후 `exit 3` | 4 |
  | `diag-exit` | `exit 42` | 5 |
  | `diag-fix` | `exit 1` 로 바로 종료 | 6 |
  | `diag-oom` | `limits.memory: 10Mi` 에서 20MB 를 메모리에 올린다. 매니페스트 `/tmp/oom.yaml` 을 setup 이 만든다 | 8, 9 |
  | `diag-ready` | readinessProbe `cat /tmp/ready` 가 실패해 READY 0/1 | 10 |
  | `diag-multi` | 컨테이너 `app`, `sidecar` 각각 한 줄을 출력 | 11 |

- 파일은 학습자가 직접 `>` 로 만든다 (`/tmp/describe.txt`, `prev.log`, `exitcode.txt`, `reason.txt`, `sidecar.log`). setup 이 `/tmp/*.txt`, `*.yaml`, `*.log` 를 지운다.

## 세트 구성 (12개)

터미널 9 + 빈칸 1 + 객관식 1 + 순서 1.

| # | 형식 | 제목 | 새로 익히는 것 | 채점(상태) |
|---|------|------|----------------|------------|
| 1 | 터미널 | describe 로 ImagePullBackOff 원인 읽기 | `describe` 의 Events | 저장한 파일에 `Name: diag-img`, `Events:`, `Failed to pull image` |
| 2 | 터미널 | kubectl set image 로 틀린 이미지 태그 고치기 | `set image pod/이름 컨테이너=이미지` | 이미지 `busybox:1.36`, Ready, Running |
| 3 | 빈칸 | get events 를 시간순으로 정렬하기 | `--sort-by=.lastTimestamp` | 정답 칩 |
| 4 | 터미널 | logs --previous 로 직전 컨테이너 로그 읽기 | `logs --previous` | `/tmp/prev.log` 에 `config file not found` |
| 5 | 터미널 | Last State 의 종료 코드 읽기 | Last State 의 Exit Code | `/tmp/exitcode.txt` 가 `42` |
| 6 | 터미널 | 옳은 명령으로 Pod 다시 만들어 CrashLoop 벗어나기 | 명령은 못 바꾸니 지우고 다시 만든다 | 새 uid, Ready, 재시작 0, 이미지 `busybox:1.36` |
| 7 | 객관식 | 종료 코드 137 과 OOMKilled | 137 = 128+SIGKILL, 메모리 한도 초과 | 정답 보기 |
| 8 | 터미널 | OOMKilled 를 describe 로 확인하기 | Last State 의 Reason | `/tmp/reason.txt` 가 `OOMKilled` |
| 9 | 터미널 | 메모리 한도를 키워 OOMKilled 고치기 | 한도는 못 바꾸니 매니페스트 수정 후 다시 만든다 | 새 uid, `limits.memory=128Mi`, Ready, 재시작 0 |
| 10 | 터미널 | readinessProbe 실패로 READY 0/1 인 Pod 를 exec 로 고치기 | readiness 실패는 죽이지 않고 Ready 만 막는다, `kubectl exec` | Ready, 재시작 0, 컨테이너 안에 `/tmp/ready`, probe 설정 유지 |
| 11 | 터미널 | logs -c 로 컨테이너 둘 중 하나의 로그 읽기 | `logs -c 컨테이너` | `/tmp/sidecar.log` 에 sidecar 줄만 있음 |
| 12 | 순서 | 깨진 Pod 를 진단하는 순서 | get → describe → logs --previous → 고쳐 다시 만들기 → get | 정답 순서 |

## 기존 세트와의 겹침

- 세트 23 의 1·3·6·11번(이미지 오타, CrashLoopBackOff, Readiness 실패, OOMKilled)과 증상이 같다. 23번은 **고치는 것**만 채점하고 읽는 도구는 요구하지 않는다. 이 세트는 `describe`·`logs --previous`·`logs -c`·종료 코드·Reason 을 **읽어서 파일로 저장**하게 한 뒤 고치게 해서 다르다. 세트 33 의 1번(이미지 태그 고치기)은 2번과 개념이 겹친다. 세트 107·220·313 은 퀴즈형이고 227·236 은 Service·설정 주입 진단이다. 통합 시 중복 정도를 다시 본다.
- 이벤트(`get events --sort-by`)와 `logs -c` 는 기존 터미널 세트에 없다.

## 배치

k8s 단원 9 운영과 트러블슈팅 끝, display_order 287, 아이콘 🩻. 세트 339, `sandbox_type = k8s`, 분야 k8s. 구현: `gen339.py` (gen336.py 복사본)로 `backend/db/02_quest_set.sql` 행, `backend/db/03_quest_set339.sql`, `backend/verify/set339.json`, 마이그레이션(`2026-11-13_k8s_pod_diagnosis_set339.sql`, 세트 INSERT 와 문제 INSERT 만)을 만든다. 단원·아이콘·display_order 는 넣지 않는다.

## 수용 조건

- [x] 터미널 9문제 모두 `solution` 을 실행하면 채점이 통과한다 (`verify:quests --set 339`).
- [x] 터미널 9문제 모두 setup 만 한 상태에서는 채점이 실패한다.
- [x] `checks` 가 이미지·메모리 한도·`ready`·`restartCount`·uid 같은 **실제 상태**와 저장한 파일 내용을 확인한다. 존재 여부만 보지 않는다.
- [x] 고장 Pod 를 기다리는 setup 이 결정적 조건 폴링(최대 60~90초)으로 끝나고, 같은 이름 Pod 가 지워지는 중이어도 다시 setup 해서 재현된다.
- [x] 6·9번이 "지우고 다시 만들기" 외의 우회(예: 이름만 바꾼 새 Pod)로 통과하지 않는다 (uid·이름 고정 확인).
- [x] 8번의 OOM 재현이 실제로 `OOMKilled`(137)로 기록된다 (코드상 가정, 클러스터에서 확인 필요).
- [x] 객관식 정답 번호는 DB 에서 보기 글자를 출력해 확인한다 (7번). 빈칸 칩에 정답이 둘이 아니다 (3번). 순서 정답 인덱스가 설명과 맞는다 (12번).
- [x] 각 터미널 문제 `docs` 에 공식 문서 링크가 달려 있다 (링크 200 확인함: debug-pods, determine-reason-pod-failure, pod-lifecycle, 프로브, manage-resources-containers).
- [x] 각 setup 의 정리가 `etude=lab339` 라벨과 고정 Pod 이름만 지운다.
- [x] `check-content.sh`, `check-migrations.sh` 통과.
- [ ] 화면: 세트가 k8s 탭에 보이고 1번부터 12번까지 순서대로 풀린다 (수동 확인).
