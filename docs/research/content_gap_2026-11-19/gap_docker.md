# 빈틈 분석: 도커 (공개 예정)

기준: DCA 시험 영역 + 인프라 운영자 입문~중급. 근거: `merged.json` 도커 단원 9개(세트 약 70개), DB 세트 제목·문제 형식 집계, 일부 세트 SQL 본문 grep 확인(`backend/db/03_quest_set*.sql`).

## 요약

- **현재 수준**: 컨테이너 실행·수명주기, run 옵션, inspect/출력 형식, Dockerfile 지시어, 이미지 관리, Compose 기본, 볼륨·네트워크 기본, 정리(prune)는 양과 깊이가 충분하다(세트 약 70개, 터미널 실습 세트 약 20개). 문제는 **폭**이다. 한 주제를 (1/2)(2/2) 퀴즈와 손연습으로 반복하는 반면, 운영자가 실제 만나는 주변 영역이 비어 있다.
- **가장 큰 빈틈 3개**
  1. **레지스트리 실사용**(login/logout, 사설 레지스트리 push·pull 인증, 태그 전략, digest 고정): 세트 8(7문제 구형)과 160/242 퀴즈뿐. `docker login` 은 전체에서 2회만 언급(142·160 문맥, 실습 없음).
  2. **도커 데몬·엔진 운영**(daemon.json, 스토리지 드라이버 overlay2/data-root, live-restore, 서비스 재시작, 로그 기본 드라이버, 원격 DOCKER_HOST/context 실습): 전부 퀴즈 한두 문제 언급 수준. `overlay2`·`live-restore`·`systemctl` 0건.
  3. **문제 해결 상황집이 세트 97 하나**(컨테이너가 안 뜰 때)뿐: 네트워크(이름 해석·포트 접속 불가), 볼륨 권한, pull·build 실패, compose 기동 실패, 데몬 다운이 없다.
- 그 밖에: 네트워크 동작 원리(docker0·NAT·기본 bridge와 사용자 정의 bridge 차이)와 host/overlay/macvlan 드라이버, 보안 심화(rootless·userns·docker.sock·docker 그룹 권한·이미지 스캔·시크릿), 모니터링(cAdvisor/메트릭), 멀티 아키텍처 빌드(`--platform` 0건)가 없다.
- 구조 쪽 부채(순서·중복)는 이미 audit 의 `issues` 에 있으므로 여기서는 반복하지 않고 신규 세트 배치에 반영만 했다.

## 참고 커리큘럼

DCA 영역(오케스트레이션 Swarm 제외)과 일반 입문~중급 범위를 합쳐 14개 영역으로 정의했다.

