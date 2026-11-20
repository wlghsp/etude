# 미들웨어 분야 콘텐츠 빈틈 분석

분석 기준: DB `quest_set`(category=미들웨어, 세트 37개) + `audit/merged.json`의 미들웨어 단원 9개 + 세트별 문제 형식 집계. 문제 본문 키워드 검색(LIKE)으로 주제 존재 여부 확인. 아래 "추정" 표시는 제목·키워드만으로 판단한 것.

## 요약

- 현재 수준: **개념 이해와 장애 읽기는 두터운데, 손으로 해보는 실습이 얇다.** HAProxy(7세트)·Kafka(6+2세트)·Prometheus(5세트)·Elasticsearch(5세트)는 입문~상황집까지 갖췄다. 반면 메시징·ES·CI/CD·Vault는 전부 또는 대부분 객관식이다. 공개 수준에는 "프록시 일반(Nginx)", "RabbitMQ 실습", "TLS·인증서", "Redis(캐시)", "로그 수집 파이프라인"이 비어 있다.
- 가장 큰 빈틈 3개
  1. **Nginx/리버스 프록시 실습 부재** — HAProxy만 있고 Nginx 언급은 문제 본문에 0건(검색 결과). 현장에서 가장 흔한 웹 프록시인데 빠져 있음.
  2. **TLS·인증서 다루기(openssl, 만료, 체인) 전용 세트 부재** — 63(개념)·116(x509 한 문제) 정도. 필수 운영 기술.
  3. **로그 수집·검색 파이프라인(Fluent Bit/Logstash→ES, Kibana/Grafana 읽기)과 RabbitMQ·Redis 실습 부재** — 57/74/66에 개념만 있고 명령 실습 0.
- 세트 구조 문제: 세트 58·62·82·100·110은 새 개념 과다(audit 지적). 순서 문제는 단원 내 70, 74, 69/73. 이는 신규 세트가 아니라 재배치·분할 대상이므로 본 문서에서는 백로그 말미에 "분할 제안"으로만 적는다.
- 신규 세트 제안 14개(필수 5, 권장 6, 선택 3).

## 참고 커리큘럼

학습자: 사내 인프라 운영자. 입문~중급 운영 범위. 도구가 아니라 일반 개념 중심(예: "리버스 프록시", "메트릭 수집", "메시지 브로커").

| # | 영역 | 핵심 주제 |
|---|------|-----------|
| D1 | 로드밸런싱 개념·L4/L7 | L4 vs L7, 분산 알고리즘, 헬스체크, 세션 고정, 이중화(VRRP) |
| D2 | HAProxy | frontend/backend, ACL, stats, timeout, stick-table, 로그, 문제 해결 |
| D3 | Nginx / 리버스 프록시 | server/location, proxy_pass, upstream, 헤더 전달(X-Forwarded-For), 정적 서빙, 로그·에러 로그, 502/504, reload, 캐시·gzip 기초, rate limit |
| D4 | TLS/인증서 | 인증서·체인·CA, openssl 확인, 만료 점검, SAN/CN, TLS 종료/패스스루, SNI, mTLS 개념 |
| D5 | 관측 개념 | 메트릭/로그/트레이스, 모니터링 vs 관측, SLI/SLO |
| D6 | Prometheus 운영 | scrape, exporter(node/blackbox), PromQL, 알림, Alertmanager, recording rule, 용량·보존 |
| D7 | 대시보드·로그 도구 | Grafana 패널·변수·데이터소스, Loki/LogQL, 로그 수집 에이전트, ELK 흐름 |
| D8 | 분산 추적 | trace/span, 샘플링, OTel 계측 개념 |
| D9 | 메시징 개념 | 큐 vs 로그, 전달 보장, 순서, 멱등, DLQ, 백프레셔 |
| D10 | Kafka | 토픽·파티션, 컨슈머 그룹, lag, 복제·ISR, 보관, Connect, 장애 |
| D11 | RabbitMQ | exchange/queue/binding, ack, prefetch, durable, DLX, 관리 UI·CLI(rabbitmqctl), 큐 적체·연결 |
| D12 | Redis/캐시 | 자료형, TTL·eviction, 캐시 패턴(stale·stampede), 지속성(RDB/AOF), 레플리카, 모니터링 명령 |
| D13 | Elasticsearch | 역색인, 샤드, REST, 매핑·분석기, 상태(yellow/red), ILM, 디스크 워터마크, 스냅샷 |
| D14 | CI/CD | 파이프라인 개념, Jenkinsfile, agent, 아티팩트, 롤백, 배포 전략(롤링/블루그린/카나리) |
| D15 | 레지스트리·저장소 | 이미지 레지스트리(push/pull/태그/인증), Nexus 저장소, 이미지 정리(GC), 취약점 스캔 개념 |
| D16 | GitOps/IaC | Argo CD, 선언형, 드리프트, IaC 기초 |
| D17 | 서비스 메시 | sidecar, Gateway/VirtualService, mTLS, 카나리, 트래픽 정책 |
| D18 | 보안/시크릿 | 시크릿 관리, Vault, k8s Secret 한계, 최소 권한, 로테이션 |
| D19 | 동시성·이벤트 | 경쟁 상태, 락, 데드락, 멱등, 재시도·백오프, 이벤트 설계 |
| D20 | 통합 장애 대응 | 연쇄 장애, 로그로 원인 좁히기, 복구 순서 |

