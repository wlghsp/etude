-- 점검 지적 반영 (2026-11-19 전체 점검). 여러 번 실행해도 안전하다: REPLACE 는 옛 문장이 있을 때만 바꾼다.
-- 원본: 03_quest_set*.sql 도 같은 내용으로 고쳤다 (고치지 못한 행은 이 마이그레이션이 보정한다).

-- 세트 6 #3 hint: $NS 설명 추가
UPDATE quest SET hint = REPLACE(hint, '확인: `kubectl get pods -n <네임스페이스>`', '`$NS` 는 이 실습용 네임스페이스 이름이 미리 담긴 변수이므로 터미널에 `$NS` 그대로 입력하면 됩니다. 확인: `kubectl get pods -n <네임스페이스>`') WHERE quest_set_id = 6 AND order_index = 3 AND INSTR(hint, '확인: `kubectl get pods -n <네임스페이스>`') > 0;
-- 세트 17 #1 hint: heredoc 설명 추가
UPDATE quest SET hint = REPLACE(hint, '파일은 `cat > /tmp/hello.sh <<\'EOF\'` 와 `EOF` 사이에 내용을 적어서 만들거나 vim 으로 만듭니다.', '파일은 `cat > /tmp/hello.sh <<\'EOF\'` 와 `EOF` 사이에 내용을 적어서 만들거나 vim 으로 만듭니다. `<<\'EOF\'` 와 `EOF` 줄 사이에 적은 줄이 그대로 파일 내용이 되고, 작은따옴표는 `$` 같은 문자를 바꾸지 않고 그대로 넣는다는 뜻입니다.') WHERE quest_set_id = 17 AND order_index = 1 AND INSTR(hint, '파일은 `cat > /tmp/hello.sh <<\'EOF\'` 와 `EOF` 사이에 내용을 적어서 만들거나 vim 으로 만듭니다.') > 0;
-- 세트 26 #9 description: 채점이 command[2]=='sleep 5' 를 요구하므로 형태를 명시
UPDATE quest SET description = REPLACE(description, '- `preStop` 훅: `sleep 5` 실행', '- `preStop` 훅: `sh -c` 로 감싸서 `sleep 5` 실행 (`command: ["sh", "-c", "sleep 5"]` 형태)') WHERE quest_set_id = 26 AND order_index = 9 AND INSTR(description, '- `preStop` 훅: `sleep 5` 실행') > 0;
-- 세트 30 #4 description: 서술이 정답(640)을 노출
UPDATE quest SET description = REPLACE(description, '`/srv/report.csv` 는 소유자만 쓸 수 있고, 같은 그룹은 읽기만, 나머지는 접근하지 못해야 하는 파일입니다.', '`/srv/report.csv` 는 권한을 점검해야 하는 파일입니다.') WHERE quest_set_id = 30 AND order_index = 4 AND INSTR(description, '`/srv/report.csv` 는 소유자만 쓸 수 있고, 같은 그룹은 읽기만, 나머지는 접근하지 못해야 하는 파일입니다.') > 0;
-- 세트 30 #4 description: 예시가 정답과 동일
UPDATE quest SET description = REPLACE(description, '(예: `-rw-r-----`)', '(예: `-rwxr-xr-x`)') WHERE quest_set_id = 30 AND order_index = 4 AND INSTR(description, '(예: `-rw-r-----`)') > 0;
-- 세트 55 #7 choices: 현재 제품명 병기
UPDATE quest SET choices = REPLACE(choices, 'vCloud Director', 'VMware Cloud Director (옛 이름 vCloud Director)') WHERE quest_set_id = 55 AND order_index = 7 AND INSTR(choices, 'vCloud Director') > 0;
-- 세트 55 #7 explanation: 현재 제품명 병기
UPDATE quest SET explanation = REPLACE(explanation, '**vCloud Director ↔ OpenStack(RHOSP)**', '**VMware Cloud Director(옛 이름 vCloud Director) ↔ OpenStack(RHOSP)**') WHERE quest_set_id = 55 AND order_index = 7 AND INSTR(explanation, '**vCloud Director ↔ OpenStack(RHOSP)**') > 0;
-- 세트 55 #7 explanation: 현재 제품명
UPDATE quest SET explanation = REPLACE(explanation, '아니라 vCloud Director 입니다', '아니라 VMware Cloud Director 입니다') WHERE quest_set_id = 55 AND order_index = 7 AND INSTR(explanation, '아니라 vCloud Director 입니다') > 0;
-- 세트 56 #4 description: Git 기본값 simple 에서는 이름이 다르면 거절되므로 조건 명시
UPDATE quest SET description = REPLACE(description, '이름 없이 push 했더니', '이름 없이 push(push.default 가 upstream 이거나 IDE 의 Push 버튼을 쓴 경우) 했더니') WHERE quest_set_id = 56 AND order_index = 4 AND INSTR(description, '이름 없이 push 했더니') > 0;
-- 세트 56 #4 explanation: 기본 설정과의 차이 보충
UPDATE quest SET explanation = REPLACE(explanation, '이후 이름 없이 push(특히 IDE 의 Push 버튼)하면 upstream 으로, 즉 공유 브랜치로 올라갈 수 있습니다.', '이후 이름 없이 push(특히 IDE 의 Push 버튼)하면 upstream 으로, 즉 공유 브랜치로 올라갈 수 있습니다. (Git 기본값 `push.default=simple` 에서는 브랜치 이름이 다르면 거절되지만, 설정이 `upstream` 이거나 IDE 가 upstream 으로 직접 보내면 올라갑니다.)') WHERE quest_set_id = 56 AND order_index = 4 AND INSTR(explanation, '이후 이름 없이 push(특히 IDE 의 Push 버튼)하면 upstream 으로, 즉 공유 브랜치로 올라갈 수 있습니다.') > 0;
-- 세트 59 #11 description: MariaDB 에서 GTID 위치를 dump 에 남기려면 --gtid 필요(#12 와 일관)
UPDATE quest SET description = REPLACE(description, '`--single-transaction --master-data=2 --all-databases`', '`--single-transaction --master-data=2 --gtid --all-databases`') WHERE quest_set_id = 59 AND order_index = 11 AND INSTR(description, '`--single-transaction --master-data=2 --all-databases`') > 0;
-- 세트 59 #11 explanation: --gtid 역할 설명
UPDATE quest SET explanation = REPLACE(explanation, '`--master-data=2` 는 dump 파일에 binlog 위치(또는 GTID)를 주석으로 남겨,', '`--master-data=2` 는 dump 파일에 binlog 위치를 주석으로 남기고, MariaDB 에서는 `--gtid` 를 함께 주면 GTID 위치도 기록해 두어,') WHERE quest_set_id = 59 AND order_index = 11 AND INSTR(explanation, '`--master-data=2` 는 dump 파일에 binlog 위치(또는 GTID)를 주석으로 남겨,') > 0;
-- 세트 59 #13 explanation: 실제 mariadb-dump --gtid 동작에 맞춤
UPDATE quest SET explanation = REPLACE(explanation, '대신 dump 파일에 `gtid_binlog_pos` 가 주석으로 들어갑니다.', '대신 `--gtid` 옵션을 주고 dump 를 뜨면 dump 파일에 GTID 위치(`gtid_slave_pos` 설정문)가 들어갑니다.') WHERE quest_set_id = 59 AND order_index = 13 AND INSTR(explanation, '대신 dump 파일에 `gtid_binlog_pos` 가 주석으로 들어갑니다.') > 0;
-- 세트 61 #11 explanation: 현재 제품명 병기
UPDATE quest SET explanation = REPLACE(explanation, 'vCloud Director 가 VMware 쪽 대응입니다', 'VMware Cloud Director(옛 이름 vCloud Director)가 VMware 쪽 대응입니다') WHERE quest_set_id = 61 AND order_index = 11 AND INSTR(explanation, 'vCloud Director 가 VMware 쪽 대응입니다') > 0;
-- 세트 61 #12 description: 주관적 전제 제거, 규모·목적 차이로 학습 목표 명확화
UPDATE quest SET description = REPLACE(description, 'Proxmox VE 가 OpenStack 보다 더 안정적으로 **느껴지는** 이유로 알맞은 것은 무엇일까요?', 'Proxmox VE 와 OpenStack 의 구조가 이렇게 다른 **가장 큰 이유**로 알맞은 것은 무엇일까요?') WHERE quest_set_id = 61 AND order_index = 12 AND INSTR(description, 'Proxmox VE 가 OpenStack 보다 더 안정적으로 **느껴지는** 이유로 알맞은 것은 무엇일까요?') > 0;
-- 세트 67 #5 explanation: 특정 현장 구성을 암시하는 표현 일반화
UPDATE quest SET explanation = REPLACE(explanation, '사이트별 3대도 순차로', '3대 클러스터도 순차로') WHERE quest_set_id = 67 AND order_index = 5 AND INSTR(explanation, '사이트별 3대도 순차로') > 0;
-- 세트 67 #8 explanation: Kafka 보관 정책과 무관한 문장 교체
UPDATE quest SET explanation = REPLACE(explanation, '로그가 뜸한 appender 는 수동 정리가 필요할 수 있습니다.', '보관 기간이 지나도 현재 쓰는 활성 세그먼트는 바로 지워지지 않을 수 있습니다.') WHERE quest_set_id = 67 AND order_index = 8 AND INSTR(explanation, '로그가 뜸한 appender 는 수동 정리가 필요할 수 있습니다.') > 0;
-- 세트 68 #2 explanation: 특정 팀 결정 회고체 일반화
UPDATE quest SET explanation = REPLACE(explanation, '공식 지원되지 않아 쓸 수 없었고, 세션 단위로 binlog 를 끄는 `sql_log_bin=0` 을 채택했습니다.', '공식 지원되지 않으므로, 세션 단위로 binlog 를 끄는 `sql_log_bin=0` 방식을 씁니다.') WHERE quest_set_id = 68 AND order_index = 2 AND INSTR(explanation, '공식 지원되지 않아 쓸 수 없었고, 세션 단위로 binlog 를 끄는 `sql_log_bin=0` 을 채택했습니다.') > 0;
-- 세트 69 #4 choices: ingress 정책에서 맞는 말이 되던 보기를 명백한 오답으로
UPDATE quest SET choices = REPLACE(choices, 'Ingress 만 막히고 Egress 는 영향이 없다', 'Ingress 는 영향이 없고 Egress 만 막힌다') WHERE quest_set_id = 69 AND order_index = 4 AND INSTR(choices, 'Ingress 만 막히고 Egress 는 영향이 없다') > 0;
-- 세트 69 #4 description: policyTypes 방향 명시
UPDATE quest SET description = REPLACE(description, '특정 포트(예: 8080)만 허용하는 NetworkPolicy', '특정 포트(예: 8080)로 들어오는 **ingress** 만 허용하는 NetworkPolicy') WHERE quest_set_id = 69 AND order_index = 4 AND INSTR(description, '특정 포트(예: 8080)만 허용하는 NetworkPolicy') > 0;
-- 세트 69 #9 explanation: 응답 출발 IP 는 그대로이므로 부정확한 서술 수정
UPDATE quest SET explanation = REPLACE(explanation, 'SYN-ACK 의 출발 IP 가 달라져 연결이 성립하지 않습니다.', '응답이 중간 장비나 `rp_filter` 등에서 버려져 연결이 성립하지 않습니다.') WHERE quest_set_id = 69 AND order_index = 9 AND INSTR(explanation, 'SYN-ACK 의 출발 IP 가 달라져 연결이 성립하지 않습니다.') > 0;
-- 세트 72 #3 hint: check 설명 추가
UPDATE quest SET hint = REPLACE(hint, '`server 이름 주소:포트 check`', '`server 이름 주소:포트 check` (`check` 는 서버가 살아 있는지 주기적으로 확인하는 옵션)') WHERE quest_set_id = 72 AND order_index = 3 AND INSTR(hint, '`server 이름 주소:포트 check`') > 0;
-- 세트 72 #3 hint: -D 설명 추가
UPDATE quest SET hint = REPLACE(hint, '로 실행합니다.', '로 실행합니다(`-D` 는 백그라운드 실행).') WHERE quest_set_id = 72 AND order_index = 3 AND INSTR(hint, '로 실행합니다.') > 0;
-- 세트 73 #8 choices: min.insync 미달은 쓰기만 거부, 읽기 불가는 Leader 없는 파티션
UPDATE quest SET choices = REPLACE(choices, '프로듀서가 쓰지 못하고, consumer 는 읽지 못해 lag 이 늘어난다', '`acks=all` 프로듀서의 쓰기가 거부되고, Leader 가 사라진 파티션은 읽기·쓰기가 모두 멈춘다') WHERE quest_set_id = 73 AND order_index = 8 AND INSTR(choices, '프로듀서가 쓰지 못하고, consumer 는 읽지 못해 lag 이 늘어난다') > 0;
-- 세트 74 #11 description: 순서 근거 명시
UPDATE quest SET description = REPLACE(description, '**가까운 곳에서 먼 곳** 순서로 진단 순서를 놓으세요.', '**Prometheus 서버 쪽에서 대상 쪽으로 범위를 좁혀 가는 순서**로 진단 순서를 놓으세요. 마지막에 Prometheus 화면의 오류 메시지로 확인합니다.') WHERE quest_set_id = 74 AND order_index = 11 AND INSTR(description, '**가까운 곳에서 먼 곳** 순서로 진단 순서를 놓으세요.') > 0;
-- 세트 77 #10 description: 채점이 요구하는 형식 명시
UPDATE quest SET description = REPLACE(description, '(파일 이름만 한 줄에 하나씩)', '(`/proc/self/ns` 아래 항목 이름만 한 줄에 하나씩, 예: `pid`, `net` …)') WHERE quest_set_id = 77 AND order_index = 10 AND INSTR(description, '(파일 이름만 한 줄에 하나씩)') > 0;
-- 세트 79 #12 choices: 명백한 오답으로
UPDATE quest SET choices = REPLACE(choices, '정책이 없는 방향은 항상 자동 허용된다', 'ingress 도 정책과 상관없이 자동으로 모두 허용된다') WHERE quest_set_id = 79 AND order_index = 12 AND INSTR(choices, '정책이 없는 방향은 항상 자동 허용된다') > 0;
-- 세트 79 #12 choices: 질문과 일치
UPDATE quest SET choices = REPLACE(choices, '정책이 선택한 Pod 의 해당 방향에서는', '정책이 선택한 Pod 의 ingress 방향에서는') WHERE quest_set_id = 79 AND order_index = 12 AND INSTR(choices, '정책이 선택한 Pod 의 해당 방향에서는') > 0;
-- 세트 79 #12 description: 질문 한정
UPDATE quest SET description = REPLACE(description, '그 정책이 허용하지 않은 방향의 트래픽은 어떻게 될까요?', '이 Pod 로 **들어오는(ingress)** 트래픽 중 정책이 허용하지 않은 것은 어떻게 될까요?') WHERE quest_set_id = 79 AND order_index = 12 AND INSTR(description, '그 정책이 허용하지 않은 방향의 트래픽은 어떻게 될까요?') > 0;
-- 세트 81 #6 choices: 버전 조건
UPDATE quest SET choices = REPLACE(choices, 'Alpine 의 musl libc 는 응답이 잘렸을 때', '오래된 Alpine 의 musl libc 는 응답이 잘렸을 때') WHERE quest_set_id = 81 AND order_index = 6 AND INSTR(choices, 'Alpine 의 musl libc 는 응답이 잘렸을 때') > 0;
-- 세트 81 #6 description: musl 1.2.4 부터 TCP 폴백 지원, 버전 조건 명시
UPDATE quest SET description = REPLACE(description, 'Alpine Linux 컨테이너에서만', '오래된 Alpine Linux 컨테이너(musl libc 1.2.3 이하)에서만') WHERE quest_set_id = 81 AND order_index = 6 AND INSTR(description, 'Alpine Linux 컨테이너에서만') > 0;
-- 세트 83 #5 description: 제작 메모 제거
UPDATE quest SET description = REPLACE(description, ' (※ 이 항목은 노트에 없는 일반 Redis 지식)', '') WHERE quest_set_id = 83 AND order_index = 5 AND INSTR(description, ' (※ 이 항목은 노트에 없는 일반 Redis 지식)') > 0;
-- 세트 83 #7 description: 제작 메모 제거
UPDATE quest SET description = REPLACE(description, ' (※ 일반 Redis 지식)', '') WHERE quest_set_id = 83 AND order_index = 7 AND INSTR(description, ' (※ 일반 Redis 지식)') > 0;
-- 세트 83 #8 description: 제작 메모 제거
UPDATE quest SET description = REPLACE(description, ' (※ 일반 Redis 지식)', '') WHERE quest_set_id = 83 AND order_index = 8 AND INSTR(description, ' (※ 일반 Redis 지식)') > 0;
-- 세트 84 #1 description: 용어 풀이
UPDATE quest SET description = REPLACE(description, '가장 가능성 높은 원인은 무엇일까요?', '가장 가능성 높은 원인은 무엇일까요? (Tq 요청 수신, Tw 큐 대기, Tc 서버 연결, Tr 서버 응답, Tt 전체 시간입니다. `maxconn` 은 서버가 동시에 받는 연결 수 상한입니다.)') WHERE quest_set_id = 84 AND order_index = 1 AND INSTR(description, '가장 가능성 높은 원인은 무엇일까요?') > 0;
-- 세트 84 #10 description: 채점 전제 명시
UPDATE quest SET description = REPLACE(description, '(앞 3번은 200, 뒤 3번은 429 여야 합니다)', '(앞 3번은 200, 뒤 3번은 429 여야 합니다. 설정 후 다른 요청을 보내지 말고 바로 6번 요청하세요. 10초가 지나면 카운트가 초기화됩니다.)') WHERE quest_set_id = 84 AND order_index = 10 AND INSTR(description, '(앞 3번은 200, 뒤 3번은 429 여야 합니다)') > 0;
-- 세트 88 #11 hint: 리터럴 \n 을 실제 줄바꿈으로
UPDATE quest SET hint = REPLACE(hint, '\\n확인', '\n확인') WHERE quest_set_id = 88 AND order_index = 11 AND INSTR(hint, '\\n확인') > 0;
-- 세트 89 #7 hint: 리터럴 \n 을 실제 줄바꿈으로
UPDATE quest SET hint = REPLACE(hint, '\\n확인', '\n확인') WHERE quest_set_id = 89 AND order_index = 7 AND INSTR(hint, '\\n확인') > 0;
-- 세트 89 #9 hint: 리터럴 \n 을 실제 줄바꿈으로
UPDATE quest SET hint = REPLACE(hint, '\\n확인', '\n확인') WHERE quest_set_id = 89 AND order_index = 9 AND INSTR(hint, '\\n확인') > 0;
-- 세트 90 #1 description: 제작 메모 제거
UPDATE quest SET description = REPLACE(description, ' (※ PromQL 문법은 노트에 없는 일반 지식)', '') WHERE quest_set_id = 90 AND order_index = 1 AND INSTR(description, ' (※ PromQL 문법은 노트에 없는 일반 지식)') > 0;
-- 세트 90 #3 description: 제작 메모 제거
UPDATE quest SET description = REPLACE(description, ' (※ LogQL 문법은 노트에 없는 일반 지식)', '') WHERE quest_set_id = 90 AND order_index = 3 AND INSTR(description, ' (※ LogQL 문법은 노트에 없는 일반 지식)') > 0;
-- 세트 90 #5 description: 제작 메모 제거
UPDATE quest SET description = REPLACE(description, ' (※ 일반 지식)', '') WHERE quest_set_id = 90 AND order_index = 5 AND INSTR(description, ' (※ 일반 지식)') > 0;
-- 세트 90 #7 hint: 리터럴 \n 을 실제 줄바꿈으로
UPDATE quest SET hint = REPLACE(hint, '\\n확인', '\n확인') WHERE quest_set_id = 90 AND order_index = 7 AND INSTR(hint, '\\n확인') > 0;
-- 세트 90 #8 hint: 리터럴 \n 을 실제 줄바꿈으로
UPDATE quest SET hint = REPLACE(hint, '\\n확인', '\n확인') WHERE quest_set_id = 90 AND order_index = 8 AND INSTR(hint, '\\n확인') > 0;
-- 세트 90 #9 hint: 리터럴 \n 을 실제 줄바꿈으로
UPDATE quest SET hint = REPLACE(hint, '\\n확인', '\n확인') WHERE quest_set_id = 90 AND order_index = 9 AND INSTR(hint, '\\n확인') > 0;
-- 세트 91 #7 hint: 리터럴 \n 을 실제 줄바꿈으로
UPDATE quest SET hint = REPLACE(hint, '\\n확인', '\n확인') WHERE quest_set_id = 91 AND order_index = 7 AND INSTR(hint, '\\n확인') > 0;
-- 세트 91 #8 hint: 리터럴 \n 을 실제 줄바꿈으로
UPDATE quest SET hint = REPLACE(hint, '\\n확인', '\n확인') WHERE quest_set_id = 91 AND order_index = 8 AND INSTR(hint, '\\n확인') > 0;
-- 세트 91 #9 hint: 리터럴 \n 을 실제 줄바꿈으로
UPDATE quest SET hint = REPLACE(hint, '\\n확인', '\n확인') WHERE quest_set_id = 91 AND order_index = 9 AND INSTR(hint, '\\n확인') > 0;
-- 세트 92 #9 hint: 리터럴 \n 을 실제 줄바꿈으로
UPDATE quest SET hint = REPLACE(hint, '\\n확인', '\n확인') WHERE quest_set_id = 92 AND order_index = 9 AND INSTR(hint, '\\n확인') > 0;
-- 세트 93 #8 hint: 리터럴 \n 을 실제 줄바꿈으로
UPDATE quest SET hint = REPLACE(hint, '\\n확인', '\n확인') WHERE quest_set_id = 93 AND order_index = 8 AND INSTR(hint, '\\n확인') > 0;
-- 세트 94 #8 hint: 리터럴 \n 을 실제 줄바꿈으로
UPDATE quest SET hint = REPLACE(hint, '\\n확인', '\n확인') WHERE quest_set_id = 94 AND order_index = 8 AND INSTR(hint, '\\n확인') > 0;
-- 세트 95 #9 hint: 리터럴 \n 을 실제 줄바꿈으로
UPDATE quest SET hint = REPLACE(hint, '\\n확인', '\n확인') WHERE quest_set_id = 95 AND order_index = 9 AND INSTR(hint, '\\n확인') > 0;
-- 세트 95 #10 hint: 리터럴 \n 을 실제 줄바꿈으로
UPDATE quest SET hint = REPLACE(hint, '\\n확인', '\n확인') WHERE quest_set_id = 95 AND order_index = 10 AND INSTR(hint, '\\n확인') > 0;
-- 세트 95 #11 hint: 리터럴 \n 을 실제 줄바꿈으로
UPDATE quest SET hint = REPLACE(hint, '\\n확인', '\n확인') WHERE quest_set_id = 95 AND order_index = 11 AND INSTR(hint, '\\n확인') > 0;
-- 세트 95 #13 hint: 리터럴 \n 을 실제 줄바꿈으로
UPDATE quest SET hint = REPLACE(hint, '\\n확인', '\n확인') WHERE quest_set_id = 95 AND order_index = 13 AND INSTR(hint, '\\n확인') > 0;
-- 세트 95 #14 hint: 리터럴 \n 을 실제 줄바꿈으로
UPDATE quest SET hint = REPLACE(hint, '\\n확인', '\n확인') WHERE quest_set_id = 95 AND order_index = 14 AND INSTR(hint, '\\n확인') > 0;
-- 세트 96 #9 hint: 리터럴 \n 을 실제 줄바꿈으로
UPDATE quest SET hint = REPLACE(hint, '\\n확인', '\n확인') WHERE quest_set_id = 96 AND order_index = 9 AND INSTR(hint, '\\n확인') > 0;
-- 세트 96 #10 hint: 리터럴 \n 을 실제 줄바꿈으로
UPDATE quest SET hint = REPLACE(hint, '\\n확인', '\n확인') WHERE quest_set_id = 96 AND order_index = 10 AND INSTR(hint, '\\n확인') > 0;
-- 세트 96 #11 hint: 리터럴 \n 을 실제 줄바꿈으로
UPDATE quest SET hint = REPLACE(hint, '\\n확인', '\n확인') WHERE quest_set_id = 96 AND order_index = 11 AND INSTR(hint, '\\n확인') > 0;
-- 세트 96 #12 hint: 리터럴 \n 을 실제 줄바꿈으로
UPDATE quest SET hint = REPLACE(hint, '\\n확인', '\n확인') WHERE quest_set_id = 96 AND order_index = 12 AND INSTR(hint, '\\n확인') > 0;
-- 세트 104 #8 description: 채점이 localhost:9100 문자열만 인정하므로 조건 명시
UPDATE quest SET description = REPLACE(description, '올바르게 고치세요.', '올바르게 고치세요. 주소는 `localhost` 그대로 두고 포트만 바꾸면 됩니다.') WHERE quest_set_id = 104 AND order_index = 8 AND INSTR(description, '올바르게 고치세요.') > 0;
-- 세트 104 #8 hint: 힌트에 리터럴 \n 노출 제거
UPDATE quest SET hint = REPLACE(hint, '맞추세요.\\n확인:', '맞추세요.\n확인:') WHERE quest_set_id = 104 AND order_index = 8 AND INSTR(hint, '맞추세요.\\n확인:') > 0;
-- 세트 111 #6 explanation: cron % 이스케이프 안내 추가
UPDATE quest SET explanation = REPLACE(explanation, '덮어쓰지 않아요.', '덮어쓰지 않아요. 단, crontab 안에서는 `%` 가 줄바꿈 뜻이라 `\\%F` 처럼 앞에 `\\` 를 붙여야 합니다.') WHERE quest_set_id = 111 AND order_index = 6 AND INSTR(explanation, '덮어쓰지 않아요.') > 0;
-- 세트 111 #6 template: crontab 에서 % 는 줄바꿈으로 해석되어 \% 로 이스케이프해야 함
UPDATE quest SET template = REPLACE(template, 'vault-$(date +%F).snap', 'vault-$(date +\\%F).snap') WHERE quest_set_id = 111 AND order_index = 6 AND INSTR(template, 'vault-$(date +%F).snap') > 0;
-- 세트 112 #4 explanation: 내부 세트 번호 참조 제거
UPDATE quest SET explanation = REPLACE(explanation, '(62번 세트의 refresh 를 떠올려 보세요)', '(`refresh` 는 색인한 문서가 검색에 보이도록 반영하는 단계입니다)') WHERE quest_set_id = 112 AND order_index = 4 AND INSTR(explanation, '(62번 세트의 refresh 를 떠올려 보세요)') > 0;
-- 세트 115 #7 description: 숨은 상태(호출 횟수 누적) 안내
UPDATE quest SET description = REPLACE(description, '`success` 를 쓰세요.', '`success` 를 쓰세요. (`flaky.sh` 는 호출할 때마다 횟수가 쌓이니 반복문 밖에서 미리 실행하지 마세요. 꼬였으면 `rm -f /tmp/n` 으로 횟수를 지우세요.)') WHERE quest_set_id = 115 AND order_index = 7 AND INSTR(description, '`success` 를 쓰세요.') > 0;
-- 세트 120 #6 explanation: 공식 문서 순서와의 차이를 설명에 명시
UPDATE quest SET explanation = REPLACE(explanation, '노드를 비운 상태에서 올리면 서비스 중단을 줄일 수 있습니다.', 'kubelet 을 올리기 전에 노드를 비워 두면 서비스 중단을 줄일 수 있습니다. (공식 문서는 kubeadm 패키지 업그레이드와 `kubeadm upgrade node` 를 drain 앞에 두기도 하니, 핵심은 drain 이 kubelet 업그레이드보다 먼저라는 점입니다.)') WHERE quest_set_id = 120 AND order_index = 6 AND INSTR(explanation, '노드를 비운 상태에서 올리면 서비스 중단을 줄일 수 있습니다.') > 0;
-- 세트 123 #7 choices: 실행 권한 전에도 가능한 방식임을 명시해 순서 모순 해소
UPDATE quest SET choices = REPLACE(choices, '스크립트를 절대 경로로 손으로 실행해 동작을 확인한다', '스크립트를 `sh /절대경로/스크립트` 로 손으로 실행해 동작을 확인한다') WHERE quest_set_id = 123 AND order_index = 7 AND INSTR(choices, '스크립트를 절대 경로로 손으로 실행해 동작을 확인한다') > 0;
-- 세트 141 #9 choices: MariaDB/MySQL 실제 오류 문구(ERROR 1052)
UPDATE quest SET choices = REPLACE(choices, 'Column \'id\' in SELECT is ambiguous', 'Column \'id\' in field list is ambiguous') WHERE quest_set_id = 141 AND order_index = 9 AND INSTR(choices, 'Column \'id\' in SELECT is ambiguous') > 0;
-- 세트 154 #10 explanation: 버전별로 달라지는 부정확한 수치 제거
UPDATE quest SET explanation = REPLACE(explanation, '알파인 기본 크기(약 4MB)', '알파인 기본 크기(수 MB)') WHERE quest_set_id = 154 AND order_index = 10 AND INSTR(explanation, '알파인 기본 크기(약 4MB)') > 0;
-- 세트 157 #12 explanation: 문제에 없는 '이 노드' 지시어 제거
UPDATE quest SET explanation = REPLACE(explanation, '이 노드처럼 예약이 없으면 두 값이 같을 수도 있어요.', '시스템용 예약이 없는 노드(예: 작은 실습 클러스터)에서는 두 값이 같을 수도 있어요.') WHERE quest_set_id = 157 AND order_index = 12 AND INSTR(explanation, '이 노드처럼 예약이 없으면 두 값이 같을 수도 있어요.') > 0;
-- 세트 160 #9 choices: 환경마다 달라지는 구체 숫자 제거
UPDATE quest SET choices = REPLACE(choices, '(예: `/dev` 항목이 15개에서 191개로 늘어난다)', '(예: `/dev` 항목이 크게 늘어난다)') WHERE quest_set_id = 160 AND order_index = 9 AND INSTR(choices, '(예: `/dev` 항목이 15개에서 191개로 늘어난다)') > 0;
-- 세트 165 #4 explanation: 제작 검증 기록 제거
UPDATE quest SET explanation = REPLACE(explanation, '실제 실행으로 "일만 맞음", "요일만 맞음" 줄이 모두 실행되는 것을 확인했어요.', '일이나 요일 중 하나만 맞아도 실행돼요.') WHERE quest_set_id = 165 AND order_index = 4 AND INSTR(explanation, '실제 실행으로 "일만 맞음", "요일만 맞음" 줄이 모두 실행되는 것을 확인했어요.') > 0;
-- 세트 165 #5 explanation: 제작 검증 기록 제거
UPDATE quest SET explanation = REPLACE(explanation, '실제로 cron 안에서 `PATH=/usr/bin:/bin` 이 출력되는 것을 확인했습니다.', 'cron 의 기본 `PATH` 는 보통 `/usr/bin:/bin` 정도로 짧습니다.') WHERE quest_set_id = 165 AND order_index = 5 AND INSTR(explanation, '실제로 cron 안에서 `PATH=/usr/bin:/bin` 이 출력되는 것을 확인했습니다.') > 0;
-- 세트 165 #7 explanation: 제작 검증 기록 제거
UPDATE quest SET explanation = REPLACE(explanation, '실제로 이스케이프하지 않은 줄은 출력 파일이 아예 만들어지지 않았고, `\\%Y` 는 `2026` 이 기록됐습니다.', '이스케이프하지 않으면 `%` 뒤가 표준 입력으로 넘어가 출력 파일이 만들어지지 않고, `\\%Y` 로 쓰면 `2026` 같은 연도가 기록됩니다.') WHERE quest_set_id = 165 AND order_index = 7 AND INSTR(explanation, '실제로 이스케이프하지 않은 줄은 출력 파일이 아예 만들어지지 않았고, `\\%Y` 는 `2026` 이 기록됐습니다.') > 0;
-- 세트 165 #11 explanation: 제작 검증 기록 제거
UPDATE quest SET explanation = REPLACE(explanation, '실제로 2026-03-01 과 2026-02-01 의 차이는 28일이에요.', '예를 들어 2026-03-01 과 2026-02-01 의 차이는 28일이에요.') WHERE quest_set_id = 165 AND order_index = 11 AND INSTR(explanation, '실제로 2026-03-01 과 2026-02-01 의 차이는 28일이에요.') > 0;
-- 세트 173 #8 explanation: 특정 환경 결과를 일반화
UPDATE quest SET explanation = REPLACE(explanation, '이 컨테이너에서는 root 의 `nice -n -5` 도 거부되었습니다. 환경에 따라 권한(capability)이 다를 수 있어요.', 'root 라도 환경(capability)에 따라 `nice -n -5` 가 거부될 수 있어요.') WHERE quest_set_id = 173 AND order_index = 8 AND INSTR(explanation, '이 컨테이너에서는 root 의 `nice -n -5` 도 거부되었습니다. 환경에 따라 권한(capability)이 다를 수 있어요.') > 0;
-- 세트 180 #5 choices: 경로 모순 해소, 설정은 각자 해야 함을 명시
UPDATE quest SET choices = REPLACE(choices, '지정한 폴더(`../hooks-shared`)에서 훅을 찾는다. `.git` 안은 커밋되지 않지만 이 폴더를 저장소에 포함해 두면 팀 모두가 같은 훅을 쓸 수 있다', '지정한 폴더(`.githooks`)에서 훅을 찾는다. `.git` 안은 커밋되지 않지만 저장소 안의 `.githooks` 폴더에 훅을 커밋해 두고 팀원이 각자 이 설정을 한 번 해 주면 같은 훅을 쓸 수 있다') WHERE quest_set_id = 180 AND order_index = 5 AND INSTR(choices, '지정한 폴더(`../hooks-shared`)에서 훅을 찾는다. `.git` 안은 커밋되지 않지만 이 폴더를 저장소에 포함해 두면 팀 모두가 같은 훅을 쓸 수 있다') > 0;
-- 세트 180 #5 description: 저장소 밖을 가리키는 예시 수정
UPDATE quest SET description = REPLACE(description, '`git config core.hooksPath ../hooks-shared`', '`git config core.hooksPath .githooks`') WHERE quest_set_id = 180 AND order_index = 5 AND INSTR(description, '`git config core.hooksPath ../hooks-shared`') > 0;
-- 세트 181 #13 choices: cmp 출력 문구가 버전별로 다름
UPDATE quest SET choices = REPLACE(choices, '처음으로 다른 바이트의 위치(`char 3, line 2`)만', '처음으로 다른 바이트의 위치(몇 번째 바이트, 몇 번째 줄)만') WHERE quest_set_id = 181 AND order_index = 13 AND INSTR(choices, '처음으로 다른 바이트의 위치(`char 3, line 2`)만') > 0;
-- 세트 186 #12 explanation: 제작 메모 제거
UPDATE quest SET explanation = REPLACE(explanation, '(여기서는 클러스터 안의 이름으로 확인했습니다)', '') WHERE quest_set_id = 186 AND order_index = 12 AND INSTR(explanation, '(여기서는 클러스터 안의 이름으로 확인했습니다)') > 0;
-- 세트 186 #14 explanation: 제작 메모 제거
UPDATE quest SET explanation = REPLACE(explanation, '(여기서는 오류 문구만 확인했습니다)', '') WHERE quest_set_id = 186 AND order_index = 14 AND INSTR(explanation, '(여기서는 오류 문구만 확인했습니다)') > 0;
-- 세트 187 #11 choices: 환경 의존 관찰 제거
UPDATE quest SET choices = REPLACE(choices, ', 이 환경에서는 `VOLUME` 뒤에 `RUN` 으로 쓴 `after.txt` 도 이미지에 남아 `before.txt` 와 함께 보였다', '') WHERE quest_set_id = 187 AND order_index = 11 AND INSTR(choices, ', 이 환경에서는 `VOLUME` 뒤에 `RUN` 으로 쓴 `after.txt` 도 이미지에 남아 `before.txt` 와 함께 보였다') > 0;
-- 세트 187 #11 description: 환경 의존 관찰 제거
UPDATE quest SET description = REPLACE(description, ' 이 환경(BuildKit)에서 `VOLUME` 뒤의 `RUN echo after > /data/after.txt` 는 어떻게 되었을까요?', '') WHERE quest_set_id = 187 AND order_index = 11 AND INSTR(description, ' 이 환경(BuildKit)에서 `VOLUME` 뒤의 `RUN echo after > /data/after.txt` 는 어떻게 되었을까요?') > 0;
-- 세트 187 #11 explanation: 환경 의존 설명을 일반 지침으로
UPDATE quest SET explanation = REPLACE(explanation, '이 환경의 관찰 결과이므로 `VOLUME` 뒤의 변경 처리는 빌더에 따라 다를 수 있습니다.', '`VOLUME` 선언 뒤에 그 경로의 파일을 바꾸면 빌더에 따라 유지되지 않을 수 있으니, 변경은 `VOLUME` 앞에서 하세요.') WHERE quest_set_id = 187 AND order_index = 11 AND INSTR(explanation, '이 환경의 관찰 결과이므로 `VOLUME` 뒤의 변경 처리는 빌더에 따라 다를 수 있습니다.') > 0;
-- 세트 187 #14 choices: COPY 권한은 원본을 따름
UPDATE quest SET choices = REPLACE(choices, '기본은 소유자 `0:0`(root)에 권한 644 이고,', '기본은 소유자 `0:0`(root)에 권한은 원본 파일의 권한을 따르고(여기서는 644),') WHERE quest_set_id = 187 AND order_index = 14 AND INSTR(choices, '기본은 소유자 `0:0`(root)에 권한 644 이고,') > 0;
-- 세트 187 #14 hint: COPY 권한은 원본을 따름
UPDATE quest SET hint = REPLACE(hint, '기본은 root 소유 644 예요.', '기본 소유자는 root 예요.') WHERE quest_set_id = 187 AND order_index = 14 AND INSTR(hint, '기본은 root 소유 644 예요.') > 0;
-- 세트 194 #12 explanation: finalizer 가 남으면 delete 가 대기하는 점 안내
UPDATE quest SET explanation = REPLACE(explanation, '원인을 먼저 확인합니다.', '원인을 먼저 확인합니다. 또한 `kubectl delete` 는 삭제가 끝날 때까지 기다리므로 멈춘 것처럼 보이면 `Ctrl+C` 로 빠져나오거나 `--wait=false` 를 붙입니다.') WHERE quest_set_id = 194 AND order_index = 12 AND INSTR(explanation, '원인을 먼저 확인합니다.') > 0;
-- 세트 197 #4 description: OPTIND 정의가 없어 4 를 계산할 근거 부족
UPDATE quest SET description = REPLACE(description, '루프가 끝난 뒤 `OPTIND` 는 무엇일까요?', '루프가 끝난 뒤 `OPTIND` 는 무엇일까요? (`OPTIND` 는 다음에 읽을 인자 번호이며 처음에는 1 입니다.)') WHERE quest_set_id = 197 AND order_index = 4 AND INSTR(description, '루프가 끝난 뒤 `OPTIND` 는 무엇일까요?') > 0;
-- 세트 198 #13 description: 버전 조건과 사이드카 개념 명시
UPDATE quest SET description = REPLACE(description, 'Pod 가 시작되면 어떻게 보일까요?', 'Pod 가 시작되면 어떻게 보일까요? (쿠버네티스 1.29 이상 기준이며, `restartPolicy: Always` 인 init 컨테이너는 앱과 함께 계속 실행되는 사이드카입니다.)') WHERE quest_set_id = 198 AND order_index = 13 AND INSTR(description, 'Pod 가 시작되면 어떻게 보일까요?') > 0;
-- 세트 199 #8 choices: status 필터는 -a 없이도 종료 컨테이너를 보여 주므로 틀린 문장 삭제
UPDATE quest SET choices = REPLACE(choices, '. `-a` 가 없으면 종료된 컨테이너는 목록에 나오지 않는다', '') WHERE quest_set_id = 199 AND order_index = 8 AND INSTR(choices, '. `-a` 가 없으면 종료된 컨테이너는 목록에 나오지 않는다') > 0;
-- 세트 201 #6 choices: x, y 미설정 전제 명시
UPDATE quest SET choices = REPLACE(choices, '`declare -A` 없이 쓰면 일반 배열이라', '`declare -A` 없이 쓰면(`x`, `y` 라는 변수가 없을 때) 일반 배열이라') WHERE quest_set_id = 201 AND order_index = 6 AND INSTR(choices, '`declare -A` 없이 쓰면 일반 배열이라') > 0;
-- 세트 201 #14 description: da 정의가 문제에 없음
UPDATE quest SET description = REPLACE(description, '`declare -p da` 는 무엇을 보여 줄까요?', '`da=(a b)` 로 만든 배열에 `declare -p da` 는 무엇을 보여 줄까요?') WHERE quest_set_id = 201 AND order_index = 14 AND INSTR(description, '`declare -p da` 는 무엇을 보여 줄까요?') > 0;
-- 세트 202 #1 choices: 오류 메시지가 파일 내용에 따라 달라 특정 문구 제거
UPDATE quest SET choices = REPLACE(choices, '`kustomization.yaml` 은 `apiVersion not set, kind not set` 검증 오류가 나고', '`kustomization.yaml` 은 일반 리소스로 변환되지 않아 오류가 나고') WHERE quest_set_id = 202 AND order_index = 1 AND INSTR(choices, '`kustomization.yaml` 은 `apiVersion not set, kind not set` 검증 오류가 나고') > 0;
-- 세트 208 #9 choices: 출제자 내부 표현 제거, 실제 동기화 주기 설명
UPDATE quest SET choices = REPLACE(choices, '시간이 조금 지난 뒤(우리 시험에서는 약 1분 반 안) `v1-NEW` 로 바뀐다', 'kubelet 이 주기적으로 동기화하므로 잠시(보통 1분 안팎) 뒤에 `v1-NEW` 로 바뀐다') WHERE quest_set_id = 208 AND order_index = 9 AND INSTR(choices, '시간이 조금 지난 뒤(우리 시험에서는 약 1분 반 안) `v1-NEW` 로 바뀐다') > 0;
-- 세트 208 #13 choices: 환경 의존 표현을 조건 표현으로
UPDATE quest SET choices = REPLACE(choices, '이 클러스터에서는 PVC 가 처음에 `Pending`', '`WaitForFirstConsumer` 인 StorageClass 에서는 PVC 가 처음에 `Pending`') WHERE quest_set_id = 208 AND order_index = 13 AND INSTR(choices, '이 클러스터에서는 PVC 가 처음에 `Pending`') > 0;
-- 세트 208 #13 description: 환경 의존 조건을 문제에 명시
UPDATE quest SET description = REPLACE(description, '`storage: 50Mi` 의 PVC 를 만들면', '`WaitForFirstConsumer` 인 StorageClass 로 `storage: 50Mi` 의 PVC 를 만들면') WHERE quest_set_id = 208 AND order_index = 13 AND INSTR(description, '`storage: 50Mi` 의 PVC 를 만들면') > 0;
-- 세트 210 #6 choices: 최신 GNU diffutils 는 byte 로 출력
UPDATE quest SET choices = REPLACE(choices, '`a1 a3 differ: char 5, line 1` 처럼 처음', '`a1 a3 differ: byte 5, line 1` 처럼(옛 버전은 `char`) 처음') WHERE quest_set_id = 210 AND order_index = 6 AND INSTR(choices, '`a1 a3 differ: char 5, line 1` 처럼 처음') > 0;
-- 세트 221 #14 choices: 이미지(busybox/coreutils)별 오류 문구 차이 제거
UPDATE quest SET choices = REPLACE(choices, '`invalid number` 오류와 함께', '`sleep` 이 `echo` 를 숫자로 읽지 못해 오류와 함께') WHERE quest_set_id = 221 AND order_index = 14 AND INSTR(choices, '`invalid number` 오류와 함께') > 0;
-- 세트 223 #5 description: 시점 조건 명시
UPDATE quest SET description = REPLACE(description, '지정한 파드는 어떻게 될까요?', '지정한 파드는 만든 직후에 어떻게 보일까요?') WHERE quest_set_id = 223 AND order_index = 5 AND INSTR(description, '지정한 파드는 어떻게 될까요?') > 0;
-- 세트 224 #2 description: 채점은 이름순 첫 Pod(db-1)를 요구
UPDATE quest SET description = REPLACE(description, '첫 번째 Pod 의 **이름만** `/tmp/first.txt` 에 저장하세요.', '첫 번째 Pod(조회되는 순서, 이름순 기준)의 **이름만** `/tmp/first.txt` 에 저장하세요.') WHERE quest_set_id = 224 AND order_index = 2 AND INSTR(description, '첫 번째 Pod 의 **이름만** `/tmp/first.txt` 에 저장하세요.') > 0;
-- 세트 228 #11 description: 최신 Docker prune 동작 반영
UPDATE quest SET description = REPLACE(description, '`docker volume prune` 은 어느 컨테이너도 쓰지 않는 볼륨을 지웁니다.', '`docker volume prune` 은 어느 컨테이너도 쓰지 않는 볼륨을 지웁니다(최신 Docker 는 기본이 이름 없는 볼륨만이고, `-a` 를 주면 이름 있는 볼륨까지 지웁니다).') WHERE quest_set_id = 228 AND order_index = 11 AND INSTR(description, '`docker volume prune` 은 어느 컨테이너도 쓰지 않는 볼륨을 지웁니다.') > 0;
-- 세트 228 #11 explanation: dangling 목록과 prune 후보가 완전히 같다는 부정확한 설명 보완
UPDATE quest SET explanation = REPLACE(explanation, '이 목록이 prune 의 후보와 같은 개념이에요.', '최신 Docker 의 prune 은 기본이 이름 없는 볼륨만이고 `-a` 를 주면 이름 있는 볼륨까지 지우니, 이 목록은 지워질 후보를 넉넉하게 보여 주는 셈이에요.') WHERE quest_set_id = 228 AND order_index = 11 AND INSTR(explanation, '이 목록이 prune 의 후보와 같은 개념이에요.') > 0;
-- 세트 239 #3 choices: --net 은 동작하는 별칭이라 확실한 오답으로 교체
UPDATE quest SET choices = REPLACE(choices, '"net"', '"connect"') WHERE quest_set_id = 239 AND order_index = 3 AND INSTR(choices, '"net"') > 0;
-- 세트 241 #11 choices: 1번과 겹치는 모호한 항목을 힌트의 '정리' 단계로 구체화
UPDATE quest SET choices = REPLACE(choices, '실행 중에 필요한 값은 `ENV` 로 넘겼는지 한 번 더 확인한다', '`docker rmi app` 으로 만든 이미지를 지워 정리한다') WHERE quest_set_id = 241 AND order_index = 11 AND INSTR(choices, '실행 중에 필요한 값은 `ENV` 로 넘겼는지 한 번 더 확인한다') > 0;
-- 세트 246 #1 choices: --net 은 동작하는 별칭이라 확실한 오답으로 교체
UPDATE quest SET choices = REPLACE(choices, '"net"', '"connect"') WHERE quest_set_id = 246 AND order_index = 1 AND INSTR(choices, '"net"') > 0;
-- 세트 246 #7 choices: --mount 에서 ro 도 유효하므로 확실한 오답으로 교체
UPDATE quest SET choices = REPLACE(choices, '"ro"', '"writeonly"') WHERE quest_set_id = 246 AND order_index = 7 AND INSTR(choices, '"ro"') > 0;
-- 세트 250 #13 choices: --rm 으로 이미 사라진 컨테이너를 inspect 하는 모순 제거
UPDATE quest SET choices = REPLACE(choices, '`docker inspect` 의 `HostConfig.NetworkMode` 가 `none` 인지 확인한다', '`none` 은 외부와 통신할 수 없는 상태라고 정리한다') WHERE quest_set_id = 250 AND order_index = 13 AND INSTR(choices, '`docker inspect` 의 `HostConfig.NetworkMode` 가 `none` 인지 확인한다') > 0;
-- 세트 250 #13 explanation: 문제와 무관한 해설 교체
UPDATE quest SET explanation = REPLACE(explanation, '`--network host` 에서는 `-p` 가 무시되고 경고가 나옵니다.', '`none` 네트워크는 `lo` 만 만들고 `eth0` 는 만들지 않습니다.') WHERE quest_set_id = 250 AND order_index = 13 AND INSTR(explanation, '`--network host` 에서는 `-p` 가 무시되고 경고가 나옵니다.') > 0;
-- 세트 250 #13 hint: 바뀐 4번 항목과 일치
UPDATE quest SET hint = REPLACE(hint, '저장값 확인 순서예요.', '정리 순서예요.') WHERE quest_set_id = 250 AND order_index = 13 AND INSTR(hint, '저장값 확인 순서예요.') > 0;
-- 세트 251 #13 choices: 인자 없이 바로 종료되는 클라이언트 수정
UPDATE quest SET choices = REPLACE(choices, '`docker run --rm --network app-net alpine` 으로 같은 네트워크에서 클라이언트를 실행한다', '`docker run -d --name cli --network app-net alpine sleep 60` 으로 같은 네트워크에서 클라이언트를 실행한다') WHERE quest_set_id = 251 AND order_index = 13 AND INSTR(choices, '`docker run --rm --network app-net alpine` 으로 같은 네트워크에서 클라이언트를 실행한다') > 0;
-- 세트 251 #13 choices: 3번에서 띄운 cli 컨테이너 안에서 확인하도록 구체화
UPDATE quest SET choices = REPLACE(choices, '클라이언트 안에서 `getent hosts database` 나 `ping database` 로 별칭이 찾아지는지 확인한다', '`docker exec cli getent hosts database` 로 별칭이 찾아지는지 확인한다') WHERE quest_set_id = 251 AND order_index = 13 AND INSTR(choices, '클라이언트 안에서 `getent hosts database` 나 `ping database` 로 별칭이 찾아지는지 확인한다') > 0;
-- 세트 267 #3 explanation: 실제 동작에 맞게 수정
UPDATE quest SET explanation = REPLACE(explanation, '`>` 는 문자열 비교(사전순)가 되어 결과가 어긋납니다.', '`[ ]` 안의 `>` 는 비교가 아니라 파일로 보내는 리다이렉트로 읽혀 엉뚱한 파일이 생깁니다.') WHERE quest_set_id = 267 AND order_index = 3 AND INSTR(explanation, '`>` 는 문자열 비교(사전순)가 되어 결과가 어긋납니다.') > 0;
-- 세트 273 #3 description: GNU sed 의 -r 도 동작하므로 POSIX 표준 옵션(-E)으로 한정
UPDATE quest SET description = REPLACE(description, '를 백슬래시 없이 쓰게 하는 옵션을 채우세요.', '를 백슬래시 없이 쓰게 하는, POSIX 표준 확장 정규식 옵션을 채우세요. (대문자 한 글자)') WHERE quest_set_id = 273 AND order_index = 3 AND INSTR(description, '를 백슬래시 없이 쓰게 하는 옵션을 채우세요.') > 0;
-- 세트 275 #1 description: -P(Perl 정규식)와 구분
UPDATE quest SET description = REPLACE(description, '을 **백슬래시 없이** 쓰게 하는 옵션을 채우세요.', '을 **백슬래시 없이** 쓰게 하는 POSIX 확장 정규식(ERE) 옵션을 채우세요.') WHERE quest_set_id = 275 AND order_index = 1 AND INSTR(description, '을 **백슬래시 없이** 쓰게 하는 옵션을 채우세요.') > 0;
-- 세트 277 #9 description: -e 는 모든 경로가 존재해야 하므로 -f 와 구분되는 조건 명시
UPDATE quest SET description = REPLACE(description, '심볼릭 링크를 끝까지 따라가 절대 경로를 출력하는 `readlink` 옵션을 채우세요.', '심볼릭 링크를 끝까지 따라가 절대 경로를 출력하는 `readlink` 옵션을 채우세요. (마지막 이름은 없어도 되는 쪽입니다)') WHERE quest_set_id = 277 AND order_index = 9 AND INSTR(description, '심볼릭 링크를 끝까지 따라가 절대 경로를 출력하는 `readlink` 옵션을 채우세요.') > 0;
-- 세트 284 #13 choices: 보기 명령의 ; 앞 백슬래시 누락
UPDATE quest SET choices = REPLACE(choices, '_ {} ;`', '_ {} \\\\;`') WHERE quest_set_id = 284 AND order_index = 13 AND INSTR(choices, '_ {} ;`') > 0;
-- 세트 286 #14 explanation: 문제는 %s 경우
UPDATE quest SET explanation = REPLACE(explanation, '모자란 숫자 자리는 `0` 으로 채워집니다.', '인자가 모자라면 `%s` 자리는 빈 문자열, `%d` 자리는 `0` 으로 채워집니다.') WHERE quest_set_id = 286 AND order_index = 14 AND INSTR(explanation, '모자란 숫자 자리는 `0` 으로 채워집니다.') > 0;
-- 세트 287 #12 description: 정답 순서를 하나로 고정
UPDATE quest SET description = REPLACE(description, 'YAML 파일로 앱을 배포하고 잘 떴는지 확인하는 순서입니다.', 'YAML 파일로 앱을 배포하고 잘 떴는지 확인하는 순서입니다. Pod 목록을 먼저 본 뒤, 이어서 진행 상태를 확인합니다.') WHERE quest_set_id = 287 AND order_index = 12 AND INSTR(description, 'YAML 파일로 앱을 배포하고 잘 떴는지 확인하는 순서입니다.') > 0;
-- 세트 287 #14 explanation: 실제 순서와 설명 일치
UPDATE quest SET explanation = REPLACE(explanation, '바꾸기 전과 후를 같은 명령으로 비교하면 변화를 눈으로 확인할 수 있습니다.', '바꾸기 전 상태를 먼저 보고, 바꾼 뒤에는 Pod 목록으로 개수를 확인한 다음 Deployment 상세(`-o wide`)로 마무리하면 변화를 눈으로 확인할 수 있습니다.') WHERE quest_set_id = 287 AND order_index = 14 AND INSTR(explanation, '바꾸기 전과 후를 같은 명령으로 비교하면 변화를 눈으로 확인할 수 있습니다.') > 0;
-- 세트 287 #14 hint: 마지막 두 단계 순서를 하나로 고정
UPDATE quest SET hint = REPLACE(hint, '지금 상태 → 변경 → 결과 순서예요.', '지금 상태 → 변경 → Pod 목록 → Deployment 상세 순서예요.') WHERE quest_set_id = 287 AND order_index = 14 AND INSTR(hint, '지금 상태 → 변경 → 결과 순서예요.') > 0;
-- 세트 288 #15 description: set image 의 컨테이너 이름 전제 명시
UPDATE quest SET description = REPLACE(description, 'Deployment 의 이미지를 새 버전으로 바꾸고 확인하는 순서입니다.', '컨테이너 이름이 `web` 인 Deployment 의 이미지를 새 버전으로 바꾸고 확인하는 순서입니다.') WHERE quest_set_id = 288 AND order_index = 15 AND INSTR(description, 'Deployment 의 이미지를 새 버전으로 바꾸고 확인하는 순서입니다.') > 0;
-- 세트 289 #12 description: 채점은 ConfigMap→Secret 한 가지만 인정하므로 조건 명시
UPDATE quest SET description = REPLACE(description, '순서에 맞게 놓아 보세요.', '순서에 맞게 놓아 보세요. (ConfigMap 을 먼저, Secret 을 그다음에 만듭니다.)') WHERE quest_set_id = 289 AND order_index = 12 AND INSTR(description, '순서에 맞게 놓아 보세요.') > 0;
-- 세트 296 #10 description: grep -A6 은 뒤 6줄만 출력
UPDATE quest SET description = REPLACE(description, '앞뒤 6줄과 함께', '뒤 6줄과 함께') WHERE quest_set_id = 296 AND order_index = 10 AND INSTR(description, '앞뒤 6줄과 함께') > 0;
-- 세트 296 #10 explanation: -A 뜻 설명 추가
UPDATE quest SET explanation = REPLACE(explanation, '이상하면 이벤트도 함께 보세요.', '이상하면 이벤트도 함께 보세요. `grep -A 숫자` 는 찾은 줄 뒤(After) 몇 줄까지 보여 줄지 정하는 옵션이에요.') WHERE quest_set_id = 296 AND order_index = 10 AND INSTR(explanation, '이상하면 이벤트도 함께 보세요.') > 0;
-- 세트 297 #3 description: 정답 db 의 근거가 문제에 없음
UPDATE quest SET description = REPLACE(description, '를 가리키는 필드와 값을 채우세요.', '를 가리키는 필드와 값을 채우세요. 앞에서 만든 Headless Service 의 이름은 `db` 입니다.') WHERE quest_set_id = 297 AND order_index = 3 AND INSTR(description, '를 가리키는 필드와 값을 채우세요.') > 0;
-- 세트 297 #3 hint: 힌트로 도출 가능하게
UPDATE quest SET hint = REPLACE(hint, '서비스 이름을 적는 필드예요.', 'Headless Service 의 이름을 그대로 적어요.') WHERE quest_set_id = 297 AND order_index = 3 AND INSTR(hint, '서비스 이름을 적는 필드예요.') > 0;
-- 세트 303 #10 template: jsonpath 식에는 바깥 중괄호가 필요
UPDATE quest SET template = REPLACE(template, 'jsonpath=\'.subsets[0].{0}\'', 'jsonpath=\'{.subsets[0].{0}}\'') WHERE quest_set_id = 303 AND order_index = 10 AND INSTR(template, 'jsonpath=\'.subsets[0].{0}\'') > 0;
-- 세트 305 #1 hint: restart 로 유도하는 힌트 수정
UPDATE quest SET hint = REPLACE(hint, '"다시 시작"이라는 뜻의 영어 단어예요.', 'pause(일시 중지)의 반대 동작이에요. 영어로 \'재개하다\'.') WHERE quest_set_id = 305 AND order_index = 1 AND INSTR(hint, '"다시 시작"이라는 뜻의 영어 단어예요.') > 0;
-- 세트 305 #1 title: restart 와 혼동 방지
UPDATE quest SET title = REPLACE(title, '롤아웃 다시 시작', '롤아웃 재개(pause 풀기)') WHERE quest_set_id = 305 AND order_index = 1 AND INSTR(title, '롤아웃 다시 시작') > 0;
-- 세트 324 #8 description: -s 도 단계를 보여 주므로 '충돌 파일만' 조건을 명시해 -u 하나로 한정
UPDATE quest SET description = REPLACE(description, '충돌한 파일의 **단계(1, 2, 3)별 버전**을 보는 `ls-files` 옵션을 채우세요.', '**충돌 난(병합 안 된) 파일만** 단계(1, 2, 3)별 버전으로 보는 `ls-files` 옵션을 채우세요.') WHERE quest_set_id = 324 AND order_index = 8 AND INSTR(description, '충돌한 파일의 **단계(1, 2, 3)별 버전**을 보는 `ls-files` 옵션을 채우세요.') > 0;
-- 세트 324 #10 choices: git 2.46+ 에서 --branches 가 --heads 의 별칭이라 정답이 될 수 있음. 존재하지 않는 옵션으로 교체
UPDATE quest SET choices = REPLACE(choices, '--branches', '--branch-list') WHERE quest_set_id = 324 AND order_index = 10 AND INSTR(choices, '--branches') > 0;
-- 세트 325 #12 hint: 3·4번 순서 근거 명시
UPDATE quest SET hint = REPLACE(hint, '파일 만들기 → 조건 연결 → 확인 순서예요.', '파일 만들기 → 조건 연결 → 확인 순서예요. 확인은 회사 폴더 먼저, 그다음 다른 폴더입니다.') WHERE quest_set_id = 325 AND order_index = 12 AND INSTR(hint, '파일 만들기 → 조건 연결 → 확인 순서예요.') > 0;
-- 세트 326 #13 hint: 3·4번 순서 근거 명시
UPDATE quest SET hint = REPLACE(hint, '현재 검색 → 과거 검색 → 위치 확인 순서예요.', '현재 검색 → 과거 검색 → 위치 확인 순서예요. 위치 확인은 짧은 해시를 먼저, 태그 기준 이름을 그다음에 봅니다.') WHERE quest_set_id = 326 AND order_index = 13 AND INSTR(hint, '현재 검색 → 과거 검색 → 위치 확인 순서예요.') > 0;
-- 세트 330 #4 explanation: 화면에 없는 데이터 결과 제거
UPDATE quest SET explanation = REPLACE(explanation, ' 고객 1 은 5000, 고객 3 은 30000 이에요.', '') WHERE quest_set_id = 330 AND order_index = 4 AND INSTR(explanation, ' 고객 1 은 5000, 고객 3 은 30000 이에요.') > 0;
-- 세트 330 #8 explanation: 화면에 없는 데이터 결과 제거
UPDATE quest SET explanation = REPLACE(explanation, ' 여기서는 3(Seoul, Busan, Daegu)이에요.', '') WHERE quest_set_id = 330 AND order_index = 8 AND INSTR(explanation, ' 여기서는 3(Seoul, Busan, Daegu)이에요.') > 0;
-- 세트 330 #12 explanation: 화면에 없는 데이터 결과 제거
UPDATE quest SET explanation = REPLACE(explanation, ' 결과로 고객 3 한 명이 나옵니다.', '') WHERE quest_set_id = 330 AND order_index = 12 AND INSTR(explanation, ' 결과로 고객 3 한 명이 나옵니다.') > 0;
-- 세트 331 #11 explanation: 화면에 없는 데이터 결과 제거
UPDATE quest SET explanation = REPLACE(explanation, ' 결과는 kim(12000)과 park(30000) 이에요.', '') WHERE quest_set_id = 331 AND order_index = 11 AND INSTR(explanation, ' 결과는 kim(12000)과 park(30000) 이에요.') > 0;
-- 세트 331 #12 explanation: 화면에 없는 데이터 결과 제거
UPDATE quest SET explanation = REPLACE(explanation, '결과는 lee, choi, jung 입니다. `INNER JOIN` 이었다면 이 세 명이 이미 사라져 아무것도 나오지 않아요.', '`INNER JOIN` 이었다면 주문 없는 고객이 이미 사라져 아무것도 나오지 않아요.') WHERE quest_set_id = 331 AND order_index = 12 AND INSTR(explanation, '결과는 lee, choi, jung 입니다. `INNER JOIN` 이었다면 이 세 명이 이미 사라져 아무것도 나오지 않아요.') > 0;
-- 세트 335 #10 description: 채점이 파일에서 글자 set -e, echo end 를 grep 함
UPDATE quest SET description = REPLACE(description, '스크립트의 앞부분에 알맞은 설정을 한 줄 넣으세요.', '스크립트의 앞부분에 알맞은 설정을 한 줄 넣으세요. 설정은 `set -e` 로 쓰고, `end` 는 `echo end` 로 출력하세요.') WHERE quest_set_id = 335 AND order_index = 10 AND INSTR(description, '스크립트의 앞부분에 알맞은 설정을 한 줄 넣으세요.') > 0;
-- 세트 341 #7 description: IP별 횟수 문제는 6번
UPDATE quest SET description = REPLACE(description, '5번의 결과를', '6번의 결과를') WHERE quest_set_id = 341 AND order_index = 7 AND INSTR(description, '5번의 결과를') > 0;
-- 세트 341 #12 hint: 기존 힌트는 $ 이스케이프 누락으로 스크립트가 깨지는 함정
UPDATE quest SET hint = REPLACE(hint, '따옴표가 섞이니 바깥은 큰따옴표가 편합니다.', '큰따옴표로 감싸면 `$9` 같은 것이 쉘에서 먼저 풀리니 `\\$9` 로 쓰거나, `cat > 파일 <<\'EOF\'` (heredoc) 으로 쓰세요.') WHERE quest_set_id = 341 AND order_index = 12 AND INSTR(hint, '따옴표가 섞이니 바깥은 큰따옴표가 편합니다.') > 0;
-- 세트 346 #1 hint: Dockerfile 만드는 방법 안내 추가
UPDATE quest SET hint = REPLACE(hint, '빌드는 Dockerfile 이 있는 폴더에서', '파일은 `cat > Dockerfile <<\'EOF\'` 와 `EOF` 사이에 내용을 적어 만들 수 있어요. 빌드는 Dockerfile 이 있는 폴더에서') WHERE quest_set_id = 346 AND order_index = 1 AND INSTR(hint, '빌드는 Dockerfile 이 있는 폴더에서') > 0;
-- 세트 356 #12 hint: 고정 정답 순서를 힌트에 명시(숨은 조건)
UPDATE quest SET hint = REPLACE(hint, '목록 확인 → 만들기 → 상태 확인 순서예요.', '목록 확인 → 만들기 → 상태 확인 순서예요. 목록은 플레이버 → 이미지 → 보안 그룹·키페어 순으로 봅니다.') WHERE quest_set_id = 356 AND order_index = 12 AND INSTR(hint, '목록 확인 → 만들기 → 상태 확인 순서예요.') > 0;
-- 세트 359 #3 explanation: 단정 표현 보완, 정답은 기본 설명 기준으로 유지
UPDATE quest SET explanation = REPLACE(explanation, '사용이 끝나면 떼어 다른 서버에 붙일 수 있습니다.', '사용이 끝나면 떼어 다른 서버에 붙일 수 있습니다. (기본 설정에서는 한 대이고, 멀티어태치 볼륨 타입을 따로 쓰면 여러 대에 붙일 수도 있습니다.)') WHERE quest_set_id = 359 AND order_index = 3 AND INSTR(explanation, '사용이 끝나면 떼어 다른 서버에 붙일 수 있습니다.') > 0;
-- 세트 363 #11 description: description 에 {0} 노출 제거
UPDATE quest SET description = REPLACE(description, '객체 하나의 **기본 최대 크기** 는 {0} GB 입니다. 빈칸을 채우세요.', '객체 하나의 **기본 최대 크기** 를 채우세요.') WHERE quest_set_id = 363 AND order_index = 11 AND INSTR(description, '객체 하나의 **기본 최대 크기** 는 {0} GB 입니다. 빈칸을 채우세요.') > 0;
-- 세트 363 #11 template: 빈칸 {0} 이 template 에 있어야 화면에 그려짐
UPDATE quest SET template = REPLACE(template, '5', '객체 하나의 기본 최대 크기는 {0} GB 입니다.') WHERE quest_set_id = 363 AND order_index = 11 AND INSTR(template, '5') > 0;
-- 세트 377 #5 explanation: 어색한 문장 교체, 사실 오류 소지 제거
UPDATE quest SET explanation = REPLACE(explanation, 'Ceph 용어집은 Ceph 블록 스토리지가 지원하는 세 종류(블록·오브젝트·파일) 중 하나라고 설명합니다.', 'Ceph 는 하나의 클러스터에서 블록(RBD), 파일(CephFS), 오브젝트(RGW) 세 가지 방식을 모두 제공합니다.') WHERE quest_set_id = 377 AND order_index = 5 AND INSTR(explanation, 'Ceph 용어집은 Ceph 블록 스토리지가 지원하는 세 종류(블록·오브젝트·파일) 중 하나라고 설명합니다.') > 0;
-- 세트 381 #8 explanation: 괄호 표현이 RAM 제외로 읽히는 모호함 해소
UPDATE quest SET explanation = REPLACE(explanation, 'virsh 문서는 save 를 "실행 중인 도메인(RAM, 디스크 상태 제외)을 상태 파일로 저장"하여 나중에 복원할 수 있게 하는 명령으로 설명합니다.', '`save` 는 실행 중인 도메인의 메모리(RAM) 상태를 상태 파일로 저장해 나중에 복원할 수 있게 하는 명령입니다. 디스크 내용은 포함하지 않습니다.') WHERE quest_set_id = 381 AND order_index = 8 AND INSTR(explanation, 'virsh 문서는 save 를 "실행 중인 도메인(RAM, 디스크 상태 제외)을 상태 파일로 저장"하여 나중에 복원할 수 있게 하는 명령으로 설명합니다.') > 0;
-- 세트 381 #8 hint: 해설에서 괄호 표현을 없앤 것과 맞춤
UPDATE quest SET hint = REPLACE(hint, '문서가 괄호로 알려 줘요.', '메모리와 디스크 중 어느 쪽일까요?') WHERE quest_set_id = 381 AND order_index = 8 AND INSTR(hint, '문서가 괄호로 알려 줘요.') > 0;
-- 세트 384 #11 description: 빈칸이 어떤 옵션인지 명시
UPDATE quest SET description = REPLACE(description, '디스크까지 함께 옮기는 라이브 마이그레이션 옵션 이름입니다.', '디스크까지 함께 옮기는, `--live-migration` 과 함께 쓰는 옵션 이름입니다.') WHERE quest_set_id = 384 AND order_index = 11 AND INSTR(description, '디스크까지 함께 옮기는 라이브 마이그레이션 옵션 이름입니다.') > 0;
-- 세트 384 #11 template: 라이브 마이그레이션 명령으로 읽히도록 명시 (answer_spec/채점 불변)
UPDATE quest SET template = REPLACE(template, 'openstack server migrate --{0}', 'openstack server migrate --live-migration --{0}') WHERE quest_set_id = 384 AND order_index = 11 AND INSTR(template, 'openstack server migrate --{0}') > 0;
-- 세트 401 #9 description: 문체 통일
UPDATE quest SET description = REPLACE(description, '를 쓴다. 기본값은', '를 씁니다. 이 포트의 기본값은') WHERE quest_set_id = 401 AND order_index = 9 AND INSTR(description, '를 쓴다. 기본값은') > 0;
-- 세트 403 #2 explanation: 제작 메모 제거
UPDATE quest SET explanation = REPLACE(explanation, ' 버전별 변경 이력은 해당 페이지에서 확인되지 않았습니다.', '') WHERE quest_set_id = 403 AND order_index = 2 AND INSTR(explanation, ' 버전별 변경 이력은 해당 페이지에서 확인되지 않았습니다.') > 0;
-- 세트 418 #6 description: 문서 기준임을 명시
UPDATE quest SET description = REPLACE(description, '`tcp_max_syn_backlog` 의 **기본값** 은 얼마일까요?', '`man 7 tcp` 문서가 적은 `tcp_max_syn_backlog` 의 **기본값** 은 얼마일까요?') WHERE quest_set_id = 418 AND order_index = 6 AND INSTR(description, '`tcp_max_syn_backlog` 의 **기본값** 은 얼마일까요?') > 0;
-- 세트 418 #6 explanation: 환경별 차이 안내
UPDATE quest SET explanation = REPLACE(explanation, '메모리가 128MB 이상이면 1024, 32MB 이하이면 128 로 조정된다고 설명합니다.', '메모리가 128MB 이상이면 1024, 32MB 이하이면 128 로 조정된다고 설명합니다. 실제 서버의 값은 메모리와 커널 버전에 따라 다를 수 있으니 `sysctl net.ipv4.tcp_max_syn_backlog` 로 확인하세요.') WHERE quest_set_id = 418 AND order_index = 6 AND INSTR(explanation, '메모리가 128MB 이상이면 1024, 32MB 이하이면 128 로 조정된다고 설명합니다.') > 0;
-- 세트 426 #7 description: 문서 기준임을 명시
UPDATE quest SET description = REPLACE(description, '`timestamp_timeout` 의 **기본값** 은 얼마일까요?', 'sudoers 문서 기준으로 `timestamp_timeout` 의 **기본값** 은 얼마일까요?') WHERE quest_set_id = 426 AND order_index = 7 AND INSTR(description, '`timestamp_timeout` 의 **기본값** 은 얼마일까요?') > 0;
-- 세트 426 #7 explanation: 환경별 차이 안내
UPDATE quest SET explanation = REPLACE(explanation, '기본 5분이라고 설명합니다.', '기본 5분이라고 설명합니다. 이 값은 빌드 때 바뀔 수 있어 배포판 패키지에 따라 다를 수 있으며, `sudo -V` 로 확인할 수 있습니다.') WHERE quest_set_id = 426 AND order_index = 7 AND INSTR(explanation, '기본 5분이라고 설명합니다.') > 0;
-- 세트 426 #11 description: 문서 기준임을 명시
UPDATE quest SET description = REPLACE(description, '암호를 다시 묻기까지의 **기본 시간(분)** 입니다.', 'sudoers 문서 기준으로 암호를 다시 묻기까지의 **기본 시간(분)** 입니다.') WHERE quest_set_id = 426 AND order_index = 11 AND INSTR(description, '암호를 다시 묻기까지의 **기본 시간(분)** 입니다.') > 0;
-- 세트 432 #10 hint: 힌트가 정답 글자를 그대로 알려 줌
UPDATE quest SET hint = REPLACE(hint, '소문자 n 이에요.', '값만 보고 싶을 때 "number"(값) 를 떠올려 보세요. 소문자예요.') WHERE quest_set_id = 432 AND order_index = 10 AND INSTR(hint, '소문자 n 이에요.') > 0;
-- 세트 432 #11 hint: 기존 힌트가 정답 -p 를 배제하는 것처럼 읽힘
UPDATE quest SET hint = REPLACE(hint, '"파일" 의 p 가 아니에요. 로드를 뜻해요.', '설정 파일을 읽어 와서 적용해요. 알파벳 p 로 시작해요.') WHERE quest_set_id = 432 AND order_index = 11 AND INSTR(hint, '"파일" 의 p 가 아니에요. 로드를 뜻해요.') > 0;
-- 세트 436 #11 hint: 정답 글자를 직접 알려 주는 힌트를 뜻 연상으로 변경
UPDATE quest SET hint = REPLACE(hint, '대문자 P 예요.', '"Permanent"(영구) 의 첫 글자예요. 대문자예요.') WHERE quest_set_id = 436 AND order_index = 11 AND INSTR(hint, '대문자 P 예요.') > 0;
-- 세트 437 #5 description: 문서 기준으로 한정
UPDATE quest SET description = REPLACE(description, '따로 설정하지 않았을 때 **자동 기본** qdisc 는 무엇일까요?', 'tc 문서 기준으로, 따로 설정하지 않았을 때 **자동 기본** qdisc 는 무엇일까요?') WHERE quest_set_id = 437 AND order_index = 5 AND INSTR(description, '따로 설정하지 않았을 때 **자동 기본** qdisc 는 무엇일까요?') > 0;
-- 세트 437 #5 explanation: 현재 배포판 차이 안내
UPDATE quest SET explanation = REPLACE(explanation, 'ToS 와 패킷 우선순위를 존중하는 3밴드 큐입니다.', 'ToS 와 패킷 우선순위를 존중하는 3밴드 큐입니다. 최근 배포판은 `net.core.default_qdisc` 설정에 따라 fq_codel 이 쓰이는 경우가 많습니다.') WHERE quest_set_id = 437 AND order_index = 5 AND INSTR(explanation, 'ToS 와 패킷 우선순위를 존중하는 3밴드 큐입니다.') > 0;
-- 세트 446 #11 hint: 정답 글자를 직접 알려 주는 힌트를 뜻 연상으로 변경
UPDATE quest SET hint = REPLACE(hint, 'token 의 t 예요.', '토큰(token) 으로 일치하는 장치를 찾는 옵션이에요.') WHERE quest_set_id = 446 AND order_index = 11 AND INSTR(hint, 'token 의 t 예요.') > 0;
-- 세트 453 #12 choices: -b 는 -a 에 붙이는 옵션이라 독립 단계가 아님
UPDATE quest SET choices = REPLACE(choices, '"`-b` 로 시그니처를 백업하며 삭제를 준비한다", "`wipefs -a` 로 시그니처를 지운다"', '"`wipefs -b -a` 로 시그니처를 백업하면서 지운다", "`wipefs` 로 다시 조회해 시그니처가 사라졌는지 확인한다"') WHERE quest_set_id = 453 AND order_index = 12 AND INSTR(choices, '"`-b` 로 시그니처를 백업하며 삭제를 준비한다", "`wipefs -a` 로 시그니처를 지운다"') > 0;
-- 세트 453 #12 hint: 보기 변경에 맞춰 힌트 갱신
UPDATE quest SET hint = REPLACE(hint, '조회 → 시험 → 백업 → 삭제예요.', '조회 → 시험 → 백업하며 삭제 → 재확인이에요.') WHERE quest_set_id = 453 AND order_index = 12 AND INSTR(hint, '조회 → 시험 → 백업 → 삭제예요.') > 0;
-- 세트 459 #12 choices: #2 경고와 일관되게 VM 정지 후 info 조회
UPDATE quest SET choices = REPLACE(choices, '"`qemu-img info` 로 현재 크기를 확인한다", "VM 을 끄고 이미지를 쓰는 프로세스가 없게 한다"', '"VM 을 끄고 이미지를 쓰는 프로세스가 없게 한다", "`qemu-img info` 로 현재 크기를 확인한다"') WHERE quest_set_id = 459 AND order_index = 12 AND INSTR(choices, '"`qemu-img info` 로 현재 크기를 확인한다", "VM 을 끄고 이미지를 쓰는 프로세스가 없게 한다"') > 0;
-- 세트 459 #12 hint: 보기 순서 변경에 맞춰 힌트 갱신
UPDATE quest SET hint = REPLACE(hint, '확인 → 정지 → 확장 → 안에서 사용이에요.', '정지 → 확인 → 확장 → 안에서 사용이에요.') WHERE quest_set_id = 459 AND order_index = 12 AND INSTR(hint, '확인 → 정지 → 확장 → 안에서 사용이에요.') > 0;
-- 세트 469 #7 explanation: bridge-fdb(8) 기본값 표기가 서로 반대로 읽힐 수 있어 기본값 문장 삭제
UPDATE quest SET explanation = REPLACE(explanation, 'self 는 드라이버가 직접 수행하며 master 를 지정하지 않으면 기본으로 켜집니다.', 'self 는 포트 드라이버가 직접 수행합니다.') WHERE quest_set_id = 469 AND order_index = 7 AND INSTR(explanation, 'self 는 드라이버가 직접 수행하며 master 를 지정하지 않으면 기본으로 켜집니다.') > 0;
-- 세트 477 #4 description: -m 사용 안내
UPDATE quest SET description = REPLACE(description, '어느 쪽 변경이 버려지는지 알고 써야 합니다.', '어느 쪽 변경이 버려지는지 알고 써야 합니다. 병합 때 편집기를 열지 않으려면 `-m` 으로 메시지를 줍니다.') WHERE quest_set_id = 477 AND order_index = 4 AND INSTR(description, '어느 쪽 변경이 버려지는지 알고 써야 합니다.') > 0;
-- 세트 477 #4 hint: 병합 커밋 메시지 편집기 방지
UPDATE quest SET hint = REPLACE(hint, '`git merge -X theirs feature`', '`git merge -X theirs feature -m \'merge feature\'`') WHERE quest_set_id = 477 AND order_index = 4 AND INSTR(hint, '`git merge -X theirs feature`') > 0;
-- 세트 477 #5 hint: 병합 커밋 메시지 편집기 방지
UPDATE quest SET hint = REPLACE(hint, '`git merge -s ours feature`', '`git merge -s ours feature -m \'merge feature\'`') WHERE quest_set_id = 477 AND order_index = 5 AND INSTR(hint, '`git merge -s ours feature`') > 0;
-- 세트 479 #2 description: 채점이 인자 없는 경우 0 을 확인함
UPDATE quest SET description = REPLACE(description, '(`while` 과 `shift` 를 쓰세요.)', '인자가 하나도 없으면 `0` 을 출력합니다. (`while` 과 `shift` 를 쓰세요.)') WHERE quest_set_id = 479 AND order_index = 2 AND INSTR(description, '(`while` 과 `shift` 를 쓰세요.)') > 0;
-- 세트 479 #6 description: 채점이 'declare -A' 문자열을 확인함
UPDATE quest SET description = REPLACE(description, '(`kim=30`, `lee=25`).', '(`kim=30`, `lee=25`). 연관 배열은 `declare -A` 로 만드세요.') WHERE quest_set_id = 479 AND order_index = 6 AND INSTR(description, '(`kim=30`, `lee=25`).') > 0;
-- 세트 479 #8 description: 채점이 'local ' 사용을 확인함
UPDATE quest SET description = REPLACE(description, '`bash /tmp/lab/max.sh 3 9` 는 `9` 입니다.', '`bash /tmp/lab/max.sh 3 9` 는 `9` 입니다. 함수 안 변수는 `local` 로 선언하세요.') WHERE quest_set_id = 479 AND order_index = 8 AND INSTR(description, '`bash /tmp/lab/max.sh 3 9` 는 `9` 입니다.') > 0;
-- 세트 500 #1 description: kubectl run 은 항상 Pod 만 만듦. 낡은 설명 교정
UPDATE quest SET description = REPLACE(description, '`--restart=Never` 라야 Deployment 가 아닌 Pod 하나로 만들어집니다.', '`--restart=Never` 로 두어야 명령이 끝난 뒤 컨테이너가 다시 시작되지 않고 Pod 가 끝나서 `--rm` 으로 지워집니다.') WHERE quest_set_id = 500 AND order_index = 1 AND INSTR(description, '`--restart=Never` 라야 Deployment 가 아닌 Pod 하나로 만들어집니다.') > 0;
-- 세트 500 #10 choices: limits 만 적으면 requests 가 자동으로 같아져 Guaranteed 가 될 수 있어 복수 정답이 됨. 확실한 오답으로 교체
UPDATE quest SET choices = REPLACE(choices, '컨테이너가 하나이고 limits 만 있다', 'requests 만 적고 limits 는 적지 않는다') WHERE quest_set_id = 500 AND order_index = 10 AND INSTR(choices, '컨테이너가 하나이고 limits 만 있다') > 0;
-- 세트 500 #11 explanation: 현재 kubectl 은 Deployment 를 만들지 않음. 낡은 해설 교정
UPDATE quest SET explanation = REPLACE(explanation, '--restart=Never 로 두어야 Pod 하나가 만들어지고 --rm 이 끝난 뒤 지웁니다. Always(기본)는 Deployment 로 만들려 하고, OnFailure 는 Job 에 가깝고, Once 는 없는 값입니다.', '--restart=Never 로 두어야 명령이 끝난 뒤 다시 시작되지 않아 Pod 가 끝나고, --rm 이 그때 지웁니다. Always(기본)는 명령이 끝나도 컨테이너를 계속 다시 시작해 Pod 가 끝나지 않고, OnFailure 는 실패할 때만 다시 시작하며, Once 는 없는 값입니다.') WHERE quest_set_id = 500 AND order_index = 11 AND INSTR(explanation, '--restart=Never 로 두어야 Pod 하나가 만들어지고 --rm 이 끝난 뒤 지웁니다. Always(기본)는 Deployment 로 만들려 하고, OnFailure 는 Job 에 가깝고, Once 는 없는 값입니다.') > 0;
-- 세트 501 #6 hint: json 출력은 {"8080/tcp":{}} 라 채점(8080/tcp 정확 일치)에 실패. 키만 출력하고 저장까지 안내
UPDATE quest SET hint = REPLACE(hint, '`docker image inspect -f \'{{json .Config.ExposedPorts}}\' t6`', '`docker image inspect -f \'{{range $p, $_ := .Config.ExposedPorts}}{{$p}}{{end}}\' t6 > /tmp/q6.txt`') WHERE quest_set_id = 501 AND order_index = 6 AND INSTR(hint, '`docker image inspect -f \'{{json .Config.ExposedPorts}}\' t6`') > 0;
