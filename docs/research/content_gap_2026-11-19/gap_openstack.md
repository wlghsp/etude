# 빈틈 분석: OpenStack

분석 기준: DB `quest_set` category='OpenStack' 23개 세트(id 353~364, 384~392, 412, 413), `audit/merged.json` 단원 36~41(6개), 세트별 문제 형식, 일부 문제 본문(354, 355, 358, 362, 364, 385, 389 문제 제목 및 362 본문 일부).
다른 분야 참조(중복 확인용): 가상화(380 KVM·QEMU·libvirt, 416·464 libvirt 네트워크), 네트워크(378 VLAN·브리지, 404 iptables), 스토리지(376 개념 지도, 377 LVM·Ceph, 393 Ceph 운영), 미들웨어(66 RabbitMQ 입문), 스토리지 61(Ceph·Cinder·Neutron 구분).

## 요약

- **현재 수준: 개념 어휘와 서비스별 심화는 "보통~좋음", 운영 실무 능력은 "없음".** 8개 핵심 서비스(Keystone·Nova·Neutron·Cinder·Glance·Swift·Heat·Horizon)가 모두 기초+심화(1~3세트)로 다뤄지고, Nova 내부(콘덕터·셀·Placement)·Fernet·ML2·Swift 링 같은 중급 주제까지 있다. 그러나 **23개 세트 전부가 `quiz`(객관식 9~11 + 빈칸 1~2 + 순서 1)이며 터미널 실습 세트는 0개(터미널 비중 0%)**. openstack CLI는 빈칸 한두 개로만 나온다.
- **가장 큰 빈틈 3개**
  1. **실습·상황집 부재(형식)**: `openstack` 명령 출력 읽기, 로그 보고 원인 찾기, 상태 복구를 직접 해 보는 세트가 0개. 389(Nova 장애 해석)조차 객관식이다.
  2. **네트워크 장애·디버깅 및 Neutron 실무**: namespace(qrouter/qdhcp), 보안 그룹·플로팅 IP 연결 안 될 때 점검 순서, DHCP/메타데이터 문제가 없다. 네트워크 유형·ML2는 있으나(385) 트러블슈팅은 없음.
  3. **운영 필수 기능 결핍**: 쿼터·사용량(quota), 서비스/호스트 상태(`compute service list`, `network agent list`, 호스트 점검·drain), 볼륨 장애(error/attaching 상태), 배포·구성 파일(nova.conf 등)·API 버전/마이크로버전, 정책(RBAC·policy) 항목이 없다.
- 순서·선수 지식 문제(merged.json 이슈): CLI 인증(362)이 가장 뒤인데 353·354·359 등이 CLI를 전제, 384·385·387·390 등 "한 세트 신규 개념 과다"가 반복됨. 신규 세트보다 **재배치·분할**이 먼저 필요한 항목도 있다(본 문서 백로그 끝의 "재배치 권고" 참조).

## 참고 커리큘럼

학습자는 사내 인프라 운영자. 기준: Operator 관점의 OpenStack 입문~중급(공식 Install/Operations/Admin 가이드, COA 시험 범위의 일반화). 배포 도구(Kolla/TripleO/Ansible 등) 상세, 개발자용(oslo 내부 코드, 플러그인 개발)은 제외.

