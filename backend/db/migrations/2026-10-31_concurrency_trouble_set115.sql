-- 미들웨어 세트 115. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set115.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 27, '미들웨어', '동시성·이벤트', 90 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 27);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 115, '동시성 문제 해결 상황집: stale 락, 중복 처리, 재시도 폭주', '동시성 문제가 실제로 터졌을 때 증상에서 원인을 좁히는 법을 익힙니다. 남은 pid 파일(stale 락) 확인과 정리, deadlock 오류 읽기, 같은 건이 두 번 처리될 때의 대응 순서, 작업 겹침 방지, 재시도 루프와 지수 백오프·jitter, 처리한 ID 기록으로 중복 막기, TTL 없는 분산 락의 위험을 문제와 파일 실습으로 다룹니다.', 'linux', '미들웨어'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 115);
UPDATE quest_set SET display_order = 563, unit_id = (SELECT id FROM unit WHERE id = 27), icon = '🧯' WHERE id = 115;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 115, 1, '프로세스가 살아 있는지 확인하기', '`app.pid` 파일에 적힌 PID `4242` 프로세스가 **아직 살아 있는지** 확인하려 합니다. 신호 번호가 **0** 이면 프로세스를 죽이지 않고 존재만 확인합니다. 빈칸을 채우세요.', '아무 일도 하지 않는 "확인용" 신호 번호예요.', NULL, NULL, '[]', 'fill', '["0", "9", "15", "l"]', NULL, '`kill -0 PID` 는 신호를 보내지 않고 "그 PID 에 신호를 보낼 수 있는가"만 검사해, 살아 있으면 성공(0), 없으면 실패를 돌려줍니다. `-9` 는 강제 종료라 확인용으로 쓰면 큰일 나요.', '[0]', 'kill -{0} 4242 && echo alive || echo dead', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 115 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 115, 2, '"already running" 인데 프로세스가 없어요', '서비스 시작 스크립트가 `already running (pid file exists)` 라며 시작을 거부합니다. 그런데 `ps` 로 보면 서비스 프로세스가 없습니다. 올바른 대응은 무엇일까요?', '서버가 갑자기 꺼지면 pid 파일이 지워지지 못하고 남아요.', NULL, NULL, '[]', 'choice', '["아무 프로세스나 `kill -9` 로 끝낸 뒤 시작한다", "서버를 무조건 재부팅한다", "pid 파일의 PID 가 살아 있는지 확인하고, 죽은 PID 라면 남은 파일(stale)만 지운 뒤 시작한다", "pid 파일의 권한을 777 로 바꾼다"]', 2, '비정상 종료 뒤 pid 파일이 남는 것을 stale 락이라고 합니다. **살아 있는 PID 인지 먼저 확인**하고, 죽은 PID 일 때만 파일을 정리하세요. 살아 있는 프로세스의 파일을 지우면 중복 실행이 돼요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 115 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 115, 3, '남은 pid 파일 정리하고 시작하기', '`/tmp/start.sh` 는 `/tmp/app.pid` 가 있으면 `already running` 이라며 종료하고, 없을 때만 시작해 `/tmp/status.txt` 에 `started` 를 남깁니다. 지금 `app.pid` 에는 이미 죽은 PID 가 남아 있습니다. ① 그 PID 가 **죽었는지 확인**하고 ② 남은 파일을 지운 뒤 ③ 스크립트를 실행해 `status.txt` 가 `started` 가 되게 하세요.', '`kill -0 $(cat /tmp/app.pid)` 로 확인한 뒤, 죽었으면 `rm /tmp/app.pid` 하고 `sh /tmp/start.sh`.
확인: `cat /tmp/status.txt`', 'cat /tmp/app.pid
kill -0 $(cat /tmp/app.pid) 2>/dev/null && echo alive || echo dead
rm -f /tmp/app.pid
sh /tmp/start.sh
cat /tmp/status.txt

