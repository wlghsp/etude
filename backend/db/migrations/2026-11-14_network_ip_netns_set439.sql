-- 퀴즈 세트 439. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_network_round8.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 439, 'ip netns 로 네트워크 네임스페이스 다루기: /var/run/netns, exec, pids, 삭제, nsid', '네트워크 네임스페이스 명령을 읽습니다. /var/run/netns 객체, exec 이 마운트 네임스페이스로 설정 파일을 바인드 마운트하는 점, -all, identify·pids, 삭제 시 사용자가 없어질 때까지 유지되는 점, /etc/netns/NAME 순서, nsid 를 봅니다.', 'quiz', '네트워크'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 439);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 439, 1, '/var/run/netns', '이름 있는 네트워크 네임스페이스는 관례상 **어디** 에 있는 객체일까요?', '/var/run 아래예요.', NULL, NULL, '[]', 'choice', '["/proc/net/NAME", "/etc/netns/NAME", "/var/run/netns/NAME", "/sys/class/net/NAME"]', 2, 'ip-netns 문서는 관례상 이름 있는 네트워크 네임스페이스가 /var/run/netns/NAME 의 열 수 있는 객체라고 설명합니다. 이 파일을 열어 두면 네임스페이스가 유지됩니다.', NULL, NULL, NULL, '[{"title": "ip-netns(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-netns.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 439 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 439, 2, 'exec 목적', '`ip netns exec` 가 해 주는 일은 무엇일까요?', '인식 못 하는 앱도 돼요.', NULL, NULL, '[]', 'choice', '["실행 중인 프로세스를 다른 네임스페이스로 옮긴다", "네임스페이스를 모르는 앱을 다른 네임스페이스에서 실행한다", "네임스페이스를 새로 만들고 명령을 저장한다", "네임스페이스의 모든 장치를 삭제한다"]', 1, '문서는 exec 이 네임스페이스를 인식하지 못하는 애플리케이션을 기본이 아닌 네임스페이스에서 실행하게 해 준다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-netns(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-netns.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 439 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 439, 3, 'exec 내부', '`ip netns exec` 는 **설정 파일** 을 어떻게 다룰까요?', '마운트 네임스페이스를 써요.', NULL, NULL, '[]', 'choice', '["네임스페이스별 설정 파일을 /etc 에 바인드 마운트한다", "설정 파일을 /etc 에 복사해 원본을 덮어쓴다", "설정 파일을 전혀 읽지 않고 명령만 실행한다", "설정 파일 내용을 환경변수로 바꿔 넘긴다"]', 0, '문서는 exec 이 마운트 네임스페이스를 만들고 네임스페이스별 설정 파일을 전통적인 위치(/etc)에 바인드 마운트해 다른 프로세스에 영향이 없다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-netns(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-netns.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 439 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 439, 4, '-all', '`ip -all netns exec` 는 어떻게 실행할까요?', '전부 돌아요.', NULL, NULL, '[]', 'choice', '["첫 번째 실패에서 곧바로 중단한다", "기본 네임스페이스에서만 한 번 실행한다", "모든 네임스페이스에서 동시에 병렬로 실행한다", "실패해도 모든 네임스페이스에서 차례로 실행한다"]', 3, '문서는 -all 이 명령이 일부에서 실패해도 각 네임스페이스에서 동기적으로 실행하고 네임스페이스 이름을 출력한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-netns(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-netns.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 439 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 439, 5, 'identify', '`ip netns identify [PID]` 는 무엇을 알려 줄까요?', '이름을 찾아요.', NULL, NULL, '[]', 'choice', '["네임스페이스에 속한 프로세스 목록", "네임스페이스의 장치 목록", "그 프로세스가 속한 네임스페이스의 이름", "네임스페이스의 숫자 ID"]', 2, '문서는 identify 가 /var/run/netns 를 훑어 지정한 프로세스(없으면 현재 프로세스)의 네트워크 네임스페이스 이름을 찾는다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-netns(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-netns.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 439 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 439, 6, 'pids', '`ip netns pids NAME` 은 무엇을 출력할까요?', '프로세스예요.', NULL, NULL, '[]', 'choice', '["네임스페이스가 열고 있는 파일", "그 네임스페이스의 프로세스", "네임스페이스에 속한 장치", "네임스페이스를 만든 사용자"]', 1, '문서는 pids 가 proc 를 훑어 지정한 네임스페이스를 기본 네트워크 네임스페이스로 가진 프로세스를 찾는다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-netns(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-netns.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 439 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 439, 7, '삭제와 사용자', '아직 프로세스가 쓰는 네임스페이스를 `ip netns del` 하면 어떻게 될까요?', '사용자가 있으면 남아요.', NULL, NULL, '[]', 'choice', '["사용자가 없어질 때까지 유지된다", "즉시 해제되고 프로세스는 종료된다", "삭제 명령이 항상 실패한다", "프로세스가 기본 네임스페이스로 자동 이동한다"]', 0, '문서는 마지막 사용자였다면 네임스페이스가 해제되고 물리 장치가 기본 네임스페이스로 이동하며, 아니면 사용자가 없어질 때까지 유지된다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-netns(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-netns.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 439 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 439, 8, '/etc/netns', '응용 프로그램은 전역 네트워크 설정 파일을 **어떤 순서** 로 찾아야 할까요?', '네임스페이스 쪽이 먼저예요.', NULL, NULL, '[]', 'choice', '["/etc/ 를 먼저, 그다음 /etc/netns/NAME/", "/var/run/netns/NAME 만", "/proc/net 만", "/etc/netns/NAME/ 을 먼저, 그다음 /etc/"]', 3, '문서는 응용 프로그램이 전역 설정 파일을 /etc/netns/NAME/ 에서 먼저 찾고 그다음 /etc/ 에서 찾는다고 설명합니다. 예시는 /etc/netns/myvpn/resolv.conf 입니다.', NULL, NULL, NULL, '[{"title": "ip-netns(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-netns.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 439 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 439, 9, 'nsid', '`ip netns set NAME NETNSID` 로 정한 **nsid** 에 대한 설명으로 맞는 것은 무엇일까요?', '한 번 정하면 못 바꿔요.', NULL, NULL, '[]', 'choice', '["모든 네임스페이스에서 유효하고 언제든 바꿀 수 있다", "현재 네임스페이스에서만 유효하고 언제든 바꿀 수 있다", "현재 네임스페이스에서만 유효하고 한 번 정하면 바꿀 수 없다", "모든 네임스페이스에서 유효하지만 바꿀 수 없다"]', 2, '문서는 nsid 가 피어 네트워크 네임스페이스를 식별하며 현재 네임스페이스 안에서만 유효하고 한 번 할당되면 바꿀 수 없다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-netns(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-netns.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 439 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 439, 10, '명령 실행', '네임스페이스 안에서 명령을 **실행하는** 하위 명령입니다. 빈칸을 채우세요.', '"실행" 이에요.', NULL, NULL, '[]', 'fill', '["exec", "add", "identify", "monitor"]', NULL, 'exec 은 지정한 네임스페이스에서 명령을 실행합니다. 문서의 예시는 vpn 네임스페이스에서 lo 를 올립니다.', '[0]', 'ip netns {0} myvpn ip link set lo up', NULL, '[{"title": "ip-netns(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-netns.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 439 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 439, 11, '프로세스 찾기', '네임스페이스를 쓰는 **프로세스 번호** 를 출력하는 하위 명령입니다. 빈칸을 채우세요.', 'PID 의 복수예요.', NULL, NULL, '[]', 'fill', '["pids", "identify", "list", "attach"]', NULL, '문서는 삭제 전 `ip netns pids net0 | xargs kill` 로 프로세스를 먼저 종료할 것을 권합니다.', '[0]', 'ip netns {0} net0 | xargs kill', NULL, '[{"title": "ip-netns(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-netns.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 439 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 439, 12, '네임스페이스 삭제', '쓰는 프로세스가 있는 네임스페이스를 정리하는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '찾고 → 끄고 → 지우고 → 해제예요.', NULL, NULL, '[]', 'order', '["`ip netns pids net0` 로 그 네임스페이스를 쓰는 프로세스를 찾는다", "찾은 프로세스를 종료한다", "`ip netns del net0` 로 네임스페이스를 지운다", "마지막 사용자가 사라지면 네임스페이스가 해제되고 물리 장치가 기본 네임스페이스로 돌아온다"]', NULL, '문서의 pids·delete 설명과 kill 권고를 이은 절차입니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "ip-netns(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-netns.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 439 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 644 WHERE id = 117;
UPDATE quest_set SET display_order = 640, unit_id = (SELECT id FROM unit WHERE id = 47), icon = '🏝️' WHERE id = 439;