| # | 영역(domain) | 핵심 주제 |
|---|---|---|
| D1 | 클라우드·OpenStack 개요 | IaaS, 프라이빗 클라우드, 서비스 8종 역할, 릴리스·프로젝트 거버넌스, 서버 생성 흐름 |
| D2 | 아키텍처·메시징·DB | 서비스 = API + 메시지 큐(oslo.messaging, RabbitMQ) + DB, RPC call/cast, 컨트롤러/컴퓨트/스토리지 노드 배치, 셀, Placement, 서비스 카탈로그·엔드포인트(public/internal/admin) |
| D3 | CLI·API 사용 | openstack CLI 기본(list/show/create/delete/set), 인증 환경(openrc·clouds.yaml), `--debug`, 출력 형식(-f json/value, -c, --long), REST API·마이크로버전, 필터·페이징 |
| D4 | Keystone(인증) | 도메인·프로젝트·사용자·그룹·역할, 역할 부여, 토큰(Fernet)·범위, 서비스 카탈로그, 앱 자격증명, 연합, **정책(policy)·기본 역할(admin/member/reader)** |
| D5 | Nova(컴퓨트) 기본 | 서버 생성 선택지(플레이버·이미지·키페어·보안그룹·user data), 상태·동작, console log/VNC, 서버 상세 읽기, 이미지로 스냅샷 |
| D6 | Nova 스케줄링·이동 | 필터·가중치, 호스트 집합·AZ, 서버 그룹, resize, cold/live migration, evacuate, 호스트 점검(disable/drain) |
| D7 | Nova 장애·운영 | nova.conf 주요 옵션, 서비스 상태, 로그, ERROR 원인(No valid host·Fault), reset-state, rescue, 오버커밋 비율, hypervisor stats |
| D8 | Neutron 기본 | 네트워크·서브넷·포트·라우터, provider/self-service, 보안 그룹, 플로팅 IP, DHCP, 메타데이터 서비스 |
| D9 | Neutron 구조·운영 | ML2·타입/메커니즘 드라이버, OVS/OVN 개요, L3·DHCP·metadata 에이전트, namespace, VXLAN·VLAN, **연결 안 될 때 디버깅**, MTU, 에이전트 상태 |
| D10 | Neutron 부가 | QoS, 보안그룹 규칙 심화, Router HA(VRRP), LBaaS(Octavia) 개요, FWaaS/VPNaaS는 제외 |
| D11 | Cinder | 볼륨·타입·백엔드, 스냅샷·백업, attach/detach, 멀티어태치, 마이그레이션, 부팅 볼륨, 볼륨 상태(error/attaching/in-use) 복구, 확장(extend) |
| D12 | Glance | 이미지 상태·포맷, 업로드/다운로드, 가져오기, 공유·공개 범위, 이미지 속성(메타데이터), 이미지 만들기·변환(qemu-img, cloud-init 이미지) |
| D13 | Swift | 계정·컨테이너·객체, 링·파티션·복제, 핸드오프, DLO/SLO, 만료, 이레이저 코딩, 접근 제어(ACL)·tempurl |
| D14 | Heat 자동화 | HOT, 파라미터/리소스/출력, 내장 함수, 환경 파일, 스택 상태(CREATE_FAILED)·이벤트·롤백, update, nested stack, autoscaling 개요 |
| D15 | Horizon·사용자 관점 | 대시보드로 하는 일, 프로젝트/관리자 화면 차이, CLI와의 대응 |
| D16 | 쿼터·사용량·멀티테넌시 | 프로젝트별 쿼터(compute/network/volume), 사용량 한도 초과 오류, 사용량 조회(`limits show`, `usage`), 기본 쿼터, 프로젝트 정리 |
| D17 | 운영·모니터링·장애 대응 | 로그 위치·레벨, 서비스·에이전트 상태 확인, 장애 사례(생성 실패·네트워크 끊김·볼륨 붙지 않음·큐 정체), DB 동기화·`nova-manage`류 관리 명령, 백업·업그레이드 개요, Ceilometer/Gnocchi/Prometheus는 개요만 |
| D18 | 스토리지 백엔드 연계 | Cinder/Glance/Nova + Ceph RBD 연계(풀 분리, 복제본 CoW), LVM 백엔드, 볼륨 타입 ↔ 백엔드 |

## 커버리지 표

깊이: 없음 / 얕음 / 보통 / 충분. 형식: 퀴즈(개념) / 실습(터미널). **현재 모든 세트가 퀴즈 형식이므로 형식 칸은 전부 "퀴즈만"이다**(양식에서 빈칸 문제 1~2개가 CLI 명령 외우기 수준). 아래 깊이 판단은 문제 제목·new_concepts 근거(354·355·358·362·364·385·389는 문제 제목 목록까지 확인, 나머지는 merged.json 개념 기준 — 일부 `추정`).