# 죽은 PID 일 때만 stale 파일을 지운다. 살아 있다면 지우지 말고 원인을 먼저 본다', '["sh", "-c", "rm -f /tmp/status.txt && echo 999999 > /tmp/app.pid && printf ''%s\\\\n'' ''[ -f /tmp/app.pid ] && echo \\"already running\\" && exit 1'' ''echo $$ > /tmp/app.pid'' ''echo started > /tmp/status.txt'' > /tmp/start.sh"]', '["sh", "-c", "( [ \\"$(cat /tmp/status.txt)\\" = started ] ) && ( ! grep -qx 999999 /tmp/app.pid )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "status.txt 가 started 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/status.txt)\\" = started ]"]}, {"label": "죽은 PID 파일이 정리됐다", "cmd": ["sh", "-c", "! grep -qx 999999 /tmp/app.pid"]}]', '[{"title": "Linux flock(1) 매뉴얼", "url": "https://man7.org/linux/man-pages/man1/flock.1.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 115 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 115, 4, 'Deadlock found 오류 읽기', '애플리케이션 로그에 `Deadlock found when trying to get lock; try restarting transaction` 이 가끔 찍힙니다. 가장 알맞은 대응은 무엇일까요?', '데이터베이스가 서로 기다리는 두 트랜잭션 중 하나를 대신 포기시킨 거예요.', NULL, NULL, '[]', 'choice', '["실패한 트랜잭션을 재시도하게 하고, 여러 행을 갱신할 때 항상 같은 순서로 잡으며 트랜잭션을 짧게 유지한다", "데이터베이스 서버를 매번 재시작한다", "락을 모두 없앤다", "로그 레벨을 낮춰 오류를 숨긴다"]', 0, '데드락은 완전히 없애기보다 **일어나도 안전하게** 만드는 것이 현실적입니다. 재시도, 일관된 락 순서, 짧은 트랜잭션이 기본이에요. 로그가 아주 잦다면 쿼리 순서와 인덱스도 점검하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 115 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 115, 5, '같은 건이 두 번 처리됐다는 신고 대응', '같은 주문이 두 번 처리됐다는 신고를 받았습니다. 순서에 맞게 놓아 보세요.', '증거 확인 → 원인 → 방지 → 정리 → 재확인 순서예요.', NULL, NULL, '[]', 'order', '["로그에서 같은 주문 ID 가 정말 두 번 처리됐는지 확인한다", "같은 작업이 두 곳(인스턴스, 스케줄러, 재시도)에서 도는지 원인을 찾는다", "락 또는 멱등 키로 중복 처리를 막는다", "이미 생긴 중복 데이터를 정리한다", "같은 상황을 만들어 다시 중복이 생기지 않는지 확인한다"]', NULL, '증거 없이 고치면 엉뚱한 곳을 건드립니다. 먼저 중복이 사실인지, 어디서 시작됐는지 보고 방지책을 넣은 뒤 데이터를 정리하세요. 방지책 전에 정리하면 또 생겨요.', '[0, 1, 2, 3, 4]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 115 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 115, 6, '5분마다 도는 작업이 겹쳐요', '5분마다 도는 정산 작업이 요즘 10분씩 걸려, 이전 작업이 끝나기 전에 다음 작업이 시작되어 데이터가 꼬입니다. 가장 알맞은 조치는 무엇일까요?', '이미 실행 중이면 새로 시작하지 않게 만들 수 있어요.', NULL, NULL, '[]', 'choice', '["실행 주기를 1분으로 줄여 더 자주 돌린다", "서버를 재부팅한다", "두 작업이 겹쳐도 상관없다고 본다", "작업을 `flock -n` 으로 감싸 이미 실행 중이면 새 실행을 건너뛰게 하고, 처리 시간이 길어진 이유도 따로 확인한다"]', 3, '스케줄러는 이전 실행이 끝났는지 신경 쓰지 않는 경우가 많습니다. 락으로 **겹침을 막고**, 느려진 원인(데이터 증가, 쿼리)을 따로 해결해야 해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 115 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 115, 7, '재시도 루프 만들기 (최대 5번, 1초 간격)', '`/tmp/flaky.sh` 는 처음 두 번은 실패하고 **세 번째**부터 성공하는 명령입니다. 실패하면 1초 쉬고 다시 시도하되 **최대 5번**까지만 하는 반복문을 만들어, 시도할 때마다 `attempt 번호` 를 `/tmp/retry.log` 에 한 줄씩 남기고, 성공하면 `/tmp/result.txt` 에 `success` 를 쓰세요.', '`i=1; while [ $i -le 5 ]; do ...; sh /tmp/flaky.sh && { ...; break; }; i=$((i+1)); sleep 1; done`', 'i=1
while [ $i -le 5 ]; do
  echo "attempt $i" >> /tmp/retry.log
  sh /tmp/flaky.sh && { echo success > /tmp/result.txt; break; }
  i=$((i+1)); sleep 1
