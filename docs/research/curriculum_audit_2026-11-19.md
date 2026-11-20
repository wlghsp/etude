# 커리큘럼 감사 (계단식 누적 기준) — 2026-11-19

기준: **한 단계(세트)에 새 개념 1개(많아야 2개), 단원 안에서 기초 → 핵심(결합) → 응용 순서, 앞에서 가르치지 않은 개념을 뒤에서 전제하지 않기.**
방법: 단원 72개(세트 501개)를 에이전트 15개가 나눠 읽고 세트별 새 개념·전제 개념, 문제점, 순서 제안, 징검다리 세트, 복습 설계도를 JSON 으로 정리했다. 원자료: `curriculum_audit_2026-11-19.json`.
**한계**: 대부분 세트 제목·설명·문제 제목(과 일부 본문)만 읽고 판단했다. "추정" 표시 항목은 확인 후 반영해야 하며, 순서 변경은 사용자 확인 뒤에 적용한다. (1/2)(2/2) 쌍은 의도된 반복 학습으로 보고 문제 삼지 않았다.

## 요약

- 단원 72개, 평균 점수 **2.78 / 5** (2점 24개, 3점 40개, 4점 8개, 5점 0개)
- 지적 448건: 높음 98, 중간 223, 낮음 127
- 유형: too_many_new 105, prereq_gap 104, overlap 81, order_in_unit 75, missing_bridge 63, order_in_set 20
- 세트 순서 변경 제안 단원 40개, 징검다리 세트 제안 132개, 단원 복습 설계 개념 807개

가장 흔한 문제는 (1) 한 세트가 새 개념을 너무 많이 한꺼번에 도입(too_many_new), (2) 가르치기 전에 쓰임(prereq_gap), (3) 같은 개념 반복(overlap), (4) 표시 순서가 개념 의존 순서와 어긋남(order_in_unit) 이다.

## 단원별 점수와 제안

