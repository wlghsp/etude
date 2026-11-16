-- 퀴즈 세트 428. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_linux_round_b.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 428, 'strace 로 시스템 호출 보기: -f, -c, -T, -tt, -s, -y, -e trace=%file', 'strace 출력과 옵션을 읽습니다. 호출 이름·인자·반환값이 표준 에러로 나오는 점, -f 로 자식 따라가기, -c 요약, -T 소요 시간, -tt 시각, -s 기본 32, -y 경로, -e trace=%file, 추적의 느려짐, -1 ENOENT 읽기를 봅니다.', 'quiz', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 428);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 428, 1, '기본 동작', '`strace` 는 기본으로 무엇을 어디에 출력할까요?', '호출 이름, 인자, 반환값이에요.', NULL, NULL, '[]', 'choice', '["프로세스의 CPU 사용량을 표준 출력에 출력", "네트워크 패킷의 내용을 파일에 저장", "호출의 이름·인자·반환값을 표준 에러에 출력", "함수 호출 그래프를 화면에 그림"]', 2, 'strace 문서는 시스템 호출의 이름, 인자, 반환값을 표준 에러 또는 -o 로 지정한 파일에 출력한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "strace(1) man page", "url": "https://man7.org/linux/man-pages/man1/strace.1.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 428 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 428, 2, '-f 옵션', '`strace -f` 는 무엇을 할까요?', '자식이 생길 때예요.', NULL, NULL, '[]', 'choice', '["요약 통계만 출력한다", "fork 로 생기는 자식도 따라간다", "파일 호출만 걸러서 보여 준다", "실행 중인 프로세스에 붙는다"]', 1, 'strace 문서는 -f 가 fork, vfork, clone 으로 생성되는 자식 프로세스를 따라간다고 설명합니다.', NULL, NULL, NULL, '[{"title": "strace(1) man page", "url": "https://man7.org/linux/man-pages/man1/strace.1.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 428 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 428, 3, '-c 옵션', '`strace -c` 의 출력은 무엇일까요?', '집계예요.', NULL, NULL, '[]', 'choice', '["호출별 시간·횟수를 요약, 일반 출력 억제", "호출마다 소요 시간을 괄호로 덧붙임", "호출마다 벽시계 시간을 앞에 붙임", "파일 디스크립터의 경로를 덧붙임"]', 0, 'strace 문서는 -c 가 호출별 시간·횟수·에러를 집계해 종료 시 요약하고 일반 출력은 억제한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "strace(1) man page", "url": "https://man7.org/linux/man-pages/man1/strace.1.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 428 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 428, 4, '-T 옵션', '`strace -T` 는 무엇을 덧붙일까요?', '시간이에요.', NULL, NULL, '[]', 'choice', '["각 호출이 일어난 벽시계 시각", "각 호출의 호출 횟수", "각 호출의 메모리 사용량", "호출의 소요 시간"]', 3, 'strace 문서는 -T 가 시스템 호출의 시작과 끝 사이 시간 차이를 기록한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "strace(1) man page", "url": "https://man7.org/linux/man-pages/man1/strace.1.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 428 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 428, 5, '-tt 옵션', '`strace -tt` 는 무엇을 덧붙일까요?', '시각이에요.', NULL, NULL, '[]', 'choice', '["호출별 소요 시간", "프로세스 시작 이후 경과 초", "마이크로초 정밀도의 벽시계 시각", "시스템 부팅 이후 틱 수"]', 2, 'strace 문서는 -tt 가 벽시계 시간을 마이크로초 정밀도로 출력한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "strace(1) man page", "url": "https://man7.org/linux/man-pages/man1/strace.1.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 428 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 428, 6, '-s 기본값', '`strace -s` 의 문자열 출력 길이 **기본값** 은 얼마일까요?', '32 예요.', NULL, NULL, '[]', 'choice', '["8", "32", "256", "1024"]', 1, 'strace 문서는 -s 의 문자열 길이 기본값이 32 이며 파일명은 길이 제한 대상이 아니라고 설명합니다.', NULL, NULL, NULL, '[{"title": "strace(1) man page", "url": "https://man7.org/linux/man-pages/man1/strace.1.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 428 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 428, 7, '-y 옵션', '`strace -y` 는 무엇을 출력할까요?', '파일 디스크립터와 관련 있어요.', NULL, NULL, '[]', 'choice', '["파일 디스크립터 인자와 연관된 경로", "시스템 호출의 호출 횟수", "자식 프로세스의 PID", "호출한 함수의 소스 위치"]', 0, 'strace 문서는 -y 가 파일 디스크립터 인자와 연관된 경로를 출력한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "strace(1) man page", "url": "https://man7.org/linux/man-pages/man1/strace.1.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 428 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 428, 8, '추적의 비용', '`strace` 로 추적하는 프로세스는 어떻게 될까요?', '비용이 있어요.', NULL, NULL, '[]', 'choice', '["성능이 전혀 달라지지 않는다", "추적 중에는 항상 더 빨라진다", "추적 대상은 읽기 전용으로 바뀐다", "추적되지 않을 때보다 느려진다"]', 3, 'strace 문서는 추적되는 프로세스가 추적되지 않을 때보다 느리며 --seccomp-bpf 로 영향을 줄일 수 있다고 설명합니다.', NULL, NULL, NULL, '[{"title": "strace(1) man page", "url": "https://man7.org/linux/man-pages/man1/strace.1.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 428 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 428, 9, '에러 표시', '`open("/foo/bar", O_RDONLY) = -1 ENOENT (No such file or directory)` 가 뜻하는 것은 무엇일까요?', '반환값이 -1 이에요.', NULL, NULL, '[]', 'choice', '["호출이 성공했고 파일을 열었다", "권한이 없어 거부되었다", "호출이 실패했고 파일이 없다는 오류", "호출이 시간 초과되었다"]', 2, 'strace 문서의 예시는 open("/foo/bar", O_RDONLY) = -1 ENOENT (No such file or directory) 형태로 실패한 호출을 보여 줍니다.', NULL, NULL, NULL, '[{"title": "strace(1) man page", "url": "https://man7.org/linux/man-pages/man1/strace.1.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 428 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 428, 10, '파일 호출만', '파일명을 인자로 받는 **시스템 호출을 모두** 추적하는 필터입니다. 빈칸을 채우세요.', '% 로 시작해요.', NULL, NULL, '[]', 'fill', '["%file", "%network", "%process", "%memory"]', NULL, '-e trace=%file 은 파일명을 인자로 받는 시스템 호출을 모두 추적하는 축약형입니다. % 없는 file 표기는 deprecated 입니다.', '[0]', 'strace -e trace={0} cat /etc/hosts', NULL, '[{"title": "strace(1) man page", "url": "https://man7.org/linux/man-pages/man1/strace.1.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 428 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 428, 11, '자식 따라가기', '**자식 프로세스까지** 따라가는 옵션입니다. 빈칸을 채우세요.', '"fork" 의 f 예요.', NULL, NULL, '[]', 'fill', '["-f", "-c", "-T", "-y"]', NULL, '-f 는 fork, vfork, clone 으로 생성되는 자식 프로세스를 따라갑니다.', '[0]', 'strace {0} -o trace.log ./run.sh', NULL, '[{"title": "strace(1) man page", "url": "https://man7.org/linux/man-pages/man1/strace.1.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 428 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 428, 12, 'strace 로 실패 찾기', 'strace 로 실패 원인을 찾는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '실행 → 오류 찾기 → 좁히기 → 요약이에요.', NULL, NULL, '[]', 'order', '["`strace -f -o trace.log` 로 명령을 실행해 호출을 기록한다", "기록에서 `= -1 ENOENT` 처럼 실패한 호출을 찾는다", "`-e trace=%file` 로 파일 호출만 좁혀 다시 본다", "`-c` 로 호출별 시간·횟수를 요약한다"]', NULL, '문서의 옵션 설명을 이은 일반 절차입니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "strace(1) man page", "url": "https://man7.org/linux/man-pages/man1/strace.1.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 428 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 111, unit_id = (SELECT id FROM unit WHERE id = 4), icon = '🧫' WHERE id = 428;
