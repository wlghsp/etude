-- 퀴즈 세트 408. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_network_round4.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 408, 'ip route 깊게: 경로 타입, metric, scope, proto, nexthop 조회', '리눅스 경로를 ip route 로 읽습니다. unicast·unreachable·blackhole·prohibit·throw 타입의 차이와 오류, metric·scope·proto 기본값, default·onlink, ip route get 조회를 봅니다.', 'quiz', '네트워크'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 408);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 408, 1, 'route 타입 기본', '`ip route add` 에서 경로 **타입을 생략** 하면 어떤 타입으로 볼까요?', '실제 경로를 뜻하는 쪽이에요.', NULL, NULL, '[]', 'choice', '["local 로 보고 루프백으로 전달한다", "blackhole 로 보고 조용히 버린다", "unicast 로 본다", "throw 로 보고 다음 테이블로 넘긴다"]', 2, 'ip-route 문서는 타입을 생략하면 unicast 로 간주한다고 설명합니다. unicast 는 목적지 prefix 에 대한 실제 경로입니다.', NULL, NULL, NULL, '[{"title": "ip-route(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-route.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 408 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 408, 2, 'unreachable 경로', '**unreachable** 타입 경로로 가는 패킷은 어떻게 처리될까요?', '버리면서 알려 줘요.', NULL, NULL, '[]', 'choice', '["조용히 버리고 아무 메시지도 보내지 않는다", "버리고 host unreachable 을 보낸다", "로컬 주소로 보고 루프백으로 전달한다", "다음 테이블을 차례로 다시 찾아본다"]', 1, '문서는 unreachable 이 패킷을 버리고 ICMP host unreachable 을 생성하며 로컬 발신자는 EHOSTUNREACH 를 받는다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-route(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-route.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 408 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 408, 3, 'blackhole 경로', '**blackhole** 타입 경로로 가는 패킷은 어떻게 처리될까요?', '소리 없이 버려요.', NULL, NULL, '[]', 'choice', '["조용히 버린다(로컬 발신자는 EINVAL)", "버리고 ICMP unreachable 메시지를 보낸다", "관리상 금지라는 ICMP 메시지를 보낸다", "링크 브로드캐스트로 내보낸다"]', 0, '문서는 blackhole 이 패킷을 조용히 버리며 로컬 발신자는 EINVAL 오류를 받는다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-route(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-route.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 408 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 408, 4, 'prohibit 경로', '**prohibit** 타입 경로의 동작으로 맞는 것은 무엇일까요?', '관리자가 막았다는 뜻이에요.', NULL, NULL, '[]', 'choice', '["조용히 버리고 로컬 발신자는 EINVAL 을 받는다", "버리고 host unreachable 을 보낸다", "목적지를 NAT 로 바꿔 전달한다", "버리고 관리상 금지 ICMP 를 보낸다"]', 3, '문서는 prohibit 이 패킷을 버리고 관리상 통신이 금지되었다는 ICMP 메시지를 생성하며 로컬 발신자는 EACCES 를 받는다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-route(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-route.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 408 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 408, 5, 'throw 경로', '**throw** 타입 경로가 선택되면 어떻게 될까요?', '정책 라우팅과 함께 쓰는 제어용이에요.', NULL, NULL, '[]', 'choice', '["패킷이 즉시 로컬로 전달된다", "패킷이 링크 브로드캐스트로 나간다", "그 테이블 조회가 실패한 것처럼 끝난다", "같은 테이블에서 다음 경로를 찾는다"]', 2, '문서는 throw 가 정책 라우팅용 제어 경로이며 선택되면 해당 테이블 조회가 경로를 못 찾은 것처럼 끝나고 net unreachable 이 생성된다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-route(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-route.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 408 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 408, 6, 'metric', '경로의 **metric** 값은 어떻게 쓰일까요?', '숫자가 작은 쪽이에요.', NULL, NULL, '[]', 'choice', '["값이 높은 경로가 우선한다", "값이 낮은 경로가 우선한다", "경로가 유지되는 시간(초)을 정한다", "넥스트홉의 개수를 제한한다"]', 1, '문서는 metric 이 경로의 선호도를 나타내는 임의의 32비트 숫자이며 값이 낮은 경로가 우선한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-route(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-route.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 408 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 408, 7, 'scope 기본값', '게이트웨이를 거치는 unicast 경로의 **scope 기본값** 은 무엇일까요?', '가장 넓은 범위예요.', NULL, NULL, '[]', 'choice', '["global", "link", "host", "site"]', 0, '문서는 scope 를 생략하면 게이트웨이를 거치는 unicast 는 global, 직접 연결된 unicast 와 broadcast 는 link, local 은 host 라고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-route(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-route.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 408 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 408, 8, 'proto 기본값', '`proto` 를 **생략** 하면 경로를 추가한 프로토콜은 무엇으로 볼까요?', '부팅과 관련된 값이에요.', NULL, NULL, '[]', 'choice', '["static", "kernel", "redirect", "boot"]', 3, '문서는 proto 를 생략하면 boot 로 간주한다고 설명합니다. boot 경로는 라우팅 데몬이 시작되면 모두 제거되고, 관리자가 데몬을 무시하려 설치하는 경로는 static 입니다.', NULL, NULL, NULL, '[{"title": "ip-route(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-route.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 408 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 408, 9, 'ip route get', '`ip route get 8.8.8.8` 은 무엇을 할까요?', '조회만 해요.', NULL, NULL, '[]', 'choice', '["8.8.8.8 로 ICMP 요청을 실제로 보낸다", "8.8.8.8 로 가는 경로를 새로 추가한다", "패킷은 보내지 않고 커널이 고를 경로를 조회해 보여 준다", "라우팅 테이블 전체를 비운다"]', 2, '문서는 ip route get 이 단일 경로를 조회해 커널이 보는 그대로 출력하며 실제 패킷은 보내지 않는다고 설명합니다.', NULL, NULL, NULL, '[{"title": "ip-route(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-route.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 408 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 408, 10, '기본 경로', '목적지와 무관하게 쓰는 **기본 경로** 를 가리키는 키워드입니다. 빈칸을 채우세요.', '"기본" 이라는 이름이에요.', NULL, NULL, '[]', 'fill', '["default", "any", "all", "main"]', NULL, 'default 는 IPv4 의 0/0, IPv6 의 ::/0 과 같은 특수 prefix 입니다.', '[0]', 'ip route add {0} via 192.168.1.1', NULL, '[{"title": "ip-route(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-route.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 408 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 408, 11, 'onlink', '넥스트홉이 어떤 인터페이스 prefix 에도 속하지 않아도 **링크에 직접 연결된 것으로 간주** 하게 하는 옵션입니다. 빈칸을 채우세요.', '링크 위에 있다는 뜻이에요.', NULL, NULL, '[]', 'fill', '["onlink", "weight", "proto", "scope"]', NULL, 'onlink 는 넥스트홉이 인터페이스 prefix 에 속하지 않아도 그 링크에 직접 연결되어 있다고 간주하게 합니다.', '[0]', 'ip route add 10.1.0.0/16 via 192.168.9.1 dev eth0 {0}', NULL, '[{"title": "ip-route(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-route.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 408 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 408, 12, '정적 경로 추가와 확인', '정적 경로를 추가하고 확인하는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '추가 → 목록 → 조회예요.', NULL, NULL, '[]', 'order', '["`ip route add` 로 목적지와 via 를 지정해 경로를 추가한다", "`ip route show` 로 경로가 테이블에 들어갔는지 본다", "`ip route get` 으로 대상 주소가 실제로 어느 경로를 타는지 조회한다"]', NULL, '문서의 add·show·get 명령을 이은 일반 절차입니다.', '[0, 1, 2]', NULL, NULL, '[{"title": "ip-route(8) man page", "url": "https://man7.org/linux/man-pages/man8/ip-route.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 408 AND order_index = 12);

-- 배치: 단원 끝 (분할 마이그레이션 뒤에 적용되도록 2026-11-13 이름을 쓴다)
UPDATE quest_set SET display_order = 635 WHERE id = 117;
UPDATE quest_set SET display_order = 631, unit_id = (SELECT id FROM unit WHERE id = 47), icon = '🗺️' WHERE id = 408;