done
cat /tmp/retry.log /tmp/result.txt

# 횟수 상한이 없는 재시도는 장애를 키운다. 상한과 대기를 꼭 둔다', '["sh", "-c", "rm -f /tmp/retry.log /tmp/result.txt /tmp/n && printf ''%s\\\\n'' ''n=$(cat /tmp/n 2>/dev/null || echo 0); n=$((n+1)); echo $n > /tmp/n; [ $n -ge 3 ]'' > /tmp/flaky.sh"]', '["sh", "-c", "( [ \\"$(cat /tmp/result.txt)\\" = success ] ) && ( [ \\"$(wc -l < /tmp/retry.log)\\" -eq 3 ] ) && ( [ \\"$(tail -n 1 /tmp/retry.log)\\" = \\"attempt 3\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "result.txt 가 success 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/result.txt)\\" = success ]"]}, {"label": "시도가 3번 기록됐다", "cmd": ["sh", "-c", "[ \\"$(wc -l < /tmp/retry.log)\\" -eq 3 ]"]}, {"label": "세 번째 시도가 마지막이다", "cmd": ["sh", "-c", "[ \\"$(tail -n 1 /tmp/retry.log)\\" = \\"attempt 3\\" ]"]}]', '[{"title": "Linux flock(1) 매뉴얼", "url": "https://man7.org/linux/man-pages/man1/flock.1.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 115 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 115, 8, '장애가 끝났는데 서비스가 다시 쓰러져요', '외부 서비스가 복구됐는데, 모든 클라이언트가 실패 즉시 **1초 간격으로 무한 재시도**하는 바람에 요청이 폭주해 서비스가 다시 쓰러졌습니다. 가장 알맞은 개선은 무엇일까요?', '재시도 간격을 점점 늘리고, 클라이언트마다 조금씩 다르게 하면 한꺼번에 몰리지 않아요.', NULL, NULL, '[]', 'choice', '["재시도 간격을 0.1초로 줄여 빨리 복구되게 한다", "지수 백오프(대기 시간을 1, 2, 4, 8 … 배로 늘림)에 약간의 무작위(jitter)와 최대 횟수를 둔다", "재시도를 제한 없이 계속한다", "실패해도 응답 코드를 무시한다"]', 1, '모두가 같은 간격으로 재시도하면 복구 순간에 요청이 한꺼번에 몰립니다(retry storm). 백오프로 부담을 분산하고 jitter 로 시점을 흩뜨리며, 상한을 둬서 포기할 때를 정하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 115 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 115, 9, '백오프 대기 시간 계산', '재시도 대기 시간을 매번 **두 배**로 늘리면 1, 2, 4, ?, 16 초가 됩니다. 그리고 클라이언트마다 시점을 흩뜨리려고 대기 시간에 **무작위 값을 조금 더하는 것**을 무엇이라 부를까요? 빈칸을 채우세요.', '4 의 두 배, 그리고 "흔들림"을 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["8", "jitter", "6", "timeout", "10"]', NULL, '두 배씩 늘리는 방식이 **지수 백오프**입니다. 무작위를 더하는 **jitter** 가 없으면 모든 클라이언트가 같은 시각에 다시 몰려요. 보통 상한(예: 60초)과 최대 횟수도 함께 둡니다.', '[0, 1]', '대기 시간: 1, 2, 4, {0}, 16 초
무작위로 조금 더하는 것: {1}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 115 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 115, 10, '같은 이벤트를 두 번 돌려도 한 번만 처리하기', '`/tmp/queue.txt` 의 ID(`a b a c b`) 를 한 줄씩 처리해 `/tmp/out.log` 에 남기는 일을 **두 번 연속 실행**할 겁니다(재실행 상황). 이미 처리한 ID 는 `/tmp/done.ids` 에 기록해 두고 **다시 만나면 건너뛰게** 하여, 두 번 돌린 뒤에도 `out.log` 에 `a`, `b`, `c` 가 **각각 한 번씩만** 있게 하세요.', '`grep -qx "$id" /tmp/done.ids` 로 이미 처리했는지 확인하세요. 바깥에 `for run in 1 2` 를 두면 재실행을 흉내 낼 수 있어요.', 'for run in 1 2; do
  while read id; do
    grep -qx "$id" /tmp/done.ids 2>/dev/null && continue
    echo "$id" >> /tmp/out.log
    echo "$id" >> /tmp/done.ids
  done < /tmp/queue.txt
