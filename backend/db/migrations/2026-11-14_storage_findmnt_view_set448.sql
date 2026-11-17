-- 퀴즈 세트 448. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_storage_round8.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 448, 'findmnt 로 마운트 살펴보기: 트리 출력, -s·-T·-R, --output, --verify', '마운트 조회 도구를 읽습니다. 기본 트리 출력과 스크립트 주의, fstab 검색(-s), 경로의 파일시스템(-T), 하위 마운트(-R), df 형식(-D), 열 지정(-o), 유형 제한(-t), 검증(-x), 변화 감시(-p)를 봅니다.', 'quiz', '스토리지'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 448);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 448, 1, 'findmnt 역할', 'findmnt 는 무엇을 할까요?', '찾는 도구예요.', NULL, NULL, '[]', 'choice', '["파일시스템을 새로 만든다", "fstab 을 자동으로 고쳐 준다", "마운트된 파일시스템을 나열하거나 검색한다", "블록 장치를 파티션으로 나눈다"]', 2, 'findmnt 문서는 마운트된 모든 파일시스템을 나열하거나 검색하며 /etc/fstab, /etc/mtab, /proc/self/mountinfo 에서 찾을 수 있다고 설명합니다.', NULL, NULL, NULL, '[{"title": "findmnt(8) man page", "url": "https://man7.org/linux/man-pages/man8/findmnt.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 448 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 448, 2, '기본 출력', '인자 없이 `findmnt` 를 실행하면 어떤 모양으로 나올까요?', '가지가 있어요.', NULL, NULL, '[]', 'choice', '["fstab 항목만 표로 나온다", "마운트된 파일시스템이 트리 형태로 나온다", "key=\\"value\\" 쌍으로 나온다", "JSON 형식으로 나온다"]', 1, '문서는 기본적으로 마운트된 모든 파일시스템을 트리 형태로 출력한다고 설명합니다. 표 형식은 -l, JSON 은 -J 입니다.', NULL, NULL, NULL, '[{"title": "findmnt(8) man page", "url": "https://man7.org/linux/man-pages/man8/findmnt.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 448 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 448, 3, '스크립트 주의', '스크립트에서 findmnt 를 쓸 때 문서가 **권하는 방법** 은 무엇일까요?', '열을 직접 정해요.', NULL, NULL, '[]', 'choice', '["--output 으로 열을 명시한다", "기본 출력은 고정이라 그대로 파싱해도 안전하다", "항상 -a 로 ASCII 출력만 쓴다", "열 이름 대신 열 번호로 자른다"]', 0, '문서는 기본 출력이 바뀔 수 있으므로 안정적인 출력이 필요하면 항상 --output 으로 예상 열을 명시하라고 설명합니다.', NULL, NULL, NULL, '[{"title": "findmnt(8) man page", "url": "https://man7.org/linux/man-pages/man8/findmnt.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 448 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 448, 4, '-s 옵션', '`findmnt -s` 는 어디에서 찾을까요?', '파일 하나예요.', NULL, NULL, '[]', 'choice', '["/proc/self/mountinfo", "/etc/mtab", "/var/log/messages", "/etc/fstab"]', 3, '문서는 -s/--fstab 이 /etc/fstab 에서 검색하며 출력은 list 형식이라고 설명합니다. 기본은 커널(mountinfo), -m 은 /etc/mtab 입니다.', NULL, NULL, NULL, '[{"title": "findmnt(8) man page", "url": "https://man7.org/linux/man-pages/man8/findmnt.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 448 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 448, 5, '-T 옵션', '`findmnt -T /var/log/app.log` 처럼 **일반 경로** 를 주면 무엇을 보여 줄까요?', '경로가 속한 곳이에요.', NULL, NULL, '[]', 'choice', '["그 경로를 새로 마운트한 결과", "그 경로 아래의 모든 하위 마운트", "그 경로가 속한 파일시스템 하나", "마운트 지점일 때만 결과가 나온다"]', 2, '문서는 --target 이 마운트 지점이 아닌 경로면 경로 요소를 거꾸로 확인해 마운트 지점을 찾고, 경로는 한 파일시스템에만 속하므로 항상 최대 하나만 돌려준다고 설명합니다.', NULL, NULL, NULL, '[{"title": "findmnt(8) man page", "url": "https://man7.org/linux/man-pages/man8/findmnt.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 448 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 448, 6, '-R 옵션', '`findmnt -R /mnt` 는 무엇을 더 보여 줄까요?', '아래쪽이에요.', NULL, NULL, '[]', 'choice', '["읽기 전용으로 마운트된 항목만", "선택한 파일시스템의 모든 하위 마운트", "위쪽 부모 마운트들", "가려진 마운트를 제외한 결과"]', 1, '문서는 -R/--submounts 가 선택된 파일시스템의 모든 하위 마운트를 재귀적으로 출력하며 트리 형식이 기본이라고 설명합니다.', NULL, NULL, NULL, '[{"title": "findmnt(8) man page", "url": "https://man7.org/linux/man-pages/man8/findmnt.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 448 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 448, 7, '-D 옵션', '`findmnt -D` 는 어떤 출력을 흉내 낼까요?', '용량을 봐요.', NULL, NULL, '[]', 'choice', '["df 명령의 출력", "du 명령의 출력", "dump 명령의 출력", "lsblk 명령의 출력"]', 0, '문서는 -D/--df 가 df(1) 출력을 흉내 내고 의사 파일시스템은 제외한다고 설명합니다. 모두 보려면 --all 을 씁니다.', NULL, NULL, NULL, '[{"title": "findmnt(8) man page", "url": "https://man7.org/linux/man-pages/man8/findmnt.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 448 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 448, 8, '-x 옵션', '`findmnt -x` 는 무엇을 할까요?', '확인이에요.', NULL, NULL, '[]', 'choice', '["fstab 의 오류를 찾아 자동으로 고친다", "모든 항목을 실제로 마운트해 보고 해제한다", "마운트 옵션을 확장해서 전부 보여 준다", "fstab 같은 마운트 테이블을 검증한다"]', 3, '문서는 -x/--verify 가 마운트 테이블 내용을 검증하며 기본은 /etc/fstab 의 해석 가능성과 사용 가능성이라고 설명합니다. --verbose 로 자세히 볼 수 있습니다.', NULL, NULL, NULL, '[{"title": "findmnt(8) man page", "url": "https://man7.org/linux/man-pages/man8/findmnt.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 448 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 448, 9, '-p 옵션', '`findmnt -p` 는 무엇을 감시할까요?', '변화를 봐요.', NULL, NULL, '[]', 'choice', '["파일시스템 사용량의 급격한 증가", "블록 장치의 읽기·쓰기 오류", "mountinfo 의 마운트 관련 변화", "fstab 파일의 마지막 수정 시각"]', 2, '문서는 -p/--poll 이 /proc/self/mountinfo 변화를 감시하며 지원 동작은 mount, umount, remount, move 이고 기본은 모두 감시한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "findmnt(8) man page", "url": "https://man7.org/linux/man-pages/man8/findmnt.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 448 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 448, 10, '열 지정', '출력 **열을 직접 정하는** 옵션입니다. 빈칸을 채우세요.', 'output 의 o 예요.', NULL, NULL, '[]', 'fill', '["-o", "-O", "-t", "-T"]', NULL, '-o/--output 은 출력 열을 정합니다. -O 는 마운트 옵션으로, -t 는 유형으로, -T 는 대상 경로로 제한합니다.', '[0]', 'findmnt {0} TARGET,SOURCE,FSTYPE', NULL, '[{"title": "findmnt(8) man page", "url": "https://man7.org/linux/man-pages/man8/findmnt.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 448 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 448, 11, '유형 제한', '출력을 **파일시스템 유형** 으로 제한하는 옵션입니다. 빈칸을 채우세요.', 'types 의 t 예요.', NULL, NULL, '[]', 'fill', '["-t", "-T", "-O", "-S"]', NULL, '-t/--types 는 쉼표로 구분한 파일시스템 유형으로 출력을 제한합니다. no 를 앞에 붙이면 해당 유형을 제외합니다.', '[0]', 'findmnt {0} xfs', NULL, '[{"title": "findmnt(8) man page", "url": "https://man7.org/linux/man-pages/man8/findmnt.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 448 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 448, 12, '마운트 확인', '마운트 상태를 살펴보는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '전체 → 경로 → 열 → 검증이에요.', NULL, NULL, '[]', 'order', '["`findmnt` 로 전체 마운트 트리를 본다", "`findmnt -T 경로` 로 특정 경로의 파일시스템을 확인한다", "`-o` 로 필요한 열만 골라 출력한다", "`findmnt -x` 로 fstab 을 검증한다"]', NULL, '문서의 기본 트리 출력, --target, --output, --verify 설명을 이은 일반 절차입니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "findmnt(8) man page", "url": "https://man7.org/linux/man-pages/man8/findmnt.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 448 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 636, unit_id = (SELECT id FROM unit WHERE id = 21), icon = '🌳' WHERE id = 448;