| # | 영역 | 핵심 주제 |
|---|------|-----------|
| D1 | 개념·아키텍처 | 이미지/컨테이너, VM 대비, 클라이언트-데몬-containerd-runc, 네임스페이스·cgroup, OCI, 레이어·CoW |
| D2 | 컨테이너 실행·수명주기 | run/create/start/stop/kill/rm, 상태, 종료 코드, 시그널·PID 1, exec/attach, 재시작 정책, 헬스체크, ps·inspect·logs·top·stats·events·cp·diff |
| D3 | 이미지 관리 | pull/tag/rmi, 태그와 digest, save/load, export/import, commit, history, prune, 이미지 크기 |
| D4 | Dockerfile·빌드 | 지시어 전반, CMD/ENTRYPOINT, 캐시, .dockerignore, 멀티스테이지, ARG/ENV, 베이스 이미지 선택, 레이어 최소화, buildx·멀티 플랫폼, BuildKit 시크릿 |
| D5 | 레지스트리 | 사설 레지스트리, login/logout, push/pull, 인증, 태그·digest 고정, 레지스트리 API, 미러·insecure registry, 이미지 서명 개념 |
| D6 | 네트워킹 | 기본 bridge vs 사용자 정의 bridge, DNS 이름 해석, -p/-P, host·none, overlay·macvlan 개념, 포트 매핑·NAT(iptables), 격리(--internal), 네트워크 디버깅 |
| D7 | 스토리지·볼륨 | volume/bind/tmpfs, 볼륨 수명, 권한(uid), 읽기 전용, 볼륨 백업·복원, 스토리지 드라이버, 볼륨 드라이버 개념, 디스크 사용량 |
| D8 | Compose | 파일 구조, up/down/ps/logs/exec, 환경 변수·env_file, depends_on·healthcheck, networks·volumes, profiles, override·-f 병합, build, 자원 제한 |
| D9 | 보안 | 비루트 USER, capabilities, --privileged, read-only, no-new-privileges, seccomp/AppArmor, rootless·userns, docker.sock·docker 그룹, 이미지 스캔, 시크릿 취급, 이미지 출처 |
| D10 | 자원 관리 | --memory/--cpus/--pids-limit, OOM, update, ulimit, shm-size |
| D11 | 로깅·모니터링 | docker logs, 로그 드라이버·로테이션, stats, events, 데몬 로그, cAdvisor 등 메트릭 수집 개념 |
| D12 | 데몬 설정·운영 | daemon.json, data-root, 스토리지 드라이버, live-restore, 서비스 기동/재시작, docker info·version, 원격 접속(context·DOCKER_HOST), 정리·디스크 |
| D13 | 문제 해결 | 기동 실패, 종료 코드, 포트 충돌, 이름 해석, 볼륨 권한, pull/build 실패, compose 실패, 디스크·메모리 |
| D14 | (선택) Swarm | init·service·stack·secret. 사내 방향이 k8s 이므로 제외 또는 개념 퀴즈 1세트만 |

## 커버리지 표

깊이: 없음 / 얕음 / 보통 / 충분. 형식: Q=개념 퀴즈만, T=터미널 포함.

