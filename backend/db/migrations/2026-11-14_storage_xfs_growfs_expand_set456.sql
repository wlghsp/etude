-- 퀴즈 세트 456. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_storage_round10.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 456, 'xfs_growfs 로 XFS 늘리기: 마운트 필요, -d·-D, -n 미리 보기, 논리 볼륨', 'XFS 확장 도구를 읽습니다. 마운트된 상태에서 확장하는 점, 대상 인자, -d 최대 확장과 -D 의 블록 단위, -n 미리 보기, -m inode 비율, 구현되지 않은 -i, 논리 볼륨과 함께 쓰는 사용을 봅니다.', 'quiz', '스토리지'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 456);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 456, 1, 'xfs_growfs 역할', 'xfs_growfs 는 무엇을 할까요?', '늘려요.', NULL, NULL, '[]', 'choice', '["XFS 파일시스템을 새로 만든다", "손상된 XFS 파일시스템을 수리한다", "기존 XFS 파일시스템을 확장한다", "XFS 의 레이블과 UUID 를 바꾼다"]', 2, 'xfs_growfs 문서는 기존 XFS 파일시스템을 확장하며, 기존 내용은 그대로 두고 늘어난 공간을 새 파일 저장에 쓸 수 있게 한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "xfs_growfs(8) man page", "url": "https://man7.org/linux/man-pages/man8/xfs_growfs.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 456 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 456, 2, '마운트 필요', 'xfs_growfs 로 확장하려면 파일시스템이 **어떤 상태** 여야 할까요?', '올라와 있어야 해요.', NULL, NULL, '[]', 'choice', '["언마운트되어 있어야 한다", "마운트되어 있어야 한다", "읽기 전용으로 점검 중이어야 한다", "로그가 비어 있어야 한다"]', 1, '문서는 확장하려면 파일시스템이 마운트되어 있어야 한다고 설명합니다. 반대로 xfs_repair 는 언마운트가 필요합니다.', NULL, NULL, NULL, '[{"title": "xfs_growfs(8) man page", "url": "https://man7.org/linux/man-pages/man8/xfs_growfs.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 456 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 456, 3, '대상 인자', 'xfs_growfs 의 대상은 **무엇으로** 줄 수 있을까요?', '두 가지예요.', NULL, NULL, '[]', 'choice', '["마운트 지점 또는 장치 이름", "언마운트된 장치 이름만", "파일시스템 레이블만", "/etc/fstab 의 줄 번호"]', 0, '문서는 mount-point 인자가 마운트된 디렉터리 경로이고 block-device 인자가 마운트된 XFS 의 장치 이름이라고 설명합니다.', NULL, NULL, NULL, '[{"title": "xfs_growfs(8) man page", "url": "https://man7.org/linux/man-pages/man8/xfs_growfs.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 456 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 456, 4, '-d 옵션', '`xfs_growfs -d` 처럼 **-D 없이 -d** 만 주면 데이터 영역은 어떻게 될까요?', '최대예요.', NULL, NULL, '[]', 'choice', '["정확히 1GiB 만 늘어난다", "현재 크기가 그대로 유지된다", "절반 크기로 줄어든다", "가능한 가장 큰 크기까지 늘어난다"]', 3, '문서는 -D size 를 주면 그 크기로, 아니면 -d 가 데이터 영역을 가능한 최대 크기까지 키운다고 설명합니다.', NULL, NULL, NULL, '[{"title": "xfs_growfs(8) man page", "url": "https://man7.org/linux/man-pages/man8/xfs_growfs.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 456 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 456, 5, '-D 단위', '`xfs_growfs -D size` 의 **size 단위** 는 무엇일까요?', '파일시스템 단위예요.', NULL, NULL, '[]', 'choice', '["바이트 단위", "메가바이트 단위", "파일시스템 블록 단위", "디스크 섹터 단위"]', 2, '문서는 -D 의 size 를 파일시스템 블록 단위로 표현한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "xfs_growfs(8) man page", "url": "https://man7.org/linux/man-pages/man8/xfs_growfs.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 456 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 456, 6, '-n 옵션', '`xfs_growfs -n` 은 무엇을 할까요?', '확인만 해요.', NULL, NULL, '[]', 'choice', '["변경 없이 크기를 자동으로 줄인다", "변경 없이 형상만 출력한다", "확장한 뒤 결과를 출력하지 않는다", "로그 영역만 확장한다"]', 1, '문서는 -n 이 파일시스템을 바꾸지 않고 형상(geometry)을 출력하며 인자를 검사하지만 확장은 하지 않는다고 설명합니다.', NULL, NULL, NULL, '[{"title": "xfs_growfs(8) man page", "url": "https://man7.org/linux/man-pages/man8/xfs_growfs.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 456 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 456, 7, '-m 옵션', '`xfs_growfs -m` 은 무엇을 바꿀까요?', 'inode 비율이에요.', NULL, NULL, '[]', 'choice', '["inode 최대 할당 비율", "데이터 영역의 최대 크기", "로그 영역의 최소 크기", "할당 그룹의 개수"]', 0, '문서는 -m 이 inode 로 할당할 수 있는 공간의 최대 비율(퍼센트)을 새로 정하며, mkfs.xfs 의 -i maxpct=nn 과 같다고 설명합니다.', NULL, NULL, NULL, '[{"title": "xfs_growfs(8) man page", "url": "https://man7.org/linux/man-pages/man8/xfs_growfs.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 456 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 456, 8, '-i 옵션', '`xfs_growfs -i` 처럼 **로그를 내부로** 두는 옵션에 대해 문서는 뭐라고 할까요?', '구현 여부예요.', NULL, NULL, '[]', 'choice', '["모든 버전에서 지원된다", "로그를 자동으로 줄인다", "root 만 쓸 수 있다", "구현되지 않았다"]', 3, '문서는 -i(새 로그를 내부 로그로)와 -l/-L(로그 영역 변경)을 구현되지 않은 옵션이라고 표시합니다.', NULL, NULL, NULL, '[{"title": "xfs_growfs(8) man page", "url": "https://man7.org/linux/man-pages/man8/xfs_growfs.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 456 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 456, 9, '활용 환경', '문서가 xfs_growfs 의 **주된 활용 환경** 으로 드는 것은 무엇일까요?', '볼륨이에요.', NULL, NULL, '[]', 'choice', '["암호화된 루프 장치 위에서만 쓴다", "램 디스크 위에서만 쓴다", "md·LVM 같은 논리 볼륨 위", "네트워크 파일시스템 위에서만 쓴다"]', 2, '문서는 xfs_growfs 가 리눅스에서 md 나 lvm 같은 논리 볼륨과 가장 자주 함께 쓰이며, 시작 블록이 같은 채 파티션이 커진 일반 파티션에도 쓸 수 있다고 설명합니다.', NULL, NULL, NULL, '[{"title": "xfs_growfs(8) man page", "url": "https://man7.org/linux/man-pages/man8/xfs_growfs.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 456 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 456, 10, '최대로 확장', '데이터 영역을 **가능한 최대로** 키우는 옵션입니다. 빈칸을 채우세요.', 'data 의 d 예요.', NULL, NULL, '[]', 'fill', '["-d", "-n", "-m", "-t"]', NULL, '-d 는 데이터 영역을 최대로 키웁니다. -n 은 확인만, -m 은 inode 최대 비율, -t 는 대체 마운트 테이블입니다.', '[0]', 'xfs_growfs {0} /data', NULL, '[{"title": "xfs_growfs(8) man page", "url": "https://man7.org/linux/man-pages/man8/xfs_growfs.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 456 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 456, 11, '확장 미리 보기', '확장 없이 **형상만 확인** 하는 옵션입니다. 빈칸을 채우세요.', 'no 의 n 이에요.', NULL, NULL, '[]', 'fill', '["-n", "-d", "-r", "-V"]', NULL, '-n 은 변경 없이 형상을 출력합니다. -d 는 데이터 영역 확장, -r 은 실시간 영역 확장, -V 는 버전 출력입니다.', '[0]', 'xfs_growfs {0} /data', NULL, '[{"title": "xfs_growfs(8) man page", "url": "https://man7.org/linux/man-pages/man8/xfs_growfs.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 456 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 456, 12, 'XFS 확장', 'XFS 를 확장하는 큰 줄기 순서입니다. 순서에 맞게 놓아 보세요.', '공간 → 미리 보기 → 확장 → 확인이에요.', NULL, NULL, '[]', 'order', '["논리 볼륨 등으로 장치의 공간을 먼저 늘린다", "`xfs_growfs -n` 으로 변경 없이 형상을 확인한다", "`xfs_growfs -d` 로 데이터 영역을 최대로 늘린다", "`findmnt -D` 로 늘어난 용량을 확인한다"]', NULL, '문서의 실제 사용(PRACTICAL USE)·-n·-d 설명과 앞 라운드의 findmnt 를 이은 일반 절차입니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "xfs_growfs(8) man page", "url": "https://man7.org/linux/man-pages/man8/xfs_growfs.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 456 AND order_index = 12);

-- 배치: 단원 끝
UPDATE quest_set SET display_order = 644, unit_id = (SELECT id FROM unit WHERE id = 21), icon = '📏' WHERE id = 456;