| 영역 | 주제 | 다루는 세트 | 깊이 | 형식 |
|---|---|---|---|---|
| D1 | IaaS·서비스 8종·서버 생성 흐름 | 353, 354 | 충분 | 퀴즈만 |
| D1 | 릴리스 주기·거버넌스·프로젝트 생태 | — | 없음(선택) | — |
| D2 | Nova 4구성요소·oslo.messaging·셀·Placement | 390 | 보통(1세트에 과다 압축) | 퀴즈만 |
| D2 | 메시지 큐 장애(RabbitMQ 정체) | 390(개념), 66(RabbitMQ 입문, 미들웨어) | 얕음 | 퀴즈만 |
| D2 | 서비스 카탈로그·엔드포인트(public/internal/admin) | 361·354에서 문장 수준 | 얕음 | 퀴즈만 |
| D2 | 컨트롤러/컴퓨트/스토리지 노드 배치·HA 구성 | — | 없음 | — |
| D3 | CLI 형식(list/show/create), 환경 변수·clouds.yaml, 인증 확인 | 362(+353·354 빈칸) | 얕음~보통 | 퀴즈만 |
| D3 | `-f json -c --long`, 필터, `--debug`, 마이크로버전, REST 직접 호출(curl+토큰) | — | 없음 | — |
| D4 | 도메인·프로젝트·사용자·그룹·역할·토큰 | 361 | 보통 | 퀴즈만 |
| D4 | Fernet·토큰 범위·앱 자격증명·연합 | 387 | 보통 | 퀴즈만 |
| D4 | 기본 역할(admin/member/reader)·policy.yaml·RBAC 오류(403) | — | 없음 | — |
| D5 | 서버 선택지(플레이버·이미지·키페어·SG·user data) | 356 | 보통 | 퀴즈만 |
| D5 | 서버 상태·stop/pause/suspend/shelve/reboot | 355 | 보통 | 퀴즈만 |
| D5 | console log/URL, `server show` 필드 읽기(fault·addresses·OS-EXT-*) | 389(일부 console log) | 얕음 | 퀴즈만 |
| D5 | 서버 스냅샷(이미지 만들기), 서버 삭제·복원(soft delete) | 355·356에 단편 | 얕음 | 퀴즈만 |
| D5 | 플레이버 심화·CPU 고정·NUMA | 412, 413 | 충분(실무 활용도 대비 과함) | 퀴즈만 |
| D6 | 스케줄러·Placement·호스트 집합·AZ·서버 그룹·resize·마이그레이션·evacuate | 384(+390 Placement) | 보통(1세트에 7개 개념) | 퀴즈만 |
| D6 | 호스트 점검 절차(disable → live migrate → 작업), live migration 조건·실패 | 384(일부) | 얕음 | 퀴즈만 |
| D7 | Nova 로그·흔한 원인·reset-state·rescue·어피니티 | 389 | 보통 | 퀴즈만 |
| D7 | "No valid host was found" 원인 분해, 오버커밋·allocation ratio, hypervisor stats, nova.conf 주요 옵션 | 384(필터 일부) | 얕음 | 퀴즈만 |
| D7 | 서비스 상태(`compute service list`) 읽기·down 처리 | — | 없음 | — |
| D8 | 네트워크·서브넷·포트·라우터 | 357 | 보통 | 퀴즈만 |
| D8 | provider/self-service·SG·플로팅 IP·DHCP | 358 | 보통 | 퀴즈만 |
| D8 | 메타데이터 서비스(169.254.169.254)·cloud-init 연계 | 356(user data)만 | 얕음 | 퀴즈만 |
| D9 | ML2·네트워크 유형·L3 에이전트·NAT | 385 | 보통(과다 압축) | 퀴즈만 |
| D9 | namespace(qrouter·qdhcp)·OVS/OVN 개요·에이전트 상태 | — | 없음 | — |
| D9 | 연결 장애 디버깅(핑·SG·플로팅·라우팅·MTU) | — | 없음 | — |
| D10 | QoS·Router HA·Octavia 개요 | — | 없음(선택) | — |
| D11 | 볼륨·스냅샷·백업·이미지 볼륨·ephemeral | 359 | 보통 | 퀴즈만 |
| D11 | 멀티어태치·마이그레이션·타입·증분 백업 | 386 | 보통 | 퀴즈만 |
| D11 | 볼륨 확장(extend), 부팅 볼륨 서버 삭제 시 동작(delete_on_termination), 볼륨 상태 복구(reset-state·detach 실패) | 389 q4(재연결 실패)만 | 얕음 | 퀴즈만 |
| D12 | 이미지 상태·포맷·공개 범위 | 360 | 보통 | 퀴즈만 |
| D12 | 가져오기·deactivated·공유·멤버 | 388 | 보통 | 퀴즈만 |
| D12 | 이미지 만들기·변환(qemu-img convert, cloud-init 이미지, 속성 hw_*) | 가상화 459·460(qemu-img) | 얕음(OpenStack 맥락 연결 없음) | 퀴즈만 |
| D13 | 계층·프록시·링 | 363, 391 | 충분 | 퀴즈만 |
| D13 | 핸드오프·DLO/SLO·만료·이레이저 코딩 | 391 | 보통 | 퀴즈만 |
| D13 | ACL·tempurl·공개 컨테이너 | — | 없음(권장) | — |
| D14 | HOT 구조·파라미터·내장 함수·환경 파일 | 364, 392 | 충분 | 퀴즈만 |
| D14 | 스택 실패(CREATE_FAILED)·이벤트·롤백·update·nested | — | 없음 | — |
| D15 | Horizon 개요 | 364(1세트에 합쳐 소개) | 얕음 | 퀴즈만 |
| D16 | 쿼터·한도 초과 오류·사용량 조회·프로젝트 정리 | — | 없음 | — |
| D17 | 로그 위치·읽는 순서 | 362, 389 | 보통 | 퀴즈만 |
| D17 | 서비스·에이전트 상태, 장애 시나리오 전반, 큐 정체 | — | 없음 | — |
| D17 | 업그레이드·백업·DB 관리 명령·용량 계획 | — | 없음(선택) | — |
| D18 | Ceph RBD 연계(Cinder·Glance·Nova 공용 풀, CoW 복제) | 61(Ceph·Cinder 구분), 377·393(Ceph 자체, 스토리지 분야) | 얕음 | 퀴즈만 |
| D18 | Cinder 볼륨 타입 ↔ 백엔드 | 386(일부) | 얕음 | 퀴즈만 |

