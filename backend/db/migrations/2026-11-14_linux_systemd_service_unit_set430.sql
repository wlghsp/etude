-- 퀴즈 세트 430. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_linux_round_c.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 430, 'systemd 서비스 유닛 읽기: Type, Restart, ExecStart, TimeoutStartSec', '서비스 유닛 설정을 읽습니다. Type 생략 시 기본(simple·dbus·oneshot), Restart 기본 no 와 값들, RestartSec 100ms, ExecStart 는 oneshot 외에는 하나, ExecStartPre 여러 줄, oneshot 의 타임아웃 비활성, RemainAfterExit, - 접두사를 봅니다.', 'quiz', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 430);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 430, 1, 'Type 기본값', '`Type=` 을 **생략** 하고 `ExecStart=` 만 있으면 기본 타입은 무엇일까요?', '가장 단순한 타입이에요.', NULL, NULL, '[]', 'choice', '["forking", "oneshot", "simple", "notify"]', 2, 'systemd.service 문서는 Type 을 생략하면 ExecStart 만 있을 때 simple, BusName 이 있으면 dbus, ExecStart 가 없으면 oneshot 이라고 설명합니다.', NULL, NULL, NULL, '[{"title": "systemd.service(5) man page", "url": "https://man7.org/linux/man-pages/man5/systemd.service.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 430 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 430, 2, 'Type 기본 규칙', 'ExecStart 가 **없을** 때 Type 의 기본값은 무엇일까요?', '한 번 실행하고 끝나는 쪽이에요.', NULL, NULL, '[]', 'choice', '["simple", "oneshot", "forking", "idle"]', 1, '문서는 Type 을 생략했을 때 ExecStart 가 없으면 oneshot 이라고 설명합니다.', NULL, NULL, NULL, '[{"title": "systemd.service(5) man page", "url": "https://man7.org/linux/man-pages/man5/systemd.service.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 430 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 430, 3, 'Restart 기본', '`Restart=` 의 **기본값** 은 무엇일까요?', '자동 재시작은 기본이 아니에요.', NULL, NULL, '[]', 'choice', '["no", "on-failure", "always", "on-abnormal"]', 0, '문서는 Restart 의 값이 no, on-success, on-failure, on-abnormal, on-watchdog, on-abort, always 이며 기본값이 no 라고 설명합니다.', NULL, NULL, NULL, '[{"title": "systemd.service(5) man page", "url": "https://man7.org/linux/man-pages/man5/systemd.service.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 430 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 430, 4, 'RestartSec 기본', '`RestartSec=` 의 **기본값** 은 얼마일까요?', '아주 짧아요.', NULL, NULL, '[]', 'choice', '["1000ms", "10000ms", "60000ms", "100ms"]', 3, '문서는 RestartSec 의 기본값이 100ms 라고 설명합니다.', NULL, NULL, NULL, '[{"title": "systemd.service(5) man page", "url": "https://man7.org/linux/man-pages/man5/systemd.service.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 430 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 430, 5, 'ExecStart 개수', 'oneshot 이 **아닌** 서비스의 `ExecStart=` 는 몇 개일 수 있을까요?', '하나뿐이에요.', NULL, NULL, '[]', 'choice', '["여러 개까지", "하나도 없어도 된다", "정확히 하나", "최대 둘"]', 2, '문서는 oneshot 이 아니면 ExecStart 명령이 정확히 하나여야 하며 빈 문자열을 대입하면 목록이 초기화된다고 설명합니다.', NULL, NULL, NULL, '[{"title": "systemd.service(5) man page", "url": "https://man7.org/linux/man-pages/man5/systemd.service.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 430 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 430, 6, 'ExecStartPre', '`ExecStartPre=` 에 대한 설명으로 맞는 것은 무엇일까요?', '여러 줄이 돼요.', NULL, NULL, '[]', 'choice', '["ExecStart 와 같이 하나만 둘 수 있다", "여러 줄 가능, 순서대로 실행", "oneshot 에서만 쓸 수 있다", "실행 순서가 정해지지 않는다"]', 1, '문서는 ExecStartPre 와 ExecStartPost 가 Type 과 관계없이 여러 줄을 허용하고 순서대로 실행된다고 설명합니다.', NULL, NULL, NULL, '[{"title": "systemd.service(5) man page", "url": "https://man7.org/linux/man-pages/man5/systemd.service.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 430 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 430, 7, 'oneshot 타임아웃', '`TimeoutStartSec=` 의 oneshot 서비스 **기본 동작** 은 무엇일까요?', '예외가 있어요.', NULL, NULL, '[]', 'choice', '["타임아웃이 기본으로 비활성화된다", "DefaultTimeoutStartSec 가 그대로 적용된다", "항상 0초로 즉시 실패한다", "10분으로 고정된다"]', 0, '문서는 TimeoutStartSec 의 기본값이 매니저의 DefaultTimeoutStartSec 이지만 oneshot 은 기본적으로 타임아웃이 비활성화된다고 설명합니다.', NULL, NULL, NULL, '[{"title": "systemd.service(5) man page", "url": "https://man7.org/linux/man-pages/man5/systemd.service.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 430 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 430, 8, 'RemainAfterExit', '`RemainAfterExit=` 의 **기본값** 은 무엇일까요?', '프로세스가 끝나면 어떻게 되는지예요.', NULL, NULL, '[]', 'choice', '["yes", "Type 에 따라 항상 yes", "Restart 값과 같다", "no"]', 3, '문서는 RemainAfterExit 가 불리언이며 기본값이 no 라고 설명합니다.', NULL, NULL, NULL, '[{"title": "systemd.service(5) man page", "url": "https://man7.org/linux/man-pages/man5/systemd.service.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 430 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 430, 9, '- 접두사', '명령 앞의 `-` 접두사는 무엇을 뜻할까요?', '종료 코드에 대한 처리예요.', NULL, NULL, '[]', 'choice', '["명령 실행을 건너뛴다", "실패하면 서비스를 재시작한다", "실패해도 성공처럼 처리", "출력을 저널에 남기지 않는다"]', 2, '문서는 - 접두사가 실패 종료 코드를 기록하지만 성공과 동등하게 처리한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "systemd.service(5) man page", "url": "https://man7.org/linux/man-pages/man5/systemd.service.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 430 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 430, 10, '항상 재시작', '종료 상태와 관계없이 **항상 재시작** 하는 `Restart=` 값입니다. 빈칸을 채우세요.', '"언제나" 예요.', NULL, NULL, '[]', 'fill', '["always", "on-failure", "on-success", "no"]', NULL, 'always 는 종료 상태와 관계없이 재시작합니다. 기본값은 no 입니다.', '[0]', '[Service]
Restart={0}', NULL, '[{"title": "systemd.service(5) man page", "url": "https://man7.org/linux/man-pages/man5/systemd.service.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 430 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 430, 11, '실패 무시', '`ExecStartPre` 명령이 실패해도 **성공처럼** 처리하게 하는 접두사입니다. 빈칸을 채우세요.', '"빼기" 기호예요.', NULL, NULL, '[]', 'fill', '["-", "@", "+", "!"]', NULL, '- 접두사는 실패 종료 코드를 기록하지만 성공과 동등하게 처리합니다. @ 는 argv[0] 지정입니다.', '[0]', 'ExecStartPre={0}/usr/bin/test -f /etc/foo.conf', NULL, '[{"title": "systemd.service(5) man page", "url": "https://man7.org/linux/man-pages/man5/systemd.service.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 430 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 430, 12, '서비스 유닛 쓰기', '서비스 유닛을 쓰는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '타입 → 실행 → 재시작 → 확인이에요.', NULL, NULL, '[]', 'order', '["`Type=` 으로 서비스 종류를 정한다", "`ExecStart=` 로 실행할 명령을 정한다", "`Restart=` 와 `RestartSec=` 로 재시작 방식을 정한다", "유닛을 시작해 상태를 확인한다"]', NULL, '문서의 Type·ExecStart·Restart 설명을 이은 일반 절차입니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "systemd.service(5) man page", "url": "https://man7.org/linux/man-pages/man5/systemd.service.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 430 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 113, unit_id = (SELECT id FROM unit WHERE id = 4), icon = '🛎️' WHERE id = 430;