| 영역·주제 | 다루는 세트 | 깊이 | 형식 |
|-----------|-------------|------|------|
| D1 이미지 vs 컨테이너, 레지스트리 개념, VM 대비 | 40 | 충분 | Q |
| D1 네임스페이스·cgroup·레이어·CoW·OCI/containerd·PID 1 | 77 | 보통(한 세트에 개념 5개 이상) | T(4문제)+Q |
| D1 클라이언트-데몬-containerd-runc 구조 | 77 일부 | 얕음 | Q |
| D2 run 기본 옵션, stop/rm, exec | 5, 137/238 | 충분 | T+Q |
| D2 상태·시그널·종료 코드·PID 1 | 171/244, 212/255, 160/242, 478 | 충분(중복 많음) | Q+T |
| D2 rename·update·재시작 정책·OOM·wait·top | 191/249, 343 | 충분 | Q+T |
| D2 exec·attach·create/start·ps 필터·cidfile | 199/251, 488 | 충분 | Q+T |
| D2 inspect -f·ps --format·stats·port·cp·diff | 215/256, 225, 231, 203/252 | 충분 | Q+T |
| D2 헬스체크 | 343, 187/248 | 보통 | T+Q |
| D2 events | 183, 478 일부 | 얕음 | 일부 T |
| D3 pull·tag·rmi·images 필터·prune·commit·history | 218/257, 183/247, 337, 203/252 | 충분(중복) | Q+T |
| D3 save/load·export/import | 8, 337, 183 | 보통 | T |
| D3 이미지 digest, 태그 전략(latest 문제, 불변 태그) | 160/242 일부 | 얕음 | Q |
| D4 Dockerfile 기본·캐시·.dockerignore | 11, 167/243, 234, 346 | 충분 | T+Q |
| D4 CMD/ENTRYPOINT·셸/exec | 221/258, 154/241, 349, 490 | 충분(과다 반복) | Q+T |
| D4 멀티스테이지·--target·--build-arg | 154/241, 218/257, 346, 485, 501 | 보통 | T |
| D4 HEALTHCHECK·STOPSIGNAL·ONBUILD·SHELL·VOLUME | 187/248, 501 | 보통 | Q+T |
| D4 빌드 시크릿 | 501 일부 | 얕음 | T |
| D4 buildx·멀티 플랫폼(`--platform`), BuildKit 캐시 | 없음(`--platform` 0건) | 없음 | - |
| D4 베이스 이미지 선택(alpine/slim/distroless), 이미지 크기 줄이기, apt 캐시 정리 | 485(레이어 줄이기), 11(apt-get 예시) | 얕음 | T |
| D5 로컬 레지스트리 올리기·내리기 | 8(7문제), 160/242 q13 | 얕음 | T(구형) |
| D5 docker login/logout, 인증, 사설 레지스트리 접근 오류, search | 없음(login 2회 언급) | 없음 | - |
| D5 레지스트리 API(/v2/_catalog), 태그 삭제, 미러·insecure | 없음 | 없음 | - |
| D6 사용자 정의 네트워크, 이름 통신, 격리 | 179/246, 228, 498, 142/239 | 충분 | Q+T |
| D6 -p 형식·-P·EXPOSE·포트 충돌 | 209/254, 171, 97 | 보통 | Q(실습은 97 일부) |
| D6 host/none, connect/disconnect, alias, --ip, --dns | 195/250, 179, 498 | 보통 | Q+T |
| D6 기본 bridge vs 사용자 정의 bridge 차이, docker0, NAT·iptables, 호스트에서 본 veth | 없음(docker0·iptables 0건) | 없음 | - |
| D6 overlay·macvlan·ipvlan 개념 | 없음 | 없음 | - |
| D6 네트워크 디버깅(컨테이너 안에서 접속 확인, curl/nc, DNS 확인) | 228 q8 일부 | 얕음 | T |
| D7 volume·bind·:ro·--mount·tmpfs·익명 볼륨·volumes-from | 142/239, 179/246, 228, 195 | 충분 | Q+T |
| D7 볼륨 백업·복원(헬퍼 컨테이너 tar), 볼륨 마이그레이션 | 없음(백업 1회 언급) | 없음 | - |
| D7 바인드 마운트 uid·권한 문제(Permission denied) | 340/346 일부 | 얕음 | T |
| D7 스토리지 드라이버(overlay2)·data-root, 볼륨 드라이버(NFS 등) 개념 | 77(CoW 개념만) | 없음~얕음 | Q |
| D7 system df·정리 | 352, 183/247 | 충분 | T |
| D8 compose 파일 읽기·up/down/ps/logs/exec | 39, 206/253, 148/240, 237 | 충분 | Q+T |
| D8 환경 변수 우선순위·env_file·변수 치환 | 175/245, 490 | 보통 | Q+T |
| D8 depends_on 조건·profiles·scale·고아 | 175/245, 237, 490 | 보통 | Q+T |
| D8 networks·volumes 최상위, 다중 네트워크 구성(frontend/backend) | 206 q1, 237 일부 | 얕음 | T |
| D8 healthcheck + depends_on service_healthy 실습 | 175 q(퀴즈) | 얕음 | Q |
| D8 override·-f 병합, config 로 검증 | 490, 206/253 | 보통 | T |
| D8 build 포함 서비스, 이미지 갱신 흐름(build·pull·up --build) | 206/253 | 얕음 | Q |
| D8 deploy.resources·secrets·configs·extends·앵커 | 없음(x- 7건은 다른 문맥) | 없음 | - |
| D9 비루트 USER·--cap-drop·--read-only·no-new-privileges·--privileged | 160/242, 340, 346, 498 | 보통 | Q+T |
| D9 seccomp/AppArmor 기본 프로파일 | 340 q(security-opt 1회) | 얕음 | Q |
| D9 rootless·userns-remap, docker.sock 마운트 위험, docker 그룹=루트 권한 | 없음(docker.sock 1회) | 없음 | - |
| D9 이미지 취약점 스캔, 신뢰 베이스, 시크릿을 이미지에 넣지 않기 | 없음(scan 0건) | 없음 | - |
| D10 --memory·--cpus·--pids-limit·update·OOM·ulimit·shm | 340, 191/249, 195, 488 | 충분 | Q+T |
| D11 logs·--tail·-t·-f | 478, 231 | 충분 | T |
| D11 로그 드라이버·로테이션 | 183/247(Q), 498(T 일부) | 보통 | Q+일부 T |
| D11 데몬 기본 로그 설정(daemon.json), journald, 중앙 로그 수집 개념 | 없음 | 없음 | - |
| D11 모니터링(stats는 충분, cAdvisor·Prometheus 연계 개념) | 231 stats | 얕음(stats만) | T |
| D12 docker info·version | 203 q5 | 얕음 | Q |
| D12 daemon.json·data-root·live-restore·서비스 재시작 | 498 q(dns 1회) | 없음~얕음 | - |
| D12 원격 접속(context·DOCKER_HOST) | 199 q24·q29(Q) | 얕음 | Q |
| D13 컨테이너가 안 뜰 때(종료 코드·포트 충돌·디스크·이름 충돌·즉시 종료·환경 변수·재시작) | 97 | 보통 | T 5+Q |
| D13 네트워크 문제(이름 해석 실패, 접속 거부, 다른 네트워크) | 없음 | 없음 | - |
| D13 볼륨 권한·마운트 경로 문제 | 없음 | 없음 | - |
| D13 pull·push·build 실패(denied·not found·manifest unknown·COPY 경로) | 490 일부(COPY 경로) | 얕음 | T |
| D13 compose 기동 실패(YAML 오류, 변수 누락, 의존 서비스, 포트) | 490, 175 | 얕음 | T/Q |
| D13 데몬 다운, 소켓 권한(permission denied to docker.sock) | 없음 | 없음 | - |
| D14 Swarm | 343 q6 언급만 | 없음 | - |