세트별 형식 분포(DB 조회): 353 choice9·fill2·order1(354는 choice11·fill1·order1, 355 choice10·fill1·order1), 나머지 20개 세트는 choice9·fill2·order1. **터미널 문제 0개, 전부 sandbox_type=quiz.** 형식은 균일하게 3종(객관식·빈칸·순서)이지만 객관식이 약 75~85%를 차지한다. 빈칸 문제는 명령어 한두 개 채우기(예: 362 q10 "토큰 발급", 364 q10 "스택 만들기")다.

## 빈틈 목록(우선순위)

### 필수 (없으면 공개 곤란)
1. **F1 상황집(장애 대응 실습) 전무** — D17. 근거: 23개 중 389만 장애 주제이며 객관식. "오류 메시지 → 원인 → 해결" 실습 0개.
2. **F2 터미널 실습 0%** — 전 영역. 근거: 모든 세트 `quiz`. 운영자가 `openstack` 출력을 읽고 판단하는 능력을 평가·훈련하지 못함. (현실성 평가는 `형식 균형` 참조)
3. **F3 CLI 사용 기초가 맨 뒤·얕음** — D3. 근거: 362가 인증 단원 중간(display_order 17번째)에 있고 353·354·356·359·360·361이 CLI 빈칸을 앞서 요구(merged.json 이슈: 353·354 prereq_gap, 361 order_in_unit). 출력 형식 선택(-f/-c), `show`로 상세 읽기, 필터가 없음.
4. **F4 네트워크 연결 장애 디버깅** — D9. 근거: 357·358·385 모두 개념. "VM이 핑 안 됨/외부 안 나감/DHCP 안 받음" 점검 순서와 namespace·에이전트 개념이 없음. OpenStack 현장 장애의 1순위.
5. **F5 쿼터와 사용량** — D16. 근거: 전 세트 검색 결과 quota 주제 없음(412에서 플레이버 quota 키만 언급). "Quota exceeded" 는 가장 흔한 사용자 문의.
6. **F6 서비스·호스트 상태 읽기와 운영 점검** — D7·D17. 근거: `compute service list`, `network agent list`, `hypervisor list/stats`, `volume service list` 같은 운영자 기본 점검 주제 없음. 384(호스트 집합)·389가 일부 암시만.

### 권장
7. **F7 Nova "No valid host"·ERROR 원인 분해** — D7. 389가 q3 정도만(문제 제목 "BUILD 에서 ERROR"). 스케줄러 필터별 실패 원인과 `server show` 의 fault 읽기를 실습화 필요.
8. **F8 볼륨 장애(error/attaching/detaching, 삭제 불가, 부팅 볼륨 삭제 동작)** — D11. 359·386은 정상 흐름 중심, 389 q4만 단편.
9. **F9 Keystone 정책·기본 역할(403)** — D4. 361은 역할 개념 소개, 387은 토큰 중심. reader/member/admin 구분과 "You are not authorized" 해석 없음.
10. **F10 Heat 스택 실패·이벤트·롤백·update** — D14. 364·392 모두 템플릿 구조. 스택 상태 읽기가 없음(merged.json 이슈 missing_bridge).
11. **F11 서비스 구성·메시징 장애(큐 정체·RPC 타임아웃)** — D2·D17. 390 개념 한 세트만. 66(RabbitMQ 입문)과 연결이 없음.
12. **F12 메타데이터·cloud-init 연계** — D8. 356 user data 문장 수준. "키페어 주입 안 됨/호스트네임 안 바뀜" 같은 흔한 증상의 원인이 메타데이터 경로임.
13. **F13 이미지 만들기·변환 실무(qemu-img·cloud 이미지·hw 속성)** — D12. 360·388은 상태·공유 중심. 가상화 459·460(qemu-img)과 OpenStack 이미지 업로드 흐름이 연결되지 않음.
14. **F14 서버 이동 절차: 호스트 점검(disable→live migration→evacuate)** — D6. 384에 개념은 있으나 한 세트에 7개 압축, 절차·실패 사례 없음.
15. **F15 REST API·토큰 직접 호출·마이크로버전** — D3. CLI 밑에 API가 있다는 이해, `curl` + `X-Auth-Token`, 카탈로그에서 엔드포인트 찾기.
16. **F16 Ceph 백엔드 연계** — D18. 61·377·393이 각각 있으나 "Glance/Cinder/Nova가 같은 Ceph 풀을 쓰는 이유(복제 없이 CoW)"가 없음.

### 선택
17. **F17 Swift ACL·tempurl** — D13. 363·391은 구조 중심.
18. **F18 Octavia·QoS·Router HA 개요** — D10.
19. **F19 업그레이드·DB 관리·릴리스** — D17. 운영자에게 필요하나 사내 학습 목적상 후순위.
20. **F20 Horizon 독립 세트** — D15. 현재 Heat 와 한 세트(364)에 합쳐져 있어 얕음. 신규 개념 비중이 작아 분리 필요성은 낮음.