done
cat /tmp/out.log

# 처리한 ID 를 기록해 두면 재실행·중복 수신에도 결과가 같다 (멱등)', '["sh", "-c", "rm -f /tmp/out.log /tmp/done.ids && printf ''%s\\\\n'' a b a c b > /tmp/queue.txt"]', '["sh", "-c", "( [ \\"$(wc -l < /tmp/out.log)\\" -eq 3 ] ) && ( [ -z \\"$(sort /tmp/out.log | uniq -d)\\" ] ) && ( [ \\"$(sort /tmp/out.log | tr \\"\\\\n\\" \\" \\")\\" = \\"a b c \\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "out.log 가 3줄이다", "cmd": ["sh", "-c", "[ \\"$(wc -l < /tmp/out.log)\\" -eq 3 ]"]}, {"label": "중복된 ID 가 없다", "cmd": ["sh", "-c", "[ -z \\"$(sort /tmp/out.log | uniq -d)\\" ]"]}, {"label": "a b c 가 모두 있다", "cmd": ["sh", "-c", "[ \\"$(sort /tmp/out.log | tr \\"\\\\n\\" \\" \\")\\" = \\"a b c \\" ]"]}]', '[{"title": "Linux flock(1) 매뉴얼", "url": "https://man7.org/linux/man-pages/man1/flock.1.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 115 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 115, 11, '만료 없는 락이 영영 안 풀려요', '여러 서버가 공유 저장소(예: Redis)에 락 키를 만들어 작업을 조율합니다. 한 서버가 락을 잡은 채 죽었더니 **다른 서버들이 영원히 기다립니다.** 가장 알맞은 설계는 무엇일까요?', '죽은 소유자가 락을 풀어 주지 못해도 락이 알아서 사라지게 하면 돼요.', NULL, NULL, '[]', 'choice', '["락 키를 영구히 유지한다", "죽은 서버를 찾지 않고 모든 서버를 재시작한다", "락에 **만료 시간(TTL)** 을 두고, 작업이 끝나면 소유자만 해제하게 한다. 작업이 TTL 보다 오래 걸리면 갱신한다", "락을 아예 쓰지 않는다"]', 2, 'TTL 이 없으면 소유자가 죽을 때 락이 영원히 남습니다. 반대로 TTL 이 작업 시간보다 짧으면 락이 풀려 두 곳이 동시에 일하므로, 작업 시간을 고려해 정하고 해제는 소유자 확인 후에 하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 115 AND order_index = 11);