## 빈틈 목록(우선순위)

### 필수 (없으면 공개 곤란)

1. **레지스트리 실사용 실습**(D5): login/logout, 사설 레지스트리 push·pull, 태그 규칙(`host:port/repo:tag`), 인증 실패·denied·http/https 오류, `docker search`, 레지스트리 카탈로그 조회. 근거: 세트 8 은 구형 7문제, 160/242 는 개념 퀴즈, `docker login` 실습 0. DCA 의 레지스트리 영역과 사내 운영(사설 레지스트리) 모두 핵심.
2. **네트워킹 동작 원리와 디버깅**(D6): 기본 bridge vs 사용자 정의 bridge(DNS 유무), docker0·veth·NAT, -p 가 실제로 하는 일(iptables/docker-proxy), 컨테이너 안·밖에서 접속 확인. 근거: docker0·iptables 0건, 209/254 -p 는 퀴즈뿐, 228 은 이름 통신 1개만 실습.
3. **도커 데몬 설정·운영**(D12): daemon.json 위치·형식, data-root, 스토리지 드라이버 확인(`docker info`), live-restore, 서비스 재시작과 컨테이너 영향, 데몬 로그. 근거: 전 세트에서 overlay2·live-restore 0건. 운영자에게 가장 직접 필요한 주제.
4. **문제 해결 상황집 확장**(D13): 세트 97 은 "안 뜰 때" 하나. 네트워크·볼륨 권한·pull/build 실패·compose 실패가 빠짐(상세는 `## 상황집`).
5. **보안 핵심 보강**(D9): docker.sock 마운트 위험, docker 그룹의 의미, rootless/userns 개념, 시크릿을 이미지·환경 변수·compose 에 두는 문제, 이미지 스캔 개념. 근거: 160/242·340 은 USER·cap·read-only 위주라 "도커 자체의 공격 표면"이 비어 있다.

### 권장