활용도 낮아 제외: 개발자용 oslo 내부, 배포 도구 상세, FWaaS/VPNaaS, Ironic·Magnum·Trove 등 선택 서비스, 413(CPU 고정·NUMA)처럼 이미 과하게 깊은 영역의 추가.

## 신규 세트 백로그

세트 id 는 미정. 단원 id 는 기존(36 서비스 지도, 37 인스턴스, 38 네트워크, 39 스토리지와 이미지, 40 인증과 운영, 41 오브젝트와 자동화). 형식 표기: 실습(터미널) 세트는 모의 CLI 샌드박스 전제(아래 `형식 균형`의 S1~S3 구성안). 예상 문제 수는 기존 관례(12~13문제)에 맞춤, 터미널 세트는 8~10 문제 권장.

| 우선순위 | 제목 | 형식 | 들어갈 단원 | 선행 | 핵심 개념(계단식) | 예상 문제 수 |
|---|---|---|---|---|---|---|
| 필수 | **openstack CLI 처음 쓰기: list·show·create·delete 와 인증 환경** | 터미널 실습 (모의 CLI) | 36 서비스 지도 맨 앞(354 다음, 390 앞으로 이동 권고. 362 의 CLI 인증 부분은 이 세트로 일부 이관) | 353, 354 | ① `openstack <리소스> <동작>` 형식, `list`/`show` ② 인증 환경 변수·`openrc`, `token issue`로 확인 ③ 출력 줄이기(`-c`, `-f value`, `--long`) ④ 에러 읽기(401·403·404) | 10 |
| 필수 | **CLI 출력 읽기: server show 와 목록 필터** | 터미널 실습 | 37 인스턴스(355 다음) | CLI 처음 쓰기, 355 | ① `server list --status`, 필터·정렬 ② `server show` 의 status·addresses·fault·flavor·volumes ③ console log ④ 서버 만들기·삭제 | 10 |
| 필수 | **쿼터와 사용량: 한도 초과 오류 읽고 풀기** | 터미널 실습 + 상황집 일부 | 40 인증과 운영(361 뒤) 또는 신규 단원 "운영" | 361, CLI 처음 쓰기 | ① 프로젝트 단위 쿼터(compute·network·volume) 종류 ② `quota show`, `limits show --absolute` ③ "Quota exceeded for cores" 해석과 `quota set`(admin) ④ 기본 쿼터 vs 프로젝트별 쿼터, 사용량 vs 한도 | 9 |
| 필수 | **서비스·호스트 상태 점검: service list·agent list·hypervisor** | 터미널 실습 | 신규 단원 "운영과 장애 대응"(40 뒤에 신설 제안) 또는 40 내 후반 | CLI 처음 쓰기, 390 | ① `compute service list`의 State/Status 읽기 ② `network agent list`(alive/XXX) ③ `volume service list` ④ `hypervisor list/stats`, 용량·오버커밋 ⑤ down 서비스가 사용자 증상으로 나타나는 모양 | 9 |
| 필수 | **상황집: 서버가 ERROR 로 만들어질 때(원인 읽기)** | 상황집 (터미널, 로그·`server show` 픽스처) | 신규 단원 "운영과 장애 대응" | 서비스·호스트 상태 점검, 389, 384 | ① fault 메시지 읽기 ② No valid host(원인별: 자원 부족·AZ·필터) ③ 이미지/네트워크/볼륨 때문에 실패하는 경우 ④ 로그 grep 순서(req-id 따라가기) ⑤ 복구(삭제 후 재생성·reset-state) | 8 |
| 필수 | **상황집: VM 이 네트워크에 안 붙을 때** | 상황집 (터미널: `ip netns` 모의·`openstack port show` 픽스처) | 38 네트워크(385 뒤) | 358, 385 | ① 점검 순서(포트 상태→SG→DHCP→라우터→플로팅) ② `port show`·`security group rule list` 읽기 ③ namespace(qdhcp/qrouter) 개념 ④ 에이전트 down·MTU 증상 ⑤ 메타데이터 경로(169.254.169.254) | 9 |
| 권장 | **Neutron namespace 와 에이전트 한눈에: qrouter·qdhcp·metadata** | 개념 퀴즈 + 읽기 실습 | 38 네트워크(385 앞, "385 징검다리") | 358 | ① 에이전트 종류 ② namespace 가 필요한 이유 ③ qrouter 안에서 보이는 인터페이스(`ip addr`, `ip route`) ④ 플로팅 IP 는 어디에 붙나(NAT 규칙) | 12 |
| 권장 | **상황집: 볼륨이 붙지 않을 때·삭제되지 않을 때** | 상황집 | 39 스토리지와 이미지(386 뒤) | 359, 386, 389 | ① 볼륨 상태(available/in-use/attaching/error/deleting) ② attach 실패 원인 ③ 스냅샷 있어 삭제 불가 ④ 서버 삭제 시 볼륨 처리(delete_on_termination) ⑤ reset-state 위험성 | 8 |
| 권장 | **Keystone 역할과 정책: 403 읽기와 reader·member·admin** | 개념 퀴즈 + 읽기 실습 | 40 인증과 운영(361 뒤, 387 앞) | 361 | ① 기본 역할 3종 ② 역할 부여 범위(프로젝트·도메인·시스템) ③ `policy.yaml` 규칙 읽기(`rule:admin_api`) ④ "You are not authorized" 대응 ⑤ 서비스 사용자(서비스 프로젝트) | 12 |
| 권장 | **Heat 스택 실패 읽기: 이벤트·상태·롤백** | 상황집 (터미널: `stack event list` 픽스처) | 41 오브젝트와 자동화(392 뒤) | 364, 392 | ① 스택 상태(CREATE_FAILED·ROLLBACK) ② `stack event list`/`resource list` 읽기 ③ 파라미터 오류 vs 리소스 오류 ④ update 시 replace 위험 ⑤ 삭제 실패 | 8 |
| 권장 | **Nova 가 서버를 두는 곳: 스케줄링 세트 분할(필터와 Placement)** | 개념 퀴즈 | 37 인스턴스 | 390 | 기존 384 신규 7개 개념 중 스케줄러·필터/가중치·Placement 만 분리(재배치 권고 참조). 새 세트 아님이면 "분할" 항목 | (기존 384 분할) |
| 권장 | **호스트 점검 절차: disable·live migration·evacuate 실습** | 터미널 실습(모의 CLI) | 37 인스턴스(384 뒤, 마지막) | 384 분할 후, 서비스 상태 점검 | ① `compute service set --disable` ② live migration 조건(공유 스토리지·CPU 호환) ③ 실패 사례 ④ evacuate 는 호스트 down 일 때만 ⑤ 점검 후 enable | 8 |
| 권장 | **메시징과 서비스 구성 실무: 큐 정체·RPC 타임아웃** | 상황집 | 36 서비스 지도(390 뒤) 또는 운영 단원 | 390, 66 | ① 서비스 로그의 `MessagingTimeout` ② RabbitMQ 큐 길이·소비자 수(`rabbitmqctl list_queues`) ③ 서비스 down 과 구분 ④ 재시작 순서 | 8 |
| 권장 | **서버 생성 후 안 되는 것들: 메타데이터·cloud-init** | 상황집 | 37 인스턴스(356 뒤) | 356, 358 | ① 메타데이터 경로 ② 키페어/호스트네임 안 들어옴 ③ cloud-init 로그 위치(`/var/log/cloud-init.log`) ④ user data 문법 오류 | 8 |
| 권장 | **이미지 만들어 올리기: qemu-img 변환과 Glance 업로드·속성** | 터미널 실습(qemu-img 실제 사용 가능) | 39 스토리지와 이미지(360 뒤, 388 앞 또는 뒤) | 360, 가상화 459·460 | ① 포맷 변환(`qemu-img convert -f qcow2 -O raw`) ② `image create --file --disk-format --container-format` ③ 속성(`hw_disk_bus`, `os_distro`) ④ 업로드 후 상태 확인(queued→active) | 9 |
| 권장 | **REST API 로 호출해 보기: 토큰·카탈로그·마이크로버전** | 터미널 실습(`curl` + 로컬 모의 API) | 36 서비스 지도(CLI 처음 쓰기 뒤) | CLI 처음 쓰기 | ① CLI 는 API 래퍼 ② `X-Auth-Token` ③ 카탈로그에서 엔드포인트 찾기 ④ 마이크로버전 헤더 | 8 |
| 선택 | Ceph 와 OpenStack 연계: 공용 풀·CoW 복제 | 개념 퀴즈 | 39 스토리지와 이미지(끝) | 386, 스토리지 393 | RBD 풀(images/volumes/vms), 이미지→볼륨 즉시 복제 | 12 |
| 선택 | Swift 접근 제어: ACL·tempurl | 개념 퀴즈 | 41 오브젝트와 자동화(391 뒤) | 363 | 컨테이너 ACL, 공개 읽기, 임시 URL | 12 |