제외(활용도 낮음): Zookeeper 단독 운영, Tomcat 튜닝 깊이, Zabbix, Jaeger 설치 운영 세부, 서비스 메시 컨트롤플레인 내부.

## 커버리지 표

깊이: 없음 / 얕음 / 보통 / 충분. 형식: Q=개념 퀴즈, T=터미널 실습 포함(세트 내 terminal 문제 수), S=상황집.

| 영역 | 주제 | 현재 세트 | 깊이 | 형식 |
|------|------|-----------|------|------|
| D1 | L4/L7·분산·헬스체크·세션 고정·VRRP | 51, 63 | 충분 | 51 T(7), 63 Q |
| D2 | HAProxy 기본·ACL·stats | 51 | 충분 | T |
| D2 | TCP 포워딩·도메인 분기·backup | 72 | 충분 | T(6) |
| D2 | 로그 타이밍·deny·stick-table·uri 분산 | 84 | 충분 | T(4) |
| D2 | 문제 해결(502/503/504, bind 충돌) | 98 | 충분 | S, T(5) |
| D3 | Nginx server/location/proxy_pass/upstream | 없음 | **없음** | — |
| D3 | X-Forwarded-For·Host 전달, 502/504, 에러 로그, reload | 없음(HAProxy 쪽 72/98에서 유사 개념만) | **없음** | — |
| D3 | gzip·캐시·rate limit(limit_req) | 없음(rate limit은 84 stick-table) | **없음** | — |
| D4 | TLS 종료 vs 패스스루, SNI | 63 | 얕음 | Q |
| D4 | 인증서 체인·openssl 확인·만료 점검 | 116(x509 사설 CA 1문제) | **얕음** | T 일부 |
| D4 | 인증서 갱신·자동화·mTLS 개념 | 92(mTLS 1건) | 얕음 | Q |
| D5 | 메트릭/로그/트레이스 구분 | 57 | 충분 | Q |
| D5 | SLI/SLO·에러 버짓 | 없음 | 없음 | — |
| D6 | PromQL·counter/gauge·카디널리티 | 90 | 보통 | T(3) |
| D6 | up·알림 규칙·Alertmanager | 103 | 보통 | T(4) |
| D6 | 문제 해결(타깃 DOWN, 빈 쿼리, 알림 안 옴) | 104 | 충분 | S, T(5) |
| D6 | exporter 개념(node_exporter, blackbox) | 103·104에 단편 | 얕음 | 단편 |
| D6 | federation·recording rule·remote_write | 74 | 얕음 | Q |
| D6 | 보존·디스크·TSDB 용량 | 없음 | 없음 | — |
| D7 | Grafana 대시보드·변수·패널 | 57, 104에 언급만 | **얕음** | Q 언급 |
| D7 | Loki·LogQL 필터 | 57, 90 | 얕음~보통 | 90 일부 T |
| D7 | 로그 수집 에이전트(Fluent Bit/Vector/Logstash)·파이프라인 설정 | 74(Vector 읽기), 57(구분) | 얕음 | Q |
| D7 | Kibana/ES 로그 검색 | 없음 | 없음 | — |
| D8 | 분산 추적 개념·OTel | 57(개념 한 줄) | **얕음** | Q |
| D9 | 전달 보장·순서·멱등·DLQ·백프레셔 | 86, 101 | 충분 | Q |
| D10 | 토픽·파티션·컨슈머 그룹 개념 | 58, 101 | 충분 | Q |
| D10 | CLI 실습(kafka-topics/consumer-groups, offset) | 89 | 보통 | T(4) |
| D10 | 복제·ISR·acks·advertised·KRaft | 67 | 충분 | Q |
| D10 | 문제 해결 | 114 | 보통(개념 중심) | S이나 터미널 0 |
| D10 | Kafka Connect·Debezium·CDC | 58, 68, 89 | 충분 | Q |
| D10 | 스키마(Schema Registry)·압축(compaction) | 68(tombstone), 67(보관정책) | 얕음 | Q |
| D11 | RabbitMQ exchange/queue/binding/ack/DLX | 66 | 보통 | **Q만** |
| D11 | rabbitmqctl·관리 UI·큐 적체·unacked | 없음 | **없음** | — |
| D12 | Redis 자료형·TTL·eviction·지속성·레플리카 | 없음(Redis는 락 예제로만 등장: 100, 115) | **없음** | — |
| D13 | 역색인·샤드·refresh/flush | 62 | 충분 | Q |
| D13 | REST 기본기 | 112 | 보통 | T(5) |
| D13 | 매핑·분석기·BM25·샤드 운영 | 76 | 보통 | Q |
| D13 | ILM | 71 | 보통 | Q |
| D13 | 상황집(yellow/red, 워터마크) | 113 | 보통 | T(5) |
| D13 | 스냅샷·복구, 인덱스 템플릿 실습 | 없음 | 없음 | — |
| D14 | CI/CD 개념·Jenkinsfile | 64 | 보통 | Q |
| D14 | Jenkins 운영·PVC | 93 | 보통 | T(3) |
| D14 | 배포 전략(롤링/블루그린/카나리)·롤백 | 82 q8, q14(단일 인스턴스), 92(카나리 가중치) | 얕음 | Q |
| D14 | 파이프라인 실습(Jenkinsfile 작성·디버깅) | 없음 | **없음** | — |
| D15 | 레지스트리 push/pull·인증·태그 | 64, 116 | 보통 | 116 T(3) |
| D15 | 레지스트리 정리(GC)·보존 정책·취약점 스캔 | 없음 | 없음 | — |
| D15 | Nexus 저장소 운영(릴리스/스냅샷, 프록시) | 64, 116 | 얕음~보통 | 일부 |
| D16 | GitOps·Argo CD | 82 | 얕음(개념만, 13문제 전부 Q) | Q |
| D16 | IaC 기초 | 82 q11~12 | 얕음 | Q |
| D17 | Istio Gateway/VS/카나리 | 70, 92 | 보통 | 92 T(3) |
| D17 | sidecar·mTLS·DestinationRule·장애 주입 | 없음 | 얕음 | — |
| D18 | Vault 개념·seal·KV·정책 | 110 | 보통 | **Q만** |
| D18 | Vault 백업 | 111 | 보통 | Q만 |
| D18 | k8s Secret 한계·base64, 시크릿 로테이션·로그 유출 | 없음 | 없음 | — |
| D19 | 경쟁 상태·락·멱등·재시도 | 100, 115 | 충분 | T |
| D19 | 이벤트 스트리밍 설계(Outbox 등) | 101 | 보통 | Q |
| D20 | 연쇄 장애·복구 순서 | 69, 73 | 보통 | Q |
| D20 | 설정 읽기·고치기 | 88 | 보통 | T(5) |