6. **볼륨 백업·복원과 권한**(D7): 헬퍼 컨테이너로 tar 백업/복원, 볼륨 이전, 바인드 마운트 uid·소유권 문제. 근거: 백업 1회 언급, 권한은 chown 관련 일부.
7. **Compose 구성 실습**(D8): 다중 네트워크(frontend/backend 분리), healthcheck + `service_healthy`, `up --build` 와 이미지 갱신, `-f` override 실제 병합 결과, 자원 제한(deploy/mem_limit). 근거: 175 는 퀴즈, 237 한 세트에 compose 전체를 12문제로 압축.
8. **이미지 슬림화·베이스 선택**(D4): alpine/slim/distroless 차이, 이미지 크기 비교(history·images), 캐시 정리, 비루트 최종 이미지, `latest` 문제. 근거: 485 가 레이어 줄이기만 다룸.
9. **로깅·모니터링 운영**(D11): 데몬 기본 로그 드라이버·로테이션 설정(daemon.json), journald, events 활용, stats 로 문제 컨테이너 찾기, cAdvisor 같은 수집 도구 개념. 근거: 로그 드라이버는 183 퀴즈와 498 한 문제.
10. **docker context·원격 데몬**(D12): context 생성·전환, DOCKER_HOST, ssh 접속. 근거: 199 퀴즈 2문제 뿐.
11. **네트워크 드라이버 개념**(D6): host·overlay·macvlan·ipvlan 이 언제 쓰이는지(개념 퀴즈). k8s CNI 학습 연결.
12. **buildx·멀티 플랫폼·BuildKit**(D4): `--platform`, 멀티 아키텍처 이미지, 빌드 캐시. 근거: `--platform` 0건(사내 ARM 서버·이기종 환경이 있다면 필요, 추정).

### 선택

13. Compose 고급 필드(secrets·configs·extends·YAML 앵커·watch).
14. Docker Swarm 개념(DCA 범위지만 사내 방향이 k8s라 개념 퀴즈 1세트 이하 또는 제외).
15. `--device`·`--gpus`(GPU/장치 연결), 볼륨 드라이버(NFS) 개념, 이미지 서명(content trust)·SBOM.
16. 기존 개념 세트 재배치(순서·중복 정리)는 별도 정리 작업이며 신규 제작 범위가 아니다.

## 신규 세트 백로그

세트 id 는 미정. 단원 표기는 기존 단원 제목을 사용했다(audit `merged.json` 의 도커 단원). "새 단원 제안"은 기존 단원에 맞지 않는 경우.

