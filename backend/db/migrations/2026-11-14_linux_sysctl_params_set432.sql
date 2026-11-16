-- 퀴즈 세트 432. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_linux_round_d.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 432, 'sysctl 로 커널 매개변수 다루기: -a·-w·-p, --system 디렉터리 순서, 파일 정렬', '커널 매개변수 도구를 읽습니다. -a 가 deprecated 를 제외하는 점, -p 기본 파일, --system 이 읽는 디렉터리 순서와 /etc/sysctl.conf 마지막, 사전식 정렬과 같은 이름 파일 무시, -n·-e·-N·-r 옵션을 봅니다.', 'quiz', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 432);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 432, 1, 'sysctl -a', '`sysctl -a` 는 무엇을 보여 줄까요?', '모든 변수예요.', NULL, NULL, '[]', 'choice', '["/etc/sysctl.conf 에 적힌 값만", "바뀐 값만", "모든 값(deprecated 제외)", "쓰기 가능한 값만"]', 2, 'sysctl 문서는 -a 가 사용 가능한 모든 값을 보여 주되 deprecated 와 verboten 매개변수는 제외한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "sysctl(8) man page", "url": "https://man7.org/linux/man-pages/man8/sysctl.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 432 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 432, 2, '-p 기본 파일', '`sysctl -p` 를 파일 없이 실행하면 **어느 파일** 을 읽을까요?', '기본 설정 파일이에요.', NULL, NULL, '[]', 'choice', '["/etc/sysctl.d/99-sysctl.conf", "/etc/sysctl.conf", "/proc/sys/kernel/sysctl", "/lib/sysctl.d/default.conf"]', 1, 'sysctl 문서는 -p 가 파일을 지정하지 않으면 /etc/sysctl.conf 를 읽고 - 는 표준 입력을 뜻한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "sysctl(8) man page", "url": "https://man7.org/linux/man-pages/man8/sysctl.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 432 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 432, 3, '--system 순서', '`sysctl --system` 이 **처음** 읽는 디렉터리는 무엇일까요?', '/etc 가 먼저예요.', NULL, NULL, '[]', 'choice', '["/etc/sysctl.d/", "/lib/sysctl.d/", "/usr/lib/sysctl.d/", "/run/sysctl.d/"]', 0, '문서는 --system 이 /etc/sysctl.d/, /run/sysctl.d/, /usr/local/lib/sysctl.d/, /usr/lib/sysctl.d/, /lib/sysctl.d/ 의 *.conf 를 순서대로 읽고 /etc/sysctl.conf 는 마지막에 읽는다고 설명합니다.', NULL, NULL, NULL, '[{"title": "sysctl(8) man page", "url": "https://man7.org/linux/man-pages/man8/sysctl.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 432 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 432, 4, 'sysctl.conf 순서', '`--system` 에서 `/etc/sysctl.conf` 는 **언제** 읽힐까요?', '가장 마지막이에요.', NULL, NULL, '[]', 'choice', '["가장 먼저 읽혀 다른 설정에 덮어쓰인다", "읽히지 않는다", "다른 디렉터리와 번갈아 읽힌다", "마지막에 읽혀 덮어쓴다"]', 3, '문서는 /etc/sysctl.conf 가 마지막에 읽혀 앞선 설정을 덮어쓸 수 있다고 설명합니다.', NULL, NULL, NULL, '[{"title": "sysctl(8) man page", "url": "https://man7.org/linux/man-pages/man8/sysctl.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 432 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 432, 5, '파일 정렬', '여러 디렉터리의 설정 파일은 어떻게 **정렬** 될까요?', '이름순이에요.', NULL, NULL, '[]', 'choice', '["디렉터리 순서대로만", "수정 시각이 최근인 순서", "디렉터리와 관계없이 사전식 순서", "파일 크기가 작은 순서"]', 2, '문서는 모든 설정 파일이 디렉터리와 관계없이 사전식(lexicographic) 순서로 정렬된다고 설명합니다.', NULL, NULL, NULL, '[{"title": "sysctl(8) man page", "url": "https://man7.org/linux/man-pages/man8/sysctl.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 432 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 432, 6, '같은 이름 파일', '우선순위가 높은 디렉터리에 **같은 이름의 파일** 이 있으면 낮은 디렉터리의 그 파일은 어떻게 될까요?', '가려져요.', NULL, NULL, '[]', 'choice', '["둘 다 읽혀 병합된다", "무시된다", "뒤에 읽은 것이 덮어쓴다", "오류로 중단된다"]', 1, '문서는 우선순위가 높은 디렉터리에 같은 이름의 파일이 있으면 낮은 디렉터리의 같은 이름 파일은 무시된다고 설명합니다.', NULL, NULL, NULL, '[{"title": "sysctl(8) man page", "url": "https://man7.org/linux/man-pages/man8/sysctl.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 432 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 432, 7, '-n 옵션', '`sysctl -n` 은 무엇을 할까요?', '이름을 끄는 쪽이에요.', NULL, NULL, '[]', 'choice', '["값을 출력할 때 키 이름 출력을 끈다", "값을 바꾸지 않고 시험만 한다", "키 이름만 출력한다", "알 수 없는 키의 오류를 무시한다"]', 0, '문서는 -n 이 값을 출력할 때 키 이름 출력을 끈다고 설명합니다. 이름만 보려면 -N 입니다.', NULL, NULL, NULL, '[{"title": "sysctl(8) man page", "url": "https://man7.org/linux/man-pages/man8/sysctl.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 432 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 432, 8, '-e 옵션', '`sysctl -e` 는 무엇을 할까요?', '알 수 없는 키예요.', NULL, NULL, '[]', 'choice', '["값을 쓰지 않고 시험만 한다", "키 이름만 출력한다", "파일의 오류를 모두 중단한다", "알 수 없는 키의 오류를 무시한다"]', 3, '문서는 -e 가 알 수 없는 키 오류를 무시한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "sysctl(8) man page", "url": "https://man7.org/linux/man-pages/man8/sysctl.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 432 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 432, 9, '-r 패턴', '`sysctl -r` 의 **패턴** 은 어떤 문법일까요?', '정규표현식이에요.', NULL, NULL, '[]', 'choice', '["셸 글롭 패턴", "고정 문자열", "확장 정규표현식", "와일드카드 * 만"]', 2, '문서는 -r/--pattern 이 패턴에 맞는 설정만 적용하며 패턴이 확장 정규표현식 문법을 쓴다고 설명합니다.', NULL, NULL, NULL, '[{"title": "sysctl(8) man page", "url": "https://man7.org/linux/man-pages/man8/sysctl.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 432 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 432, 10, '값만 출력', '변수 값을 **키 이름 없이** 출력하는 옵션입니다. 빈칸을 채우세요.', '소문자 n 이에요.', NULL, NULL, '[]', 'fill', '["-n", "-N", "-w", "-e"]', NULL, '-n 은 값 출력 시 키 이름을 끕니다. -N 은 이름만 표시합니다.', '[0]', 'sysctl {0} net.ipv4.ip_forward', NULL, '[{"title": "sysctl(8) man page", "url": "https://man7.org/linux/man-pages/man8/sysctl.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 432 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 432, 11, '파일에서 로드', '설정 **파일에서 값을 로드** 하는 옵션입니다. 빈칸을 채우세요.', '"파일" 의 p 가 아니에요. 로드를 뜻해요.', NULL, NULL, '[]', 'fill', '["-p", "-a", "-w", "-r"]', NULL, '-p 는 파일을 지정하지 않으면 /etc/sysctl.conf 를 읽습니다.', '[0]', 'sysctl {0} /etc/sysctl.conf', NULL, '[{"title": "sysctl(8) man page", "url": "https://man7.org/linux/man-pages/man8/sysctl.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 432 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 432, 12, '커널 값 바꾸기', '커널 매개변수를 바꾸고 설정 파일로 반영하는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '조회 → 변경 → 파일 → 로드예요.', NULL, NULL, '[]', 'order', '["`sysctl -n` 으로 현재 값을 조회한다", "`sysctl -w` 로 값을 바꾼다", "`/etc/sysctl.d/` 의 `*.conf` 파일에 값을 적는다", "`sysctl --system` 으로 설정 파일을 읽어 적용한다"]', NULL, '문서의 -w 와 --system 설명을 이은 일반 절차입니다. 재부팅 후 유지는 원문이 직접 설명하지 않습니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "sysctl(8) man page", "url": "https://man7.org/linux/man-pages/man8/sysctl.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 432 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 115, unit_id = (SELECT id FROM unit WHERE id = 4), icon = '🎚️' WHERE id = 432;