## 빈틈 목록(우선순위)

번호는 백로그와 대응.

### 필수 (없으면 공개 곤란)

1. **Nginx 리버스 프록시 기본**(D3) — 키워드 검색 0건. HAProxy와 별개로 가장 흔한 프록시. 근거: 미들웨어 전 세트에서 nginx 문자열 없음.
2. **Nginx 문제 해결 상황집**(D3) — 502/504, upstream 연결 거부, 설정 문법 오류, 413, 권한. HAProxy 98에 대응하는 짝이 없음.
3. **TLS·인증서 실습**(D4) — openssl s_client/x509 확인, 체인, 만료, SAN 불일치. 현재 63은 개념, 116은 한 문제. 현장 장애 단골(인증서 만료).
4. **RabbitMQ 실습**(D11) — 66은 13문제 전부 객관식·순서. rabbitmqctl, 큐 적체, unacked 실습 없음.
5. **Redis 기본기**(D12) — 캐시/세션/락의 사실상 표준인데 독립 세트 없음. 100·115에서 락 예제로만 사용.

### 권장

6. **로그 수집 파이프라인 실습**(D7) — 수집 에이전트→저장소 흐름과 설정 읽기. 57/74는 개념뿐.
7. **Grafana·대시보드 읽기**(D7) — 패널·변수·쿼리 연결, 임계 시각화. 언급만 있음.
8. **Prometheus exporter·용량 기본**(D6) — node_exporter 지표 읽기, blackbox 개념, 보존·디스크. 103/104에 단편.
9. **CI/CD 파이프라인 실습(Jenkinsfile 디버깅)**(D14) — 64는 개념 13문제 전부 Q, 93은 PVC 중심. 빌드 실패 읽기는 116에 일부.
10. **배포 전략과 롤백**(D14/D17) — 롤링·블루그린·카나리·롤백 비교를 하나의 단원으로. 현재는 82와 92에 흩어짐.
11. **Elasticsearch 스냅샷·템플릿 실습**(D13) — 장애 복구와 운영 필수. ILM(71)은 Q이고 스냅샷은 없음.
12. **Kafka 상황집의 실습화**(D10) — 114는 13문제 중 터미널 0. 최소 5문제는 재현형 터미널로.