| 우선순위 | 제목 | 형식 | 들어갈 단원 | 선행 | 핵심 개념(계단식) | 예상 문제 수 |
|---------|------|------|-------------|------|-------------------|-------------|
| 필수 | 사설 레지스트리 쓰기 1: login·태그·push·pull | 터미널 실습 | 새 단원 "레지스트리" (현재 "이미지와 Dockerfile"·"Dockerfile 심화" 사이, 기존 세트 8을 이 단원으로 이동 권장) | 8 또는 337(tag·save), 160/242 | ① 이름 구조 `host:port/repo:tag` → ② `docker run registry:2` 로컬 레지스트리 → ③ tag 후 push, 다른 이름으로 pull → ④ `docker login/logout`(인증 레지스트리, htpasswd 구성은 제공된 환경 사용) → ⑤ `search`, 카탈로그(`/v2/_catalog`)·태그 목록 curl | 12(터미널 9 + 퀴즈 3) |
| 필수 | 레지스트리 오류 읽기: denied·not found·http 오류 | 상황집 | 새 단원 "레지스트리" 끝 또는 "문제 해결" 단원 | 위 세트 | `unauthorized`, `repository does not exist`, `manifest unknown`, `http: server gave HTTP response to HTTPS client`(insecure registries 개념), 태그 오타, latest 착각 | 10(터미널 5, 읽기 퀴즈 5) |
| 필수 | 도커 네트워크 안쪽 들여다보기: bridge·veth·NAT | 터미널 실습 | "네트워크와 볼륨" 단원 맨 앞(228 이전)으로 배치 권장 | 142/239 | ① 기본 bridge 와 사용자 정의 bridge 비교(이름 해석 유무) → ② `network inspect` 로 서브넷·게이트웨이 → ③ 호스트에서 docker0·veth 확인(`ip addr`·`ip link`) → ④ -p 가 만드는 규칙(iptables nat 출력 읽기) → ⑤ 컨테이너 안·밖에서 `curl`/`nc` 로 접속 확인 | 12(터미널 9) |
| 필수 | 포트 공개 직접 해 보기: -p·-P·바인드 주소 | 터미널 실습 | "네트워크와 볼륨" 단원, 209/254 퀴즈 뒤 | 위 세트 | `-p 호스트:컨테이너`, `127.0.0.1:` 바인딩, `-P` 와 EXPOSE, `docker port`, 충돌 재현 | 10(터미널 7) |
| 필수 | 도커 데몬 설정 읽고 바꾸기: daemon.json·data-root·스토리지 드라이버 | 터미널 실습(샌드박스에서 데몬 설정 변경 가능 여부 확인 필요, 불가하면 읽기·`docker info` 중심 퀴즈로 대체) | 새 단원 "도커 엔진 운영"(Compose 와 운영 단원 다음 또는 문제 해결 앞) | 77(구조), 203 q5 | ① `docker info` 읽기(Storage Driver·Root Dir·Cgroup·Logging Driver) → ② daemon.json 위치·JSON 문법 오류 → ③ 로그 드라이버·로테이션 기본값 → ④ data-root 변경·디스크 위치 → ⑤ live-restore 와 데몬 재시작 영향 | 12(터미널 6 + 퀴즈 6, 환경 제약 시 퀴즈 비중 증가) |
| 필수 | 문제 해결 상황집: 네트워크가 안 될 때 | 상황집 | 단원 "문제 해결" (97 다음) | 97, 네트워크 세트 | 이름으로 못 찾음(기본 bridge), 다른 네트워크라 접속 불가, 포트 미공개·잘못된 포트, 127.0.0.1 바인딩, DNS 해석 실패, 방화벽 | 12(터미널 8) |
| 필수 | 문제 해결 상황집: 볼륨·권한·디스크 | 상황집 | 단원 "문제 해결" | 97, 228 | 마운트 경로 오타로 빈 디렉터리, Permission denied(uid), 읽기 전용 오류, 볼륨 덮어쓰기, 디스크 가득(system df) | 12(터미널 8) |
| 필수 | 문제 해결 상황집: 이미지 받기·빌드가 실패할 때 | 상황집 | 단원 "문제 해결" | 레지스트리·빌드 세트 | pull 실패(태그 없음), build 실패(COPY 경로·`.dockerignore`·네트워크), 캐시 때문에 안 바뀜, `exec format error`(아키텍처) | 12(터미널 8) |
| 필수 | 문제 해결 상황집: compose 가 안 올라올 때 | 상황집 | 단원 "문제 해결" | 237, 175/245 | YAML 들여쓰기, 필수 변수 누락, 포트 중복, depends_on 만으로 준비 보장 안 됨, 이름 충돌·고아 | 12(터미널 8) |
| 필수 | 도커 보안: 소켓·권한·시크릿 | 개념 퀴즈 + 일부 터미널 | 새 단원 "컨테이너 보안"(현재 160/242·340 은 "조회·종료 코드·실습" 단원에 섞여 있어 이 단원으로 이동 권장) | 340 | ① docker 그룹 = 호스트 루트급 권한 → ② docker.sock 마운트가 위험한 이유(터미널 확인) → ③ rootless·userns 개념 → ④ 시크릿을 ENV·이미지 레이어에 넣으면 `history`/`inspect` 로 노출(터미널 확인) → ⑤ 이미지 스캔·신뢰 베이스 개념 | 12(터미널 5) |
| 권장 | 볼륨 백업·복원과 권한 | 터미널 실습 | "네트워크와 볼륨" 단원, 228 뒤 | 228 | ① 볼륨 내용 확인(헬퍼 컨테이너) → ② `tar` 로 백업(`--volumes-from` 활용) → ③ 새 볼륨으로 복원 → ④ 바인드 마운트 소유권(uid)과 `--user` | 10(터미널 8) |
| 권장 | Compose 구성 실습: 네트워크 분리·헬스체크·override | 터미널 실습 | "Compose와 운영" 단원 237 뒤 | 237, 175/245 | ① 최상위 networks 로 frontend/backend 분리 → ② healthcheck + `service_healthy` → ③ `up --build` 로 이미지 갱신 → ④ `-f` override 병합 결과(`config`) → ⑤ 자원 제한 필드 | 12(터미널 9) |
| 권장 | 이미지 작게·안전하게 만들기 | 터미널 실습 | "Dockerfile 심화와 이미지 실습" 단원 끝(501 뒤) | 485, 346 | ① alpine/slim/기본 이미지 크기 비교 → ② 패키지 캐시 정리(같은 RUN) → ③ 멀티스테이지로 빌드 도구 제거 → ④ 비루트 USER 로 마무리 → ⑤ `latest` 대신 고정 태그·digest | 10(터미널 7) |
| 권장 | 로그·이벤트·자원 보기로 운영하기 | 터미널 실습 | "컨테이너 조회·종료 코드·실습" 단원 또는 새 "엔진 운영" 단원 | 183/247, 231, 478 | ① 로그 드라이버 확인·`--log-opt` 적용 후 효과 → ② `events` 필터로 재시작 추적 → ③ `stats` 로 자원 먹는 컨테이너 찾기 → ④ 메트릭 수집 도구(cAdvisor 등) 개념 | 10(터미널 6) |
| 권장 | docker context 와 원격 데몬 | 개념 퀴즈 + 터미널 소수 | 새 단원 "도커 엔진 운영" | 데몬 설정 세트 | context 생성·전환, DOCKER_HOST, ssh 접속, 보안 주의 | 8(터미널 3) |
| 권장 | 네트워크 드라이버 개념 정리 | 개념 퀴즈 | "네트워크와 볼륨" 단원 끝 | 네트워크 세트 | host 모드, overlay(여러 호스트), macvlan·ipvlan, 언제 무엇을 쓰나, k8s CNI 와의 연결 | 8 |
| 선택 | buildx·멀티 플랫폼 이미지 | 터미널 실습 | "Dockerfile 심화와 이미지 실습" 단원 | 485 | `buildx` 기본, `--platform`, 멀티 아키텍처 확인, 빌드 캐시 | 8 |
| 선택 | Swarm 한눈에 보기 | 개념 퀴즈 | 새 단원 맨 끝 또는 제외 | - | init·service·stack·secret 개념, k8s 와 차이 | 6 |

