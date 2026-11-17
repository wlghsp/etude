-- 퀴즈 세트 454. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_storage_round10.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 454, 'mkfs.xfs 로 XFS 만들기: 기본 사용, -f·-L·-N·-K, 할당 그룹, 외부 로그', 'XFS 생성 도구를 읽습니다. 크기를 드라이버에서 정하는 기본 사용, 외부 로그 예시, -f 덮어쓰기, -L 레이블 12자 제한, -N 미리 보기, -q·-K, 할당 그룹 개수와 병렬성을 봅니다.', 'quiz', '스토리지'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 454);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 454, 1, 'mkfs.xfs 역할', 'mkfs.xfs 는 무엇을 할까요?', '만들어요.', NULL, NULL, '[]', 'choice', '["마운트된 XFS 의 크기를 늘린다", "손상된 XFS 를 검사하고 고친다", "특수 파일에 XFS 파일시스템을 만든다", "XFS 레이블을 읽어서 보여 준다"]', 2, 'mkfs.xfs 문서는 명령행 인자 값을 써서 특수 파일에 XFS 파일시스템을 구성하며, mkfs 에 -t xfs 를 주면 자동으로 호출된다고 설명합니다.', NULL, NULL, NULL, '[{"title": "mkfs.xfs(8) man page", "url": "https://man7.org/linux/man-pages/man8/mkfs.xfs.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 454 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 454, 2, '기본 사용', '가장 단순한 `mkfs.xfs /dev/sda1` 에서 **크기** 는 어떻게 정해질까요?', '드라이버가 알려 줘요.', NULL, NULL, '[]', 'choice', '["항상 1GiB 로 고정되어 만들어진다", "디스크 드라이버가 알려 주는 크기로 정해진다", "직접 블록 수를 입력해야 정해진다", "파티션 테이블의 값을 읽어서 정해진다"]', 1, '문서는 가장 단순하고 흔한 형태에서 파일시스템 크기를 디스크 드라이버로부터 정한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "mkfs.xfs(8) man page", "url": "https://man7.org/linux/man-pages/man8/mkfs.xfs.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 454 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 454, 3, '외부 로그', '`-l logdev=/dev/sdb1,size=10m` 처럼 **로그를 다른 장치** 에 두는 이유로 문서가 드는 것은 무엇일까요?', '탐색이 줄어요.', NULL, NULL, '[]', 'choice', '["디스크 탐색(seek) 횟수를 줄이기 위해", "파일시스템 크기를 줄이기 위해", "데이터를 자동으로 암호화하기 위해", "레이블 길이 제한을 피하기 위해"]', 0, '문서는 메타데이터 로그를 다른 장치에 두어 디스크 seek 횟수를 줄일 수 있다고 설명하며 로그를 10MiB 로 두는 예시를 보여 줍니다.', NULL, NULL, NULL, '[{"title": "mkfs.xfs(8) man page", "url": "https://man7.org/linux/man-pages/man8/mkfs.xfs.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 454 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 454, 4, '-f 옵션', '`mkfs.xfs -f` 는 무엇을 허용할까요?', '덮어쓰기예요.', NULL, NULL, '[]', 'choice', '["레이블을 12자보다 길게 쓴다", "마운트된 상태에서 새로 만든다", "파일시스템 크기를 0 으로 둔다", "기존 파일시스템이 감지돼도 덮어쓴다"]', 3, '문서는 -f 가 장치에 기존 파일시스템이 감지돼도 강제로 덮어쓰며, 기본은 파일시스템이나 파티션 테이블이 있어 보이면 쓰지 않는다고 설명합니다.', NULL, NULL, NULL, '[{"title": "mkfs.xfs(8) man page", "url": "https://man7.org/linux/man-pages/man8/mkfs.xfs.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 454 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 454, 5, '-L 길이', 'XFS **레이블** 의 길이 제한과 초과 시 동작은 무엇일까요?', '12자예요.', NULL, NULL, '[]', 'choice', '["최대 16자이며 넘으면 잘라서 만든다", "최대 32자이며 넘으면 경고만 한다", "최대 12자이며 넘으면 만들지 않는다", "최대 64자이며 넘으면 UUID 로 바꾼다"]', 2, '문서는 XFS 레이블이 최대 12자이며 더 길면 mkfs.xfs 가 파일시스템 생성을 진행하지 않는다고 설명합니다.', NULL, NULL, NULL, '[{"title": "mkfs.xfs(8) man page", "url": "https://man7.org/linux/man-pages/man8/mkfs.xfs.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 454 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 454, 6, '-N 옵션', '`mkfs.xfs -N` 은 무엇을 할까요?', '미리 보기예요.', NULL, NULL, '[]', 'choice', '["만든 뒤 자동으로 검사까지 한다", "실제로 만들지 않고 파라미터만 출력한다", "출력 없이 조용히 만든다", "이름 옵션을 따로 지정한다"]', 1, '문서는 -N 이 파일시스템을 실제로 만들지 않고 파라미터만 출력한다고 설명합니다. 조용히 만드는 것은 -q 입니다.', NULL, NULL, NULL, '[{"title": "mkfs.xfs(8) man page", "url": "https://man7.org/linux/man-pages/man8/mkfs.xfs.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 454 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 454, 7, '-q 옵션', '`mkfs.xfs -q` 는 무엇을 억제할까요?', '출력이에요.', NULL, NULL, '[]', 'choice', '["만들 파일시스템의 파라미터 출력", "기존 파일시스템 감지 검사", "블록 discard 시도", "메타데이터 체크섬 기록"]', 0, '문서는 -q 가 기본으로 출력하는 만들 파일시스템의 파라미터를 출력하지 않게 한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "mkfs.xfs(8) man page", "url": "https://man7.org/linux/man-pages/man8/mkfs.xfs.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 454 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 454, 8, '-K 옵션', '`mkfs.xfs -K` 는 무엇을 하지 않을까요?', '버리기예요.', NULL, NULL, '[]', 'choice', '["만들 때 로그 영역을 만들지 않는다", "만들 때 레이블을 지정하지 않는다", "만들 때 기존 내용을 검사하지 않는다", "만들 때 블록 discard 를 시도하지 않는다"]', 3, '문서는 -K 가 mkfs 시점에 블록을 discard 하려고 시도하지 않게 한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "mkfs.xfs(8) man page", "url": "https://man7.org/linux/man-pages/man8/mkfs.xfs.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 454 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 454, 9, 'agcount', '`-d agcount` 로 정하는 **할당 그룹(AG)** 에 대해 맞는 것은 무엇일까요?', '병렬성이에요.', NULL, NULL, '[]', 'choice', '["AG 는 개수가 적을수록 항상 더 빠르다", "AG 하나의 크기는 정확히 1GiB 로 고정된다", "AG 가 많을수록 할당 병렬성이 높아질 수 있다", "AG 는 로그를 따로 두는 영역이다"]', 2, '문서는 데이터 영역을 할당 그룹으로 나누어 성능을 높이며 AG 가 많으면 병렬성이 높아지고, 기본값은 장치 크기에 따라 자동 조정된다고 설명합니다. AG 최소 16MiB, 최대 1TiB 미만입니다.', NULL, NULL, NULL, '[{"title": "mkfs.xfs(8) man page", "url": "https://man7.org/linux/man-pages/man8/mkfs.xfs.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 454 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 454, 10, '레이블 지정', 'XFS **레이블** 을 정하는 옵션입니다. 빈칸을 채우세요.', 'label 의 L 이에요.', NULL, NULL, '[]', 'fill', '["-L", "-l", "-d", "-N"]', NULL, '-L 은 레이블을 정합니다(최대 12자). 소문자 -l 은 로그 영역 옵션이고 -d 는 데이터 영역 옵션입니다.', '[0]', 'mkfs.xfs {0} data /dev/sdb1', NULL, '[{"title": "mkfs.xfs(8) man page", "url": "https://man7.org/linux/man-pages/man8/mkfs.xfs.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 454 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 454, 11, '미리 보기', '실제로 만들지 않고 **파라미터만 출력** 하는 옵션입니다. 빈칸을 채우세요.', 'No 의 N 이에요.', NULL, NULL, '[]', 'fill', '["-N", "-f", "-q", "-K"]', NULL, '-N 은 만들지 않고 파라미터만 출력합니다. -f 는 덮어쓰기, -q 는 출력 억제, -K 는 discard 생략입니다.', '[0]', 'mkfs.xfs {0} /dev/sdb1', NULL, '[{"title": "mkfs.xfs(8) man page", "url": "https://man7.org/linux/man-pages/man8/mkfs.xfs.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 454 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 454, 12, 'XFS 만들기', 'XFS 를 새로 만드는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '미리 보기 → 생성 → 확인 → 마운트예요.', NULL, NULL, '[]', 'order', '["`mkfs.xfs -N` 으로 파라미터를 미리 확인한다", "`mkfs.xfs -L` 로 레이블을 정해 만든다", "`blkid` 로 만들어진 파일시스템을 확인한다", "`mount` 로 마운트한다"]', NULL, '문서의 -N, -L 설명과 앞 라운드의 blkid·mount 를 이은 일반 절차입니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "mkfs.xfs(8) man page", "url": "https://man7.org/linux/man-pages/man8/mkfs.xfs.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 454 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 642, unit_id = (SELECT id FROM unit WHERE id = 21), icon = '⚙️' WHERE id = 454;