### 선택

13. **SLI/SLO·알림 설계**(D5) — 알림 피로·에러 버짓 개념. 103에서 알림 규칙은 다루나 설계 관점 없음.
14. **분산 추적 입문**(D8) — trace/span, 컨텍스트 전파. 57에서 한 줄. 실습 환경 구성 비용이 큼.
15. **Vault 실습 전환·k8s Secret 한계**(D18) — 110·111이 개념뿐. 터미널 실습으로 전환하거나 k8s Secret 비교 세트.
16. **레지스트리 정리(GC)·취약점 스캔 개념**(D15).
17. **Kafka 스키마·compaction**(D10) 깊이 확장.

## 신규 세트 백로그

단원명은 현재 단원 기준. "새 단원" 제안은 위치를 적음. 예상 문제 수는 기존 평균(11~13)에 맞춤. 터미널 실습은 샌드박스 `linux` 타입 사용 가정. 샌드박스에 해당 도구(nginx, openssl, redis, rabbitmq)가 설치돼 있는지 확인 필요(추정: nginx·redis·openssl은 패키지 설치로 가능, rabbitmq는 이미지 크기 확인 필요).

| 우선순위 | 제목 | 형식 | 들어갈 단원 | 선행 | 핵심 개념(계단식) | 예상 문제 수 |
|----------|------|------|-------------|------|-------------------|--------------|
| 필수 | N1. Nginx 리버스 프록시 익히기: server·location·proxy_pass | 터미널 실습 | **새 단원 "웹 서버·리버스 프록시"**: 로드밸런서 단원 뒤(HAProxy 98 다음)에 배치 | 51 | 1) server 블록·nginx -t·reload / 2) location 매칭 순서(prefix·정규식) / 3) proxy_pass로 백엔드 연결 / 4) upstream 여러 대 + 헤더 전달(Host, X-Forwarded-For) / 5) 정적 서빙·access/error 로그 읽기 | 11 (터미널 7) |
| 필수 | N2. Nginx 활용: HTTPS·리다이렉트·제한·캐시 기초 | 터미널 실습 | 위 새 단원 | N1, T1 | 301 redirect / ssl_certificate 설정 / limit_req 요청 제한 / gzip·proxy_cache 기초 / 타임아웃(proxy_read_timeout) | 10 (터미널 6) |
| 필수 | N3. Nginx 문제 해결 상황집: 502, 504, 413, 설정 오류 | 상황집 | 위 새 단원, 98(HAProxy 상황집)과 짝 | N1 | 502 upstream 연결 거부 / 504 타임아웃 / 413 client_max_body_size / nginx -t 오류 읽기 / 포트 충돌·권한 오류 / error.log 읽기 | 12 (터미널 6) |
| 필수 | T1. TLS·인증서 다루기: 확인, 체인, 만료 | 터미널 실습 | **새 단원 "TLS·인증서"**: 로드밸런서 단원 직후 또는 보안 단원 앞 | 63(TLS 종료 개념) | 1) 인증서·CA·체인 개념 / 2) openssl x509로 만료일·CN·SAN 보기 / 3) openssl s_client로 서버 인증서 확인 / 4) 체인 불완전·만료·호스트명 불일치 오류 읽기 / 5) 자체 서명 인증서 만들고 서버에 적용 | 11 (터미널 6) |
| 필수 | T2. 인증서 장애 상황집: 만료, 체인 누락, 사설 CA | 상황집 | "TLS·인증서" 단원 | T1 | 만료 임박 점검 스크립트 / x509 unknown authority / 체인 누락(중간 인증서) / SAN 불일치 / 갱신 후 reload 누락 | 10 (터미널 6) |
| 필수 | R1. RabbitMQ 명령 실습: 큐·exchange 만들고 확인 | 터미널 실습 | 메시징·CDC 단원, 66 뒤 | 66 | rabbitmqctl list_queues/exchanges/bindings / 큐 선언·바인딩 확인 / 메시지 수(ready/unacked) 읽기 / 사용자·vhost·권한 기본 | 10 (터미널 6) |
| 필수 | R2. RabbitMQ 문제 해결 상황집: 큐 적체, unacked, 연결 | 상황집 | 메시징·CDC 단원 | R1 | 큐가 계속 쌓임 / unacked 급증(ack 누락) / 연결·채널 폭증 / 디스크·메모리 알람(flow control) / DLX로 간 메시지 확인 | 10 (터미널 5) |
| 필수 | C1. Redis 기본기: 키·TTL·자료형 | 터미널 실습 | **새 단원 "캐시·키-값 저장소"**: 메시징 단원 뒤, 동시성 단원 앞(100이 Redis 락 사용) | — | 1) redis-cli GET/SET/DEL / 2) TTL·EXPIRE / 3) 해시·리스트·셋 기본 / 4) INCR로 카운터 / 5) INFO·DBSIZE | 11 (터미널 8) |
| 필수 | C2. Redis 운영 기본: 메모리·지속성·레플리카 | 터미널 실습 | "캐시·키-값 저장소" | C1 | maxmemory·eviction 정책 / RDB·AOF 차이 / 복제 확인(INFO replication) / SLOWLOG·KEYS 대신 SCAN / 캐시 패턴(만료 동시 폭주) | 11 (터미널 6) |
| 필수 | C3. Redis 문제 해결 상황집: OOM, 느림, 복제 끊김 | 상황집 | "캐시·키-값 저장소" | C2 | OOM command not allowed / 느린 명령 SLOWLOG / 복제 끊김 / 영속화 실패(디스크) / 키 폭증·TTL 없는 키 | 10 (터미널 6) |
| 권장 | L1. 로그 수집 파이프라인 설정 읽고 고치기 | 터미널 실습 | 관측 단원, 90 뒤·74 앞 | 57, 90 | 수집 에이전트 구성(input/filter/output) / 파싱 실패 로그 / 레이블 부착 / 전송 지연·버퍼 / 중복·유실 판단 | 10 (터미널 5) |
| 권장 | G1. Grafana 대시보드 읽기와 쿼리 연결 | 터미널 실습 또는 개념 퀴즈 혼합 | 관측 단원, 103 뒤 | 90 | 데이터소스·패널과 PromQL 연결 / 변수 / rate 구간과 step / 임계 표시 / 빈 패널 원인(시간 범위·레이블) | 10 (터미널 3, 나머지 화면 읽기 퀴즈) |
| 권장 | P1. Prometheus exporter와 용량 기본 | 터미널 실습 | 관측 단원, 103 뒤 | 103 | node_exporter 주요 지표(CPU·메모리·디스크) / exporter 추가와 scrape / 블랙박스 프로브 개념 / 보존 기간·TSDB 디스크 / 카디널리티와 메모리 | 11 (터미널 6) |
| 권장 | J1. Jenkinsfile 작성·빌드 실패 디버깅 | 터미널 실습 | CI/CD·레지스트리 단원, 64 뒤·93 앞 | 64 | 간단 파이프라인 작성 / stage 실패 로그 읽기 / 환경변수·크리덴셜 주입 / 아티팩트 저장 / 병렬 stage | 11 (터미널 6) |
| 권장 | D1. 배포 전략과 롤백: 롤링·블루그린·카나리 | 개념 퀴즈 + 일부 터미널 | CI/CD 단원 또는 서비스 메시 단원 (92와 82 사이) | 82, 92 | 롤링 업데이트(maxSurge/maxUnavailable) / 블루그린 전환 / 카나리 가중치 / 롤백 절차 / 데이터 스키마 호환 | 11 (터미널 4) |
| 권장 | E1. Elasticsearch 스냅샷·인덱스 템플릿 실습 | 터미널 실습 | 검색·로그 저장 단원, 113 뒤 | 112, 71 | 스냅샷 저장소 등록 / 스냅샷 생성·목록 / 복원 / 인덱스 템플릿·alias / 보존·삭제 | 10 (터미널 6) |
| 권장 | K1. Kafka 상황집 실습 재현판 | 상황집 | 메시징 단원, 114 뒤(또는 114의 터미널 문제 보강) | 89, 114 | 114와 중복 없이 재현형: lag 증가를 직접 만들고 소비 시작 / 존재하지 않는 토픽 / advertised 주소 틀림 재현 / 오프셋 리셋 전후 비교 | 10 (터미널 7) |
| 선택 | S1. SLI·SLO와 알림 설계 | 개념 퀴즈 | 관측 단원, 104 뒤 | 103 | SLI/SLO 정의 / 에러 버짓 / 증상 기반 vs 원인 기반 알림 / 알림 피로 | 10 |
| 선택 | V1. Vault 실습과 k8s Secret 비교 | 터미널 실습 | 보안·시크릿 단원, 110 뒤 | 110 | vault kv put/get 직접 / 정책 적용·토큰 권한 / k8s Secret은 base64일 뿐 / 로테이션 | 11 (터미널 6) |
| 선택 | O1. 분산 추적 입문 | 개념 퀴즈 | 관측 단원, 57 뒤 | 57 | trace/span / 컨텍스트 전파 / 샘플링 / 로그와 연결 | 10 |