필수 세트 총 10개, 권장 6개, 선택 2개(합 18개). 한 번에 다 만들기 부담이면 필수 중 **레지스트리 1, 네트워크 안쪽, 데몬 설정, 상황집 4종, 보안** 순으로 진행하는 편이 효과가 크다.

## 형식 균형

- 도커는 퀴즈 세트 약 50개, 터미널 실습 세트 약 20개로 **세트 수는 퀴즈 쪽이 많다**. (1/2)(2/2) 반복 세트는 문제가 거의 choice 14 + fill 1 + order 1 / fill 10 + order 4 구조라 실습 비중이 낮다. 다만 같은 주제를 실습 세트(225·228·231·234·237·337·340·343·346·349·352·478·485·488·490·498·501)가 뒤따르는 구성이라 핵심 명령은 실습이 있다.
- 실습이 필요한데 퀴즈뿐인 영역:
  - 포트 공개(209/254): 실습 없음. 신규 "포트 공개 직접 해 보기" 필요.
  - 네트워크 격리·connect/disconnect·--internal(179/246): 실습 없음.
  - 레지스트리(160/242): 개념 퀴즈. 실습은 구형 세트 8 뿐.
  - Compose 변수·depends_on·profiles(175/245): 퀴즈 중심, 237·490 에서 일부 실습.
  - 헬스체크의 compose 연동, 로그 드라이버(183/247): 퀴즈.
  - 보안 심화(docker.sock·rootless): 없음.