| 코스 | 단원 | 점수 | 지적(높음/전체) | 순서변경 | 징검다리 |
|---|---|---|---|---|---|
| Git | 기초 (id 12) | 3 | 2/6 | 제안 | 2 |
| Git | 브랜치와 병합 (id 14) | 3 | 1/5 | - | 3 |
| Git | 병합과 이력 다듬기 심화 (id 49) | 2 | 3/8 | 제안 | 3 |
| Git | 원격과 협업 (id 15) | 3 | 1/5 | - | 3 |
| Git | 되돌리기와 복구 (id 17) | 3 | 0/6 | - | 2 |
| Git | 기록 살펴보기 (id 42) | 4 | 0/3 | - | 0 |
| Git | 설정·패치·내부 구조 (id 50) | 2 | 1/7 | 제안 | 3 |
| k8s | 기초 (id 6) | 3 | 2/7 | 제안 | 2 |
| k8s | kubectl 실습 기초 (id 60) | 3 | 1/7 | 제안 | 2 |
| k8s | 워크로드와 설정 (id 7) | 3 | 3/8 | 제안 | 3 |
| k8s | Pod 수명주기·보안·네트워크 정책 (id 61) | 3 | 2/7 | - | 3 |
| k8s | 자원·kubectl 도구·Job·Service 심화 (id 62) | 3 | 2/8 | - | 3 |
| k8s | 롤아웃·Pod 스펙·Kustomize·ConfigMap (id 63) | 2 | 2/8 | 제안 | 3 |
| k8s | 컨테이너 실행·재시작·Deployment 읽기 (id 64) | 2 | 2/7 | 제안 | 2 |
| k8s | 스케줄링과 워크로드 실습 (id 65) | 2 | 4/6 | 제안 | 2 |
| k8s | 스토리지와 네트워크 (id 8) | 2 | 3/6 | 제안 | 2 |
| k8s | 운영과 트러블슈팅 (id 9) | 3 | 1/7 | 제안 | 2 |
| k8s | 클러스터 운영·보안 (id 29) | 3 | 1/6 | 제안 | 3 |
| k8s | 패키지 관리 (Helm) (id 11) | 4 | 0/3 | - | 1 |
| OpenStack | 서비스 지도 (id 36) | 4 | 0/4 | - | 2 |
| OpenStack | 인스턴스 (id 37) | 3 | 2/7 | 제안 | 3 |
| OpenStack | 네트워크 (id 38) | 4 | 1/5 | - | 2 |
| OpenStack | 스토리지와 이미지 (id 39) | 3 | 0/6 | - | 1 |
| OpenStack | 인증과 운영 (id 40) | 3 | 1/6 | 제안 | 2 |
| OpenStack | 오브젝트와 자동화 (id 41) | 4 | 0/7 | 제안 | 1 |
| 가상화 | 가상화 기초 (id 48) | 3 | 1/8 | - | 3 |
| 가상화 | qemu-img·장치 설정·virsh 객체 명령 (id 72) | 3 | 0/8 | 제안 | 3 |
| 가상화 | 용어 지도 (id 16) | 3 | 0/3 | - | 0 |
| 네트워크 | 네트워크 기초 (id 47) | 3 | 1/8 | 제안 | 3 |
| 네트워크 | ip·ss·tc 도구 다루기 (id 68) | 2 | 2/7 | 제안 | 2 |
| 네트워크 | 소켓·ARP·브리지·터널 (id 69) | 2 | 2/6 | - | 2 |
| 네트워크 | 연결이 안 될 때 (id 43) | 3 | 0/4 | - | 1 |
| 데이터베이스 | SQL 1 · 조회 (id 30) | 3 | 1/5 | - | 2 |
| 데이터베이스 | SQL 2 · JOIN·서브쿼리·윈도 (id 44) | 2 | 2/6 | - | 3 |
| 데이터베이스 | SQL 3 · 데이터 바꾸기 (id 45) | 3 | 2/6 | - | 2 |
| 데이터베이스 | SQL 4 · 테이블과 인덱스 (id 46) | 3 | 0/5 | - | 1 |
| 데이터베이스 | MariaDB 운영 (id 20) | 2 | 3/8 | 제안 | 2 |
| 데이터베이스 | Redis (id 31) | 3 | 1/7 | - | 2 |
| 도커 | Docker 기초 (id 5) | 4 | 0/4 | 제안 | 0 |
| 도커 | 컨테이너 다루기 (id 32) | 2 | 2/8 | 제안 | 2 |
| 도커 | 컨테이너 조회·종료 코드·실습 (id 66) | 2 | 2/8 | 제안 | 2 |
| 도커 | 이미지와 Dockerfile (id 33) | 3 | 2/8 | - | 2 |
| 도커 | Dockerfile 심화와 이미지 실습 (id 67) | 3 | 2/8 | 제안 | 2 |
| 도커 | 네트워크와 볼륨 (id 34) | 3 | 0/8 | 제안 | 2 |
| 도커 | Compose와 운영 (id 35) | 2 | 2/7 | 제안 | 2 |
| 도커 | Dockerfile·compose 읽기 (id 10) | 4 | 0/4 | - | 1 |
| 도커 | 문제 해결 (id 26) | 3 | 0/3 | - | 2 |
| 리눅스 | 기초 (id 1) | 2 | 4/8 | 제안 | 3 |
| 리눅스 | 명령어 한 줄씩 1: 파일·권한·프로세스 (id 51) | 2 | 1/5 | - | 1 |
| 리눅스 | 명령어 한 줄씩 2: 로그·쉘·텍스트 (id 52) | 2 | 3/6 | 제안 | 1 |
| 리눅스 | 운영 도구 한 줄씩: 성능·스케줄·sed·awk (id 53) | 2 | 3/5 | 제안 | 2 |
| 리눅스 | 텍스트·파일 도구 심화 (id 54) | 2 | 2/6 | 제안 | 1 |
| 리눅스 | 쉘 스크립트와 작업 제어 (id 55) | 2 | 3/8 | 제안 | 3 |
| 리눅스 | find·읽기·출력 서식 모음 (id 56) | 3 | 0/5 | - | 1 |
| 리눅스 | 도구 다루기 (id 2) | 3 | 0/6 | 제안 | 2 |
| 리눅스 | 반복·스크립트·텍스트 실습 (id 57) | 4 | 0/7 | - | 1 |
| 리눅스 | 네트워크와 통신 (id 3) | 3 | 1/7 | 제안 | 1 |
| 리눅스 | 운영과 장애 대응 (id 4) | 2 | 2/8 | 제안 | 2 |
| 리눅스 | 운영 실습과 systemd (id 58) | 3 | 1/6 | - | 2 |
| 리눅스 | 권한·진단·커널 설정 읽기 (id 59) | 2 | 2/6 | - | 3 |
| 미들웨어 | 로드밸런서 (id 13) | 3 | 2/7 | 제안 | 2 |
| 미들웨어 | 관측 (모니터링·로그) (id 18) | 3 | 3/7 | 제안 | 1 |
| 미들웨어 | 메시징·CDC (id 19) | 3 | 2/7 | - | 2 |
| 미들웨어 | 검색·로그 저장 (id 22) | 3 | 1/6 | 제안 | 1 |
| 미들웨어 | CI/CD·레지스트리 (id 23) | 3 | 1/5 | - | 1 |
| 미들웨어 | 사내 장애 사례 (id 24) | 3 | 0/4 | 제안 | 0 |
| 미들웨어 | 설정 읽기·고치기 (id 25) | 3 | 0/3 | - | 0 |
| 미들웨어 | 동시성·이벤트 (id 27) | 2 | 2/7 | - | 2 |
| 미들웨어 | 보안·시크릿 (id 28) | 3 | 1/4 | - | 1 |
| 스토리지 | 스토리지 기초 (id 21) | 2 | 1/7 | 제안 | 1 |
| 스토리지 | 파일시스템과 마운트 도구 (id 70) | 3 | 2/8 | 제안 | 1 |
| 스토리지 | 스왑·XFS·파티션 도구 (id 71) | 2 | 1/6 | 제안 | 1 |