세트 수: 필수 10 + 권장 6 + 선택 3 = 19로 늘었다. "세트 수는 많지 않게" 기준으로 줄인 최소안:
- 필수 최소안(5개): N1+N2 통합→N1, N3, T1(T2 통합), R1(R2 통합), C1(C2·C3는 C2 하나로).
- 보고용 숫자는 이 최소안 기준(아래 최종 보고).

### 기존 세트 분할·재배치 제안(신규 제작 아님, 참고)
- 58(Kafka+RabbitMQ+CDC 8개 개념) → Kafka 핵심 / CDC 두 세트로 분할 (audit too_many_new).
- 62(ES 입문 7개 개념), 100(동시성 7개), 82(GitOps+IaC+k8s CI), 110(Vault 7개)도 분할 후보.
- 단원 순서: 70을 92 앞으로, 74를 관측 단원 끝으로, 73을 69 앞으로.

## 형식 균형

현재 집계: 37세트 중 터미널 포함 세트 17개, 퀴즈 전용(터미널 0) 세트 20개. (세트 기준: 터미널 0 = 57, 58, 62, 63, 64, 66, 67, 68, 69, 70, 71, 73, 74, 76, 82, 86, 101, 110, 111, 114).

| 영역 | 현재 | 문제점 | 권고 비율(터미널 : 퀴즈) |
|------|------|--------|---------------------------|
| 로드밸런서(HAProxy) | 51·72·84·98 터미널, 63·70 퀴즈 | 양호 | 유지 (60:40) |
| 관측 | 90·103·104 T, 57·74 Q | 양호 | 유지. 신규는 50:50 |
| 메시징(Kafka) | 89만 T, 58·66·67·68·86·114 Q | **실습 필요 영역인데 퀴즈 위주.** 114 상황집조차 터미널 0 | 신규·보강 세트는 60:40, 기존 상황집 114는 터미널 5문제 이상 추가 |
| RabbitMQ | 66 Q만 | 터미널 0 | 신규 R1·R2는 55:45 |
| Elasticsearch | 112·113 T, 62·71·76 Q | 개념 3세트 대비 실습 2세트. 71 ILM(8문제)도 Q | 신규 E1은 60:40 |
| CI/CD·레지스트리 | 93·116 T, 64·82 Q | 64·82(27문제)가 전부 객관식. 파이프라인 직접 작성 없음 | J1 신규 55:45 |
| 보안·시크릿 | 110·111 전부 Q(23문제) | 명령어 중심 도구인데 실습 0 | V1 또는 110을 50:50으로 전환 |
| 동시성 | 100·115 T, 101 Q | 양호 | 유지 |
| 사내 장애 사례 | 69·73 Q | 읽기 중심이라 성격상 허용 | 유지 |
| Nginx/TLS/Redis | 없음 | 신규 | 신규 세트 모두 55~70% 터미널 |