- 신규 세트의 권고 비율: 운영 기술 영역(레지스트리, 네트워크, 데몬, 볼륨 백업, compose 구성, 상황집)은 **터미널 70% 이상**(상황집은 터미널 70% + 읽기·진단 퀴즈 30%). 개념 성격(네트워크 드라이버, Swarm, 보안 개념)은 퀴즈 중심이되 확인 가능한 부분은 터미널 3~5문제를 섞는다.
- 세트 8(구형, 7문제, `docker-persistent` 샌드박스)은 형식이 다른 오래된 세트다(문제 수·형식 불균형). 레지스트리 세트를 새로 만들 때 흡수·재작성을 고려한다(제작 시 판단).
- 샌드박스 제약(추정): 데몬 설정 변경·iptables·docker0 확인은 컨테이너 안에서 불가하거나 제한될 수 있다. 신규 세트 제작 전에 `docker`/`docker-persistent` 샌드박스에서 가능한 범위를 확인해야 한다(제작 전 선행 확인 항목).

## 상황집

현황: 도커 분야에 상황집 세트는 **97 "도커 문제 해결 상황집: 컨테이너가 안 뜰 때" 1개**(문제 12개: 터미널 5, 퀴즈 7). 시나리오 7개(종료 코드 137, 포트 충돌, 디스크 가득, 이름 충돌, 즉시 종료, 환경 변수 누락, 재시작 정책)를 이미 다룬다(audit 도 시나리오 과다 지적, 복습 성격). 부족하다.

필요한 시나리오(오류 메시지 → 원인 → 해결, 재현 가능한 터미널 위주):

1. **네트워크**
   - `curl: (6) Could not resolve host: db` → 기본 bridge 라 이름 해석 안 됨 / 서로 다른 네트워크.
   - `Connection refused` → 서비스가 127.0.0.1 만 바인딩, 포트 미공개(`-p` 없음), 컨테이너 포트 오입력.
   - 호스트에서 접속 불가 → 포트 매핑 방향 혼동(호스트:컨테이너), 방화벽(개념).
2. **볼륨·권한·디스크**
   - `Permission denied` → 호스트 디렉터리 소유 uid 와 컨테이너 USER 불일치.
   - 마운트했더니 앱 파일이 사라짐(빈 볼륨·바인드 덮어쓰기), 경로 오타로 빈 디렉터리 생성.
   - `Read-only file system` → `--read-only`/`:ro`.
   - `no space left on device` → 이미 97 에 있으나 `system df`·볼륨/빌드 캐시 단위로 확대.
3. **이미지·빌드**
   - `pull access denied` / `manifest unknown` / `repository does not exist` → 태그·이름·로그인.
   - `http: server gave HTTP response to HTTPS client` → insecure registry 설정.
   - `COPY failed: file not found in build context` → 컨텍스트·.dockerignore.
   - `exec format error` → 아키텍처 불일치 또는 셸 스크립트 shebang 누락.
   - 소스를 고쳤는데 반영 안 됨 → 레이어 캐시, `--no-cache`, 이미지 재빌드 안 함.
4. **Compose**
   - `yaml: line N: mapping values are not allowed` → 들여쓰기.
   - `variable is not set`/필수 변수 누락 → `${VAR:?}`.
   - 서비스가 DB 보다 먼저 떠서 실패 → depends_on 의 한계, healthcheck 조건.
   - `port is already allocated`, 고아 컨테이너, 프로젝트 이름 충돌.
5. **데몬·권한**
   - `Cannot connect to the Docker daemon at unix:///var/run/docker.sock` → 데몬 정지, DOCKER_HOST/context 오설정.
   - `permission denied while trying to connect to the Docker daemon socket` → docker 그룹.
   - daemon.json 문법 오류로 데몬 기동 실패(개념/읽기 문제).
6. **자원**
   - OOMKilled(137) 확인, CPU 제한으로 느려짐(`stats`), `pids-limit` 로 fork 실패(97 이 일부 다룸, 자원 중심으로 재구성 가능).

구성 권고: 위 1~4를 각각 한 세트(10~12문제)로, 5·6 은 문제 해결 단원 말미 한 세트로 묶는다. 기존 97 은 유지하고 "안 뜰 때" 시나리오 중복은 새로 만들지 않는다. 각 세트는 문제마다 "에러 문구 읽기(퀴즈) → 재현된 환경에서 고치기(터미널)" 형태로 구성하고, 현장 이름이 아닌 일반 서비스 이름(web, db, app)을 쓴다.