## 높음 등급 지적 (상위)

- [Git · 기초] order_in_unit — 핵심 실습 세트 52(config→init→첫 커밋→log 를 직접 해 보는 기초 단계)가 맨 뒤(9번째)에 있다. 앞의 한 줄씩 퀴즈 6개(138~328)가 add/commit/브랜치/reset/rebase/cherry-pick 등을 먼저 묻는데 학습자는 아직 첫 커밋도 실습하지 않은 상태다.
- [Git · 기초] too_many_new — 143 한 세트가 설정·clone·fast-forward·branch -d/-D·amend·show·blame·reflog·tag·cherry-pick·reset --soft·rebase vs merge 등 10개 이상을 도입한다. 138(9개)·149(8개)도 같다. 한 줄씩 퀴즈라 1개씩 묻지만 새 
- [Git · 브랜치와 병합] too_many_new — 373 한 세트에 bisect·rebase·merge --squash·clean·alias·restore --source·log -S·merge --abort 등 8개 이상의 새 개념이 있다. 서로 연관도 낮다.
- [Git · 병합과 이력 다듬기 심화] too_many_new — 155 이 병합 방식·원격 관리·detached HEAD·pull --rebase·force-with-lease·태그 push 등 한 세트에 10개 이상 새 개념을 담는다. 제목도 4개 주제를 나열한다. 161(8개)·172(7개)·176(9개)·184(9개)도 같은 패턴.
- [Git · 병합과 이력 다듬기 심화] prereq_gap — 155 의 pull --rebase(12번)·rebase 와 충돌 관련 설명은 rebase 를 먼저 가르치는 161(rebase -i)보다 앞에 온다. rebase 개념은 143·373 에서 한 번 언급되지만 직접 가르치는 세트는 161 이후.
- [Git · 병합과 이력 다듬기 심화] order_in_unit — 원격 주제(remote set-url, push --delete, fetch --prune, force-with-lease, 태그 push; 155 6~9·13·14번)가 '원격과 협업' 단원(order 30)보다 앞서 나온다. 같은 개념이 495 에서 손연습으로 다시 등장해 선수 지식 순서가 거꾸로다.
- [Git · 원격과 협업] too_many_new — 495 가 stash 3종(-u·apply·branch)·태그 push·원격 브랜치 삭제·prune·업스트림 지정·force-with-lease·amend --author 등 9개를 한 세트에 도입. 단원 주제(원격)와 stash·amend 는 무관.
- [Git · 설정·패치·내부 구조] too_many_new — 모든 한 줄씩 퀴즈가 7~12개 개념을 한 세트에 담는다: 168(12개: 객체·ls-tree·HEAD~·describe·태그·add -p·--merged·switch -·-vv·restore --source·status), 180(8개 이상, 서로 무관한 훅·archive·bundle·notes), 1
- [k8s · 기초] order_in_unit — 개념 입문 세트(41)가 128/287/130/288 뒤에 있다. 41 은 같은 용어를 터미널 없이 처음 소개하는 세트인데 이미 128(1/2), 287 에서 같은 용어와 kubectl 실습을 마친 뒤라 '먼저 이해하기'라는 제목과 순서가 어긋난다.
- [k8s · 기초] too_many_new — 79 가 Taint·Affinity·cordon·drain·PDB·DaemonSet·Sidecar·Ingress/Egress·Gateway API·NetworkPolicy 를 한 세트에 도입한다. '기초' 단원에 넣기에는 범위도 난이도도 크다.
- [k8s · kubectl 실습 기초] too_many_new — 19 가 dry-run·명령형 수정·라벨·jsonpath·custom-columns·explain·patch·edit·줄임말 등 8개 이상을 한 세트에 도입한다.
- [k8s · 워크로드와 설정] prereq_gap — 134(롤링 업데이트·undo)가 Deployment 가 ReplicaSet 을 갈아끼우는 원리를 전제하지만, ReplicaSet 관계는 뒤의 145 가 처음 가르친다.
- [k8s · 워크로드와 설정] too_many_new — 487 이 ownerReferences·envFrom prefix·items·docker-registry·immutable·startupProbe·field-selector·logs -l·serviceAccount 등 9개를 한 세트에 도입한다. 사실상 심화 모음이며 단원 마지막이라도 과밀.
- [k8s · 워크로드와 설정] too_many_new — 136 이 Service 3종·Endpoints·Ingress·probe 2종·nodeSelector·cordon·PV/PVC 를 한 세트에 도입한다. 네트워크·헬스체크·스케줄링·스토리지가 한 세트.
- [k8s · Pod 수명주기·보안·네트워크 정책] too_many_new — 153 한 세트가 쿼터·LimitRange, securityContext, ServiceAccount, 비공개 이미지 인증 4개 영역을 도입(1번~14번이 영역별로 이어짐). 한 세트 새 개념 1~2개 기준 초과. 기초 개념이 서로 무관해 한 번에 소화하기 어렵다.
- [k8s · Pod 수명주기·보안·네트워크 정책] too_many_new — 151 이 init 컨테이너, restartPolicy, imagePullPolicy, 종료 유예, 라벨 셀렉터, custom-columns, scale 을 한 세트에 섞음(문제 1~14가 주제별 2문제씩). 157 도 배포 전략·ConfigMap 반영·emptyDir·삭제 연쇄·노드 상태·DNS 6개 
- [k8s · 자원·kubectl 도구·Job·Service 심화] too_many_new — 178 이 Job 심화(1~8번) 에 taint·toleration(9~11), nodeAffinity(12~13), PDB(14) 를 이어 붙임. Job 필드와 스케줄링 제약은 별개 주제 3개(Job·taint/affinity·PDB). 제목에도 '스케줄링 제약'이 같이 나와 있음.
- [k8s · 자원·kubectl 도구·Job·Service 심화] too_many_new — 182 가 logs 옵션, exec, cp, port-forward, events, debug 6개 도구를 한 세트에 도입. 186 도 Endpoints·targetPort·readiness·sessionAffinity·환경 변수·헤드리스·ExternalName·expose 8주제. 174 는 label
- [k8s · 롤아웃·Pod 스펙·Kustomize·ConfigMap] order_in_unit — 205(네임스페이스 -n/-A, get all, -o name, 권한 확인)와 190(config·컨텍스트)은 단원에서 가장 기초인 kubectl 사용 기본인데 롤아웃·Pod 스펙·Kustomize 뒤에 놓임(205는 Kustomize 다음). 단원 제목(롤아웃·Pod 스펙·Kustomize·Config
- [k8s · 롤아웃·Pod 스펙·Kustomize·ConfigMap] too_many_new — 198/306 은 command·args, $(VAR), run 옵션, securityContext, startupProbe, tolerations, hostAliases, shareProcessNamespace, hostNetwork, 사이드카, --from-env-file, PriorityClass 
- [k8s · 컨테이너 실행·재시작·Deployment 읽기] too_many_new — 208 한 세트가 ConfigMap 3방식·Secret·환경변수·볼륨·갱신·subPath·immutable·PVC·emptyDir 등 8개 넘는 개념을 14문제에 몰아 가르침. 211도 kubectl 도구 10여 가지, 214·217·220도 각각 6~10개 개념.
- [k8s · 컨테이너 실행·재시작·Deployment 읽기] order_in_unit — 표시 순서가 (1/2)(2/2) 쌍 단위로 5개 주제를 병렬 나열(ConfigMap→kubectl→컨테이너→Deployment→재시작). 단원 제목은 실행·재시작·Deployment인데 ConfigMap·kubectl 도구 모음이 맨 앞에 와서 흐름이 끊김. 실행(command/args)→재시작→Depl
- [k8s · 스케줄링과 워크로드 실습] prereq_gap — 223·314 는 nodeSelector·requests·required/preferred 어피니티·PVC(StorageClass)를 전제하나, nodeSelector·requests 는 같은 단원 22 가 223 뒤에 처음 가르치고 어피니티·PVC 는 이 단원 뒤(다음 단원 세트 26, 13, 122)
- [k8s · 스케줄링과 워크로드 실습] too_many_new — 22 는 Job·CronJob·DaemonSet·requests/limits·프로브·nodeSelector·initContainers·env·HPA 를 11문제에 한 번씩 도입. 499 도 9개 서로 무관한 옵션 모음.
- [k8s · 스케줄링과 워크로드 실습] order_in_unit — 표시 순서는 223·314(Pending 진단)이 맨 앞이고, 진단 대상인 nodeSelector·requests 를 가르치는 22 가 뒤. 12·236(ConfigMap)은 단원 주제(스케줄링·워크로드)와 무관하며 이미 64 단원에서 다룬 개념 반복.
- [k8s · 스케줄링과 워크로드 실습] prereq_gap — 421(topology spread)·420(우선순위)은 podAntiAffinity·nodeAffinity·taint 를 비교·전제하나 해당 내용은 다음 단원 세트 26 에서 처음 나옴. 고급 스케줄링이 기초보다 앞섬.
- [k8s · 스토리지와 네트워크] order_in_unit — 108(입문)은 설명에 "37 전에 보는 입문"이라고 쓰였으나 표시 순서는 37 이 108 보다 앞. 또 80(개념 총정리)이 맨 앞에 있어 Service·Pod IP 입문(108·37) 이전에 CNI·Service 타입을 요구.
- [k8s · 스토리지와 네트워크] order_in_unit — 스토리지 두 세트(13 실습, 122 개념)는 중간 네트워크 세트들로 끊겨 있지 않고 붙어 있으나, 이후 네트워크 6세트가 이어져 단원이 저장소→네트워크 두 블록으로 섞임. 13 은 PVC 마운트 후 Service/port-forward 를 한 세트에 혼합.
- [k8s · 스토리지와 네트워크] too_many_new — 26 은 taint·nodeAffinity·anti-affinity·롤링·StatefulSet·PDB·종료·diff 8개로 스토리지·네트워크와 무관(단원 주제 불일치). 489 도 Ingress·ExternalName·hostAliases·downwardAPI·defaultMode·StatefulSet·
- [k8s · 운영과 트러블슈팅] overlap — 230(롤아웃과 복구)과 345(롤아웃 손연습)가 set image·rollout history·undo --to-revision·CHANGE-CAUSE·막힌 업데이트 복구를 거의 그대로 반복한다. 345가 maxSurge·pause·progressDeadline을 더해 깊어지는 점은 의도로 보이나 앞 
- [k8s · 클러스터 운영·보안] too_many_new — 120이 etcd 백업·복원, kubeadm 업그레이드, 인증서, 컨트롤 플레인 설정 변경까지 서로 다른 운영 작업 4가지를 한 세트(10문제)에서 새로 도입한다.
- [OpenStack · 인스턴스] too_many_new — 384가 스케줄러(필터·가중치), Placement, 호스트 집합, 가용 영역, 서버 그룹, resize, 마이그레이션/evacuate 7개 개념을 한 세트에 도입한다. 스케줄링과 인스턴스 이동은 분리해야 한다.
- [OpenStack · 인스턴스] prereq_gap — 413이 NUMA 노드, 소켓·코어·스레드, CPU 고정·오버커밋을 전제하지만 이 개념(하드웨어 CPU 구조)을 가르치는 세트가 이 분야에 없다. 다른 분야(리눅스/컴퓨터 원리)에서 다뤘는지 확인 필요(추정).
- [OpenStack · 네트워크] too_many_new — 385가 네트워크 유형 4종, 오버레이, ML2 두 종류 드라이버, 플러그인, L3 에이전트, SNAT/floating NAT 를 한 세트에서 처음 가르친다.
- [OpenStack · 인증과 운영] prereq_gap — 389 Nova 장애 해석은 인스턴스 상태·서버 생성·호스트 스케줄링(어피니티)을 전제하나 Nova 자체를 가르치는 세트가 이 단원에도 앞 단원에도 보이지 않음(추정: 다른 분야/단원에 있을 수 있음, 확인 필요).
- [가상화 · 가상화 기초] prereq_gap — 417 풀 유형(netfs·logical·iscsi·rbd)이 NFS·LVM·iSCSI·Ceph를 전제하나 이 단원에 그 개념을 가르친 곳 없음. 다른 분야 단원 존재 여부는 확인 못 함.
- [네트워크 · 네트워크 기초] order_in_unit — 397 dnsmasq의 --address·--no-resolv·캐시 문항은 DNS 레코드·TTL·재귀를 전제하나 DNS 기본은 405(397보다 뒤)에서 가르침.
- [네트워크 · ip·ss·tc 도구 다루기] too_many_new — 418은 한 세트에 TCP 옵션·sysctl 8~9개(NODELAY, CORK, keepalive, syncookies, 백로그, fin_timeout, retries2, window scaling)를 한꺼번에 도입한다. 전체가 문서 읽기식 12문항이라 다른 세트도 대체로 옵션 5~9개를 한 세트에서 도
- [네트워크 · ip·ss·tc 도구 다루기] order_in_unit — 418(소켓 옵션·TCP 튜닝)이 첫 세트인데 소켓/bind/listen 개념은 다음 단원 466에서 처음 가르치고, 상태 확인 도구 ss는 434에서 가르친다. 도구 단원 시작에 가장 고급 주제가 놓였다. 466·467 뒤(다음 단원)로 옮기는 편이 낫다.
- [네트워크 · 소켓·ARP·브리지·터널] prereq_gap — 466은 소켓·bind·listen이 무엇인지 설명 없이 옵션(SO_REUSEADDR, 특권 포트)부터 묻는다. 이 개념은 앞 단원 418(SO_KEEPALIVE)·434(ss -l)가 이미 전제하는데 가르치는 곳이 이 단원 첫 세트다.

## 다음 단계

1. 순서 변경 제안 40개 단원을 사용자가 검토해 확정 → 마이그레이션으로 표시 순서(`display_order`)만 재배치(ID·진행 기록 영향 없음).
2. 징검다리 세트 제안(132개)을 우선순위로 추려 신규 세트 제작. 새 세트는 "한 단계 새 개념 1개, 기초 → 핵심 → 응용" 기준으로 작성.
3. 단원 복습 세트(시험형, `is_review`)를 각 단원의 `review_outline` 을 설계도로 제작.
4. "추정"으로 표시된 지적은 문제 본문을 확인한 뒤 반영.