필수 6개 + 권장 중 상황집·실습 위주를 먼저 만들 것을 권한다. 필수 6세트만 만들어도 "운영자가 실제 화면에서 보게 되는 모양"을 처음 다루게 된다.

### 기존 세트 재배치·분할 권고 (신규 세트가 아닌 정리 작업)
merged.json 이슈 근거. 콘텐츠 보강 계획에 함께 넣으면 선수 지식 문제가 줄어든다.
- 362(CLI 인증·로그)를 단원 36 뒤쪽 또는 단원 40 맨 앞으로(353·354·359가 CLI 빈칸을 쓰므로). 위 "CLI 처음 쓰기" 신규 세트와 역할을 나눌 것(362는 로그 위치·읽는 순서 중심으로).
- 384(7개 개념)는 "스케줄링(필터·가중치·AZ·호스트 집합·서버 그룹)"과 "인스턴스 이동(resize·마이그레이션·evacuate)"으로 분할, 412·413 뒤로 이동(merged 이슈 too_many_new 높음/order_in_unit).
- 385(네트워크 유형·ML2·L3·NAT)는 분할 권장(유형/오버레이 vs ML2·L3·NAT). 358~385 사이에 namespace·에이전트 징검다리(위 백로그) 삽입.
- 390(구성요소·메시징·셀·Placement)은 "구성요소+메시징"과 "셀+Placement"로 분리 고려.
- 355(상태)와 356(만들 때 고르는 것) 순서: 356을 먼저(merged 이슈).
- 389(Nova 장애 해석)는 362(로그 읽는 순서) 바로 뒤로.

