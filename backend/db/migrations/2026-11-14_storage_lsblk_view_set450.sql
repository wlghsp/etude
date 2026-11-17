-- 퀴즈 세트 450. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_storage_round9.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 450, 'lsblk 로 블록 장치 보기: 트리 출력, -f 파일시스템, -d·-l·-s, --output', '블록 장치 조회 도구를 읽습니다. sysfs·udev 정보원, 기본 트리 출력과 스크립트 주의, -f 파일시스템 열, -d 하위 제외, -D discard, -l 목록, -p 경로, -s 역방향, -o 열 지정을 봅니다.', 'quiz', '스토리지'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 450);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 450, 1, 'lsblk 정보원', 'lsblk 는 장치 정보를 **어디에서** 모을까요?', '커널 정보와 udev 예요.', NULL, NULL, '[]', 'choice', '["/etc/fstab 과 /etc/mtab 파일", "/var/log 아래의 커널 로그", "sysfs 파일시스템과 udev 데이터베이스", "/boot 아래의 부트 설정"]', 2, 'lsblk 문서는 sysfs 와 udev db 에서 정보를 모으며, udev db 가 없으면 장치에서 직접 읽어야 해서 root 권한이 필요하다고 설명합니다.', NULL, NULL, NULL, '[{"title": "lsblk(8) man page", "url": "https://man7.org/linux/man-pages/man8/lsblk.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 450 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 450, 2, '기본 출력', '인자 없이 `lsblk` 를 실행하면 기본으로 무엇을 보여 줄까요?', '램 디스크는 빠져요.', NULL, NULL, '[]', 'choice', '["마운트된 장치만 표로 보여 준다", "모든 블록 장치를 트리로 보여 준다", "파티션 없는 디스크만 보여 준다", "fstab 에 적힌 장치만 보여 준다"]', 1, '문서는 기본적으로 RAM 디스크를 제외한 모든 블록 장치를 트리 형태로 출력한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "lsblk(8) man page", "url": "https://man7.org/linux/man-pages/man8/lsblk.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 450 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 450, 3, '스크립트 주의', '스크립트에서 lsblk 를 쓸 때 문서가 **권하는 방법** 은 무엇일까요?', '열을 직접 정해요.', NULL, NULL, '[]', 'choice', '["--output 으로 열을 직접 명시한다", "기본 출력은 고정이라 그대로 파싱해도 된다", "항상 -a 와 -b 를 함께 쓴다", "열 번호로 잘라서 파싱한다"]', 0, '문서는 기본 출력(--fs·--topology 포함)이 바뀔 수 있으므로 안정적인 출력이 필요하면 --output 으로 열을 명시하고 --list 를 쓰라고 설명합니다.', NULL, NULL, NULL, '[{"title": "lsblk(8) man page", "url": "https://man7.org/linux/man-pages/man8/lsblk.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 450 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 450, 4, '-f 옵션', '`lsblk -f` 는 무엇을 보여 줄까요?', '파일시스템 정보예요.', NULL, NULL, '[]', 'choice', '["장치의 읽기·쓰기 속도와 큐 길이", "장치의 소유자와 그룹과 모드", "장치의 TRIM 지원 여부", "유형·레이블·UUID·사용률·마운트"]', 3, '문서는 -f 가 NAME,FSTYPE,FSVER,LABEL,UUID,FSAVAIL,FSUSE%,MOUNTPOINTS 열과 같다고 설명하며, 파일시스템 정보의 기준은 blkid 라고 안내합니다.', NULL, NULL, NULL, '[{"title": "lsblk(8) man page", "url": "https://man7.org/linux/man-pages/man8/lsblk.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 450 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 450, 5, '-d 옵션', '`lsblk -d /dev/sda` 는 무엇을 보여 줄까요?', '아래 장치를 빼요.', NULL, NULL, '[]', 'choice', '["sda 의 삭제 가능 여부만 보여 준다", "sda 를 포함한 모든 디스크를 보여 준다", "sda 자체만 보여 주고 파티션 등 하위 장치는 뺀다", "sda 의 TRIM 정보를 보여 준다"]', 2, '문서는 -d/--nodeps 가 holder 장치나 slave 를 출력하지 않으며, lsblk --nodeps /dev/sda 가 sda 장치 정보만 출력한다고 설명합니다. TRIM 정보는 -D 입니다.', NULL, NULL, NULL, '[{"title": "lsblk(8) man page", "url": "https://man7.org/linux/man-pages/man8/lsblk.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 450 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 450, 6, '-D 옵션', '`lsblk -D` 는 무엇을 보여 줄까요?', '버리기 기능이에요.', NULL, NULL, '[]', 'choice', '["장치별 삭제 가능한 파티션 목록", "discard(TRIM) 기능 정보", "장치 의존 관계의 역순 목록", "장치 노드의 소유자와 모드"]', 1, '문서는 -D/--discard 가 장치마다 discard 기능(TRIM, UNMAP)에 대한 정보를 출력한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "lsblk(8) man page", "url": "https://man7.org/linux/man-pages/man8/lsblk.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 450 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 450, 7, '-l 옵션', '`lsblk -l` 의 출력은 어떻게 다를까요?', '가지가 없어요.', NULL, NULL, '[]', 'choice', '["목록으로 나오고 관계는 안 보인다", "트리가 더 깊게 확장되어 나온다", "JSON 형식으로 바뀌어 나온다", "파일시스템 열만 골라서 나온다"]', 0, '문서는 -l/--list 가 목록 형식으로 출력하며 장치 간 관계 정보는 없고, 2.34 버전부터 각 장치를 한 번씩만 출력한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "lsblk(8) man page", "url": "https://man7.org/linux/man-pages/man8/lsblk.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 450 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 450, 8, '-p 옵션', '`lsblk -p` 는 무엇을 출력할까요?', '경로예요.', NULL, NULL, '[]', 'choice', '["파티션 정보만", "상위 장치 경로만", "프로세스 번호", "전체 장치 경로"]', 3, '문서는 -p/--paths 가 전체 장치 경로를 출력한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "lsblk(8) man page", "url": "https://man7.org/linux/man-pages/man8/lsblk.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 450 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 450, 9, '-s 옵션', '`lsblk -s` 는 무엇을 바꿀까요?', '방향이 바뀌어요.', NULL, NULL, '[]', 'choice', '["출력 항목을 크기순으로 정렬한다", "출력을 SCSI 장치만으로 제한한다", "의존 관계를 거꾸로 출력한다", "크기를 바이트 단위로 보여 준다"]', 2, '문서는 -s/--inverse 가 의존 관계를 역순으로 출력한다고 설명합니다. SCSI 장치만은 -S, 바이트 단위는 -b 입니다.', NULL, NULL, NULL, '[{"title": "lsblk(8) man page", "url": "https://man7.org/linux/man-pages/man8/lsblk.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 450 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 450, 10, '열 지정', '출력 **열을 직접 정하는** 옵션입니다. 빈칸을 채우세요.', 'output 의 o 예요.', NULL, NULL, '[]', 'fill', '["-o", "-O", "-x", "-t"]', NULL, '-o/--output 은 출력 열을 정합니다. -O 는 가능한 모든 열, -x 는 정렬, -t 는 토폴로지 출력입니다.', '[0]', 'lsblk {0} NAME,SIZE,TYPE,MOUNTPOINTS', NULL, '[{"title": "lsblk(8) man page", "url": "https://man7.org/linux/man-pages/man8/lsblk.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 450 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 450, 11, '파일시스템 정보', '파일시스템 **유형·UUID·마운트 지점** 열을 한 번에 보는 옵션입니다. 빈칸을 채우세요.', 'filesystem 의 f 예요.', NULL, NULL, '[]', 'fill', '["-f", "-m", "-t", "-D"]', NULL, '-f 는 파일시스템 정보를, -m 은 소유자·그룹·모드를, -t 는 토폴로지를, -D 는 discard 정보를 보여 줍니다.', '[0]', 'lsblk {0}', NULL, '[{"title": "lsblk(8) man page", "url": "https://man7.org/linux/man-pages/man8/lsblk.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 450 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 450, 12, '장치 파악', '새로 붙은 디스크를 파악하는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '전체 → 파일시스템 → 마운트 → 정확히예요.', NULL, NULL, '[]', 'order', '["`lsblk` 로 전체 블록 장치 구조를 본다", "`lsblk -f` 로 파일시스템 유무와 UUID 를 확인한다", "`MOUNTPOINTS` 열로 마운트 여부를 확인한다", "확실한 정보는 `blkid` 로 다시 확인한다"]', NULL, '문서의 기본 트리 출력, -f 와 MOUNTPOINTS 열 설명, 파일시스템 정보의 기준이 blkid 라는 안내를 이은 일반 절차입니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "lsblk(8) man page", "url": "https://man7.org/linux/man-pages/man8/lsblk.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 450 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 638, unit_id = (SELECT id FROM unit WHERE id = 21), icon = '🔭' WHERE id = 450;
