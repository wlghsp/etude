-- 퀴즈 세트 399. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). docs/specs/spec_openstack_round9.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 399, 'NFS 클라이언트 마운트: hard·soft, timeo·retrans, rsize·wsize, 버전, 잠금', 'NFS 를 마운트할 때의 옵션을 익힙니다. hard 와 soft 의 차이와 soft 의 위험, timeo·retrans 기본값, rsize·wsize 최댓값, nfsvers 협상, noatime 무효, nolock, actimeo 를 봅니다.', 'quiz', '스토리지'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 399);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 399, 1, 'hard 가 기본', 'NFS 마운트에서 **hard/soft 를 지정하지 않으면** 요청은 어떻게 처리될까요?', '끝없이 재시도해요.', NULL, NULL, '[]', 'choice', '["retrans 번 시도 뒤 EIO 로 실패한다 (soft)", "한 번 실패하면 즉시 마운트를 해제한다", "무기한 재시도한다 (hard)", "서버가 응답할 때까지 하지만 10분 뒤 포기한다"]', 2, 'nfs(5) 는 옵션이 없거나 hard 이면 NFS 요청을 무기한 재시도한다고 설명합니다.', NULL, NULL, NULL, '[{"title": "nfs(5) 매뉴얼", "url": "https://man7.org/linux/man-pages/man5/nfs.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 399 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 399, 2, 'soft 의 위험', '**soft** 마운트의 문제로 문서가 경고하는 것은 무엇일까요?', '조용히 깨질 수 있어요.', NULL, NULL, '[]', 'choice', '["서버가 응답하지 않으면 클라이언트가 멈춰 버린다", "일부 경우 조용한 데이터 손상을 일으킬 수 있다", "읽기가 쓰기보다 항상 느려진다", "마운트 지점이 읽기 전용으로 바뀐다"]', 1, 'nfs(5) 는 soft 타임아웃이 특정한 경우 조용한 데이터 손상을 일으킬 수 있다고 경고합니다.', NULL, NULL, NULL, '[{"title": "nfs(5) 매뉴얼", "url": "https://man7.org/linux/man-pages/man5/nfs.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 399 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 399, 3, 'soft 의 오류', '**soft** 마운트에서 retrans 번의 재전송이 끝나면 어떻게 될까요?', '애플리케이션에 오류를 줘요.', NULL, NULL, '[]', 'choice', '["애플리케이션에 오류(EIO)를 돌려준다", "클라이언트가 서버를 다시 찾아서 마운트한다", "요청이 대기열에 영구히 그대로 남는다", "마운트가 자동으로 해제되어 사라진다"]', 0, 'nfs(5) 는 soft 에서 retrans 번 재전송 후 클라이언트가 애플리케이션에 EIO(softerr 면 ETIMEDOUT) 오류를 돌려준다고 설명합니다.', NULL, NULL, NULL, '[{"title": "nfs(5) 매뉴얼", "url": "https://man7.org/linux/man-pages/man5/nfs.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 399 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 399, 4, 'timeo 의 기본', 'NFS 마운트 옵션 **timeo** 는 무엇이며 TCP 에서 기본값은 얼마일까요?', '단위가 데시초예요.', NULL, NULL, '[]', 'choice', '["재전송 횟수를 뜻하며 TCP 기본은 3이다", "캐시 유지 시간(초)이며 TCP 기본은 60이다", "연결 제한 시간(밀리초)이며 기본은 1이다", "응답 대기 시간(데시초), TCP 기본 600"]', 3, 'nfs(5) 는 timeo 를 클라이언트가 응답을 기다린 뒤 재시도하는 시간(데시초)으로, TCP 기본은 600(60초)이고 UDP 기본은 60(6초)이라고 설명합니다.', NULL, NULL, NULL, '[{"title": "nfs(5) 매뉴얼", "url": "https://man7.org/linux/man-pages/man5/nfs.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 399 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 399, 5, 'retrans 기본', 'retrans 를 **지정하지 않으면** 요청을 몇 번 시도할까요?', '프로토콜마다 달라요.', NULL, NULL, '[]', 'choice', '["UDP·TCP 모두 한 번", "UDP·TCP 모두 열 번", "UDP 요청은 세 번, TCP 요청은 두 번", "TCP 는 세 번, UDP 는 두 번"]', 2, 'nfs(5) 는 retrans 를 지정하지 않으면 클라이언트가 UDP 요청은 세 번, TCP 요청은 두 번 시도한다고 설명합니다. 그 뒤 "server not responding" 을 기록하고 hard·soft 복구 동작을 합니다.', NULL, NULL, NULL, '[{"title": "nfs(5) 매뉴얼", "url": "https://man7.org/linux/man-pages/man5/nfs.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 399 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 399, 6, 'rsize·wsize 최대', 'NFS 의 **rsize/wsize 최댓값** 은 얼마일까요?', '1 메가바이트예요.', NULL, NULL, '[]', 'choice', '["65,536 바이트(64KB)", "1,048,576 바이트(1MB)", "16,777,216 바이트(16MB)", "제한이 없다"]', 1, 'nfs(5) 는 rsize·wsize 의 최댓값이 1,048,576 바이트이며, 1024 미만은 4096 으로 1048576 초과는 1048576 으로 바뀐다고 설명합니다.', NULL, NULL, NULL, '[{"title": "nfs(5) 매뉴얼", "url": "https://man7.org/linux/man-pages/man5/nfs.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 399 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 399, 7, 'nfsvers 기본', '**nfsvers** 를 지정하지 않으면 클라이언트는 어떤 버전부터 시도할까요?', '가장 높은 버전부터 내려와요.', NULL, NULL, '[]', 'choice', '["4.2 부터 시도하고 서버에 맞게 낮춘다", "항상 NFSv3 만 쓴다", "NFSv2 부터 시도해 올라간다", "서버에 묻지 않고 NFSv4.0 으로 고정한다"]', 0, 'nfs(5) 는 nfsvers 를 지정하지 않으면 클라이언트가 4.2 를 먼저 시도하고 서버가 지원하지 않으면 협상으로 낮춘다고 설명합니다. 버전을 지정했는데 서버가 지원하지 않으면 마운트가 실패합니다.', NULL, NULL, NULL, '[{"title": "nfs(5) 매뉴얼", "url": "https://man7.org/linux/man-pages/man5/nfs.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 399 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 399, 8, 'noatime 의 효과', 'NFS 마운트에서 **noatime** 같은 atime 관련 옵션은 어떻게 동작할까요?', '효과가 없어요.', NULL, NULL, '[]', 'choice', '["접근 시각 갱신을 끄고 성능을 크게 올린다", "서버 쪽에서만 효과가 있다", "읽기 전용 마운트에서만 효과가 있다", "NFS 마운트에서는 효과가 없다"]', 3, 'nfs(5) 는 noatime 을 포함한 atime 관련 옵션이 NFS 마운트에는 효과가 없다고 설명합니다.', NULL, NULL, NULL, '[{"title": "nfs(5) 매뉴얼", "url": "https://man7.org/linux/man-pages/man5/nfs.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 399 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 399, 9, 'nolock', '**nolock** 옵션은 무엇을 할까요?', 'NLM 잠금을 꺼요.', NULL, NULL, '[]', 'choice', '["모든 파일을 읽기 전용으로 잠가 둔다", "다른 클라이언트의 쓰기를 모두 막아 둔다", "NLM 잠금을 끄고 같은 클라이언트 안에서만 적용한다", "서버 쪽 파일 잠금을 강제로 해제해 둔다"]', 2, 'nfs(5) 는 nolock 이 NLM 잠금을 끄며 잠금은 같은 클라이언트의 다른 애플리케이션에 대해서만 적용된다고 설명합니다. /var 를 NFS 로 마운트할 때는 NLM 을 꺼야 합니다.', NULL, NULL, NULL, '[{"title": "nfs(5) 매뉴얼", "url": "https://man7.org/linux/man-pages/man5/nfs.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 399 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 399, 10, '무한 재시도', '서버가 응답하지 않아도 **무기한 재시도** 하는 마운트 옵션(기본)입니다. 빈칸을 채우세요.', '"soft" 의 반대예요.', NULL, NULL, '[]', 'fill', '["hard", "soft", "nolock", "noatime"]', NULL, 'hard 는 요청을 무기한 재시도하는 기본 동작입니다. soft 는 retrans 번 뒤 오류를 돌려줍니다.', '[0]', 'mount -o {0} server:/data /mnt', NULL, '[{"title": "nfs(5) 매뉴얼", "url": "https://man7.org/linux/man-pages/man5/nfs.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 399 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 399, 11, '캐시 시간을 한 번에', 'acregmin·acregmax·acdirmin·acdirmax 를 **모두 같은 값** 으로 맞추는 옵션입니다. 빈칸을 채우세요.', '"ac" 로 시작해요.', NULL, NULL, '[]', 'fill', '["actimeo", "timeo", "retrans", "rsize"]', NULL, 'actimeo 는 acregmin·acregmax·acdirmin·acdirmax 를 같은 값으로 설정합니다. 기본은 일반 파일 3·60초, 디렉터리 30·60초입니다.', '[0]', 'mount -o {0}=10 server:/data /mnt', NULL, '[{"title": "nfs(5) 매뉴얼", "url": "https://man7.org/linux/man-pages/man5/nfs.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 399 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 399, 12, 'NFS 요청 재시도 과정', '서버가 응답하지 않을 때 NFS 클라이언트의 큰 줄기 동작 순서입니다. 순서에 맞게 놓아 보세요.', '대기 → 재시도 → 로그 → 복구 동작이에요.', NULL, NULL, '[]', 'order', '["응답을 timeo 동안 기다린다", "응답이 없으면 요청을 재전송한다", "retrans 번 재시도 뒤 \\"server not responding\\" 을 기록한다", "hard 면 계속 재시도하고 soft 면 오류를 돌려준다"]', NULL, 'nfs(5) 의 timeo·retrans·hard·soft 설명을 이은 큰 줄기입니다.', '[0, 1, 2, 3]', NULL, NULL, '[{"title": "nfs(5) 매뉴얼", "url": "https://man7.org/linux/man-pages/man5/nfs.5.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 399 AND order_index = 12);

-- 배치: 단원 끝 (분할 마이그레이션 뒤에 적용되도록 2026-11-13 이름을 쓴다)
UPDATE quest_set SET display_order = 625, unit_id = (SELECT id FROM unit WHERE id = 21), icon = '📥' WHERE id = 399;