## 형식 균형

**현황**: OpenStack 분야 23세트 약 284문제 중 터미널 0개(0%). 객관식 약 80%, 빈칸 약 15%, 순서 약 5%. 같은 인프라 분야인 리눅스(79 세트 terminal)·k8s(39)·도커(20)와 달리 OpenStack은 `sandbox` 테이블에 맞는 이미지가 없어 전부 `quiz`다. 사내 현장 용도(실무자가 CLI·로그·대시보드를 보며 판단)에는 **읽기 중심 실습이 가장 부족**하다.

**권고 비율(분야 전체)**: 터미널·읽기 실습·상황집 세트 비중 35~45%, 개념 퀴즈 55~65%. 현재 23세트 + 백로그 필수 6 + 권장 실습·상황집 약 8을 합치면 실습 계열이 약 14/37 = 38%가 된다. 영역별로는 다음과 같다.

| 영역 | 현재 | 권고 |
|---|---|---|
| D3 CLI·API | 퀴즈 빈칸 | 실습 80% 이상 (CLI는 손으로 쳐야 익힘) |
| D7·D17 운영·장애 | 퀴즈 1세트 | 실습·상황집 80% |
| D8·D9 네트워크 | 퀴즈만 | 개념 60 / 상황집 40 |
| D11 Cinder | 퀴즈만 | 개념 70 / 상황집 30 |
| D14 Heat | 퀴즈만 | 개념 70 / 템플릿 읽기·고치기(`validate` 가능) 30 |
| D13 Swift | 퀴즈만 | 개념 80 / 링 빌더 실습 20 (아래 현실성 참고) |
| D1·D2·D4·D12 개념 중심 영역 | 퀴즈 | 퀴즈 유지(읽고 고치기 문제 추가) |

### 샌드박스 실습의 현실성 평가

실제 OpenStack(DevStack 등)은 최소 수 GB 메모리·긴 기동 시간·네트워크 설정이 필요해 세션당 컨테이너 방식에는 **비현실적**(추정). 사내 서버 분리 보류 방침(MEMORY)과도 충돌. 대안:

| 방식 | 내용 | 현실성 | 비고 |
|---|---|---|---|
| **S1. 모의 `openstack` CLI(스크립트)** | `etude-linux` 이미지 위에 `openstack` 셸/파이썬 래퍼 설치. 고정 픽스처(JSON/텍스트)에서 `server list`, `server show`, `network list`, `quota show` 등의 출력을 실제 포맷(표·`-f json`·`-c`)으로 반환. 일부 상태형 동작(`create`/`delete`/`set`)은 로컬 상태 파일로 흉내 | **높음** | 새 샌드박스 타입 `linux`+도구 추가 또는 `setup_cmd`로 설치. 읽기 실습·"어떤 명령을 칠까" 채점(출력 일치·상태 파일 검사)에 충분. 지원 명령 범위를 좁게(수십 개) 정의해야 유지비가 낮음. 현실감 한계는 있음(실제 에러 형식 차이) → 정확한 에러 메시지는 픽스처에 박아 둠 |
| **S2. 로그·설정 파일 픽스처** | `/var/log/nova/nova-compute.log` 등 가짜 로그, `nova.conf`·`neutron.conf`·`policy.yaml` 를 두고 grep·less·편집으로 원인 찾기 | **높음** | 리눅스 실습 인프라 그대로 사용. 상황집의 핵심. 로그는 일반화·익명화(현장 정보 금지 원칙) |
| **S3. 실제 도구 일부 오프라인 사용** | `swift-ring-builder`(pip `swift`), `keystone-manage fernet_rotate`, Heat 템플릿 YAML 문법 확인, `qemu-img`(가상화 분야에서 이미 사용), `rabbitmqctl`(미들웨어 66과 같은 계열) | **중간** (추정) | 패키지 설치 크기·시간 확인 필요. 링 빌더·Fernet 키 회전은 서버 없이도 동작하는 것으로 알려져 있음(추정, 구현 전 검증). qemu-img 만 현재 이미지에서 바로 가능 |
| **S4. 설정 파일 읽고 고치기(quiz 레이아웃)** | 터미널 없이 `nova.conf` 조각·`server show` 출력·`policy.yaml` 을 보여 주고 "문제가 되는 줄/다음 명령"을 고르는 문제 | **높음** | 샌드박스 비용 0. 당장 기존 `quiz` 세트에 적용 가능(CLAUDE.md 정책의 "퀴즈도 실습 연계형 문제로"와 일치) |
| **S5. 실제 경량 OpenStack(Keystone 단독, Swift AIO 이미지 등)** | 서비스 하나만 컨테이너로 띄움 | **낮음~중간** (추정) | 컨테이너 기동·이미지 크기·유지 비용. 필요성은 낮음 |