전체 권고: 신규 세트의 평균 터미널 비중 약 55~60%. 기존 퀴즈 전용 20개 중 114·110·66(·82)은 "실습 짝" 세트를 붙이는 방식으로 균형 조정.

## 상황집

현황(터미널 문제 수 / 전체):
- HAProxy 98: 5/12 — 충분.
- Prometheus 104: 5/12 — 충분.
- Elasticsearch 113: 5/13 — 충분(주제는 yellow/red, 워터마크 중심).
- 동시성 115: 3/11 — 보통.
- CI/CD·레지스트리 116: 3/12 — 보통.
- Kafka 114: 0/13 — **상황집이지만 퀴즈뿐.** 오류 메시지 읽기는 있으나 재현·해결 실습 없음.
- 없음: Nginx, TLS·인증서, RabbitMQ, Redis, Vault(unseal 실패·토큰 만료), 로그 수집, 서비스 메시(503 upstream connect error, 정책 충돌).

필요 시나리오(오류 메시지 → 원인 → 해결):
- **Nginx**: `502 Bad Gateway`(upstream 거부) → `504`(타임아웃) → `413 Request Entity Too Large` → `nginx: [emerg] bind() failed (Address already in use)` → `nginx -t` 문법 오류 → `Permission denied` 로그/소켓.
- **TLS**: `certificate has expired` → `unable to get local issuer certificate`(체인 누락) → `certificate is not valid for` (SAN 불일치) → `x509: certificate signed by unknown authority`.
- **RabbitMQ**: 큐 적체(ready 증가) → unacked 증가(ack 누락) → `connection_closed`/채널 폭증 → `disk free limit` 알람으로 publish 정지 → DLX 로 몰린 메시지.
- **Redis**: `OOM command not allowed when used memory > 'maxmemory'` → `MISCONF Redis is configured to save RDB snapshots` → 복제 `LOADING` / 끊김 → SLOWLOG에서 `KEYS *`.
- **Kafka**(114 보완): 접속 불가 재현, lag 증가 재현, 컨슈머 그룹 리셋.
- **Vault/서비스 메시**(선택): `Vault is sealed`, `permission denied`(정책), Istio `upstream connect error or disconnect/reset before headers`.

원칙: 신규 상황집 각 세트는 터미널 재현형 50% 이상, 문구는 일반화(제품 공통 오류 메시지 위주).