권고: **S1+S2를 기본으로, S4를 기존 퀴즈 세트에 즉시 적용**. S3은 Swift 링 빌더·Fernet 정도만 선택 적용. 첫 단계로 S1 지원 명령은 서버·네트워크·볼륨·이미지·쿼터·서비스 상태의 list/show 와 서버 create/delete/stop/start, 쿼터 set 정도로 제한할 것.

## 상황집

**현황**: "오류 메시지 → 원인 → 해결"을 직접 따라가는 상황집은 **없음**. 389(Nova 장애 해석과 복구)가 가장 가깝지만 객관식·빈칸 위주(문제 제목: 컴퓨트 로그 위치, BUILD→ERROR, 볼륨 재연결 실패, 콘솔 로그, 삭제 중 멈춤, rescue, 어피니티)이고 로그·출력 픽스처를 읽는 문제가 아니다. 362의 "로그 읽는 순서"도 개념 문제다.

**필요한 시나리오**(일반화, 현장 정보 없음). 각 시나리오는 증상 메시지(또는 명령 출력) 제시 → 원인 좁히기 → 조치 순서로 구성:

| # | 시나리오 | 증상(모의 출력) | 원인 후보 → 조치 | 세트 |
|---|---|---|---|---|
| 1 | 서버가 ERROR | `fault: No valid host was found` | 자원 부족/필터 불일치/AZ → `compute service list`, `hypervisor stats`, 플레이버·AZ 조정 | 상황집: 서버가 ERROR |
| 2 | 쿼터 초과 | `Quota exceeded for cores: Requested 4, but already used 20 of 20` | `quota show`·정리 or 증설 | 쿼터와 사용량 |
| 3 | SSH 접속 불가 | 플로팅 IP 있음, 핑·SSH 안 됨 | 보안 그룹 규칙 없음/라우터 게이트웨이 없음/포트 down → 점검 순서 | VM 네트워크 상황집 |
| 4 | DHCP 안 받음 | 인스턴스 콘솔에 `no lease`, 포트는 ACTIVE | DHCP 에이전트 down, 서브넷 DHCP 비활성 | 〃 |
| 5 | 인스턴스 메타데이터 실패 | 콘솔 로그에 `failed to get metadata`, 키 주입 안 됨 | 메타데이터 에이전트·라우터 경로 | 메타데이터·cloud-init 상황집 |
| 6 | 볼륨 붙지 않음/삭제 안 됨 | `volume status: error_attaching`, `Volume in use`/`has snapshots` | 호스트 문제·스냅샷 먼저 삭제·reset-state 주의 | 볼륨 상황집 |
| 7 | 서비스 down | `compute service list` 에서 State=down | 콘덕터/큐 연결·서비스 재시작, `MessagingTimeout` 로그 | 서비스·호스트 상태 점검 / 메시징 |
| 8 | 403/401 | `You are not authorized to perform the requested action`, `The request you have made requires authentication` | 토큰 만료/프로젝트 범위/역할 부족 | 역할과 정책 |
| 9 | 스택 생성 실패 | `CREATE_FAILED`, `Resource CREATE failed` | 파라미터 제약·쿼터·이미지 없음 → `event list` | Heat 실패 |
| 10 | 이미지 올렸는데 사용 불가 | 상태 `queued`/`killed`/`deactivated` | 업로드 중단·포맷 불일치·관리자 비활성화 | 이미지 만들어 올리기(마지막 문제 구간) |
| 11 | live migration 실패 | `Migration pre-check error` 등 | CPU 호환·공유 스토리지 미설정·대상 호스트 자원 | 호스트 점검 절차 |
| 12 | 호스트 장애 후 복구 | 컴퓨트 down, 서버 ACTIVE 로 남음 | evacuate 전제(호스트 down 확인), reset-state 순서 | 호스트 점검 절차 |

우선 1·2·3·4·7을 필수 6세트에 포함하고 나머지는 권장 세트에 배분한다. 시나리오 정답 채점은 모의 CLI의 상태 파일 변화나 명령 입력 일치로 가능(위 S1·S2).

---
작성 근거 한계: 문제 본문은 354·355·358·362·364·385·389 의 제목과 362 일부만 직접 확인했다. 나머지 세트의 깊이는 merged.json 의 `new_concepts`·`issues` 기준이며 일부 `추정`이다. 문서의 "모의 CLI 지원 명령 범위", "S3 오프라인 도구 동작"은 구현 전 검증이 필요한 추정이다.
