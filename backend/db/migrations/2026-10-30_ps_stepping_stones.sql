-- 세트 3 에 ps 징검다리 문제(9~11)를 추가하고, 세트 16·27 의 프로세스 문제를 앞에서 배운 정렬 저장 형태로 낮춘다 (sed·awk 없이). 여러 번 실행해도 같은 결과다. docs/specs/spec_ps_stepping_stones.md
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 3, 9, 'ps 로 필요한 열만 골라 보기',
   '`ps aux` 는 모든 정보를 보여 주지만 열이 많아서 필요한 값만 보기 어렵습니다. `ps` 는 **보여 줄 열을 직접 고를** 수 있습니다.

모든 프로세스의 **PID(프로세스 번호), RSS(실제로 쓰는 메모리 크기, KB), 실행 명령** 세 열만 `/tmp/ps_cols.txt` 에 저장하세요.

완료 조건: 파일의 제목 줄이 `PID RSS COMMAND` 이고 아래에 프로세스가 나열되어야 합니다.',
   '`ps -eo 열이름,열이름,...` 입니다. `-e` 는 모든 프로세스, `-o` 는 보여 줄 열을 지정하는 옵션입니다. 열 이름은 `pid`(프로세스 번호), `rss`(실제 메모리 KB), `args`(실행한 명령 전체)를 씁니다. 결과를 파일로 저장하려면 `>` 를 씁니다.',
   'ps -eo pid,rss,args > /tmp/ps_cols.txt

# -e : 모든 프로세스, -o pid,rss,args : 이 세 열만 보여 줌
# (args 열의 제목은 COMMAND 로 나옵니다)',
   NULL,
   '["sh", "-c", "[ \\"$(awk ''NR==1 {print $1, $2, $3}'' /tmp/ps_cols.txt)\\" = \\"PID RSS COMMAND\\" ] && [ \\"$(wc -l < /tmp/ps_cols.txt)\\" -gt 1 ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 3 AND order_index = 9);
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 3, 10, '메모리를 많이 쓰는 순서로 정렬해 저장하기',
   '서버가 느릴 때는 **메모리를 많이 쓰는 프로세스**부터 봅니다. `ps` 는 열 하나를 기준으로 **정렬**해서 보여 줄 수 있습니다. 지금 메모리를 크게 쓰는 프로세스가 하나 돌고 있습니다.

`PID, RSS, 명령` 세 열을 **RSS 가 큰 순서**로 정렬해서 `/tmp/ps_by_mem.txt` 에 저장하세요. (제목 줄 포함)

완료 조건: 제목 바로 아래(2번째 줄)가 메모리를 가장 많이 쓰는 프로세스여야 합니다.',
   '`ps -eo pid,rss,args --sort=-rss` 입니다. `--sort=열이름` 은 그 열을 기준으로 정렬하고, 앞에 `-` 를 붙이면 **큰 값이 먼저 오는 내림차순**입니다. (`-` 가 없으면 작은 값이 먼저입니다) 결과는 `>` 로 파일에 저장합니다.',
   'ps -eo pid,rss,args --sort=-rss > /tmp/ps_by_mem.txt

# --sort=-rss : RSS(실제 메모리) 큰 순서. 맨 위 제목 줄 다음이 1등입니다
# 확인: head -n 3 /tmp/ps_by_mem.txt',
   '["sh", "-c", "nohup perl -e ''$x = \\"a\\" x (80*1024*1024); sleep 3600'' memhog >/dev/null 2>&1 & sleep 2"]',
   '["sh", "-c", "[ \\"$(awk ''NR==2 {print $1}'' /tmp/ps_by_mem.txt)\\" = \\"$(pgrep -x perl | head -n 1)\\" ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 3 AND order_index = 10);
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 3, 11, '이름으로 프로세스를 한꺼번에 종료하기',
   '같은 프로그램이 여러 개 떠 있을 때 PID 를 하나씩 찾아 `kill` 하기는 번거롭습니다. 프로세스는 **이름으로 한꺼번에** 종료할 수 있습니다. 지금 이름이 `worker` 인 프로세스가 3개 돌고 있습니다.

이름이 `worker` 인 프로세스를 **모두** 종료하세요.

완료 조건: 이름이 `worker` 인 프로세스가 하나도 없어야 합니다.',
   '`pgrep worker` 는 이름이 맞는 프로세스의 PID 를 보여 주고(`-l` 을 붙이면 이름도 함께), `pkill worker` 는 이름이 맞는 프로세스 모두에 종료 요청(SIGTERM)을 한 번에 보냅니다. `-x` 를 붙이면 이름이 **정확히 같은** 것만 대상으로 합니다. 먼저 `pgrep` 으로 대상을 확인한 뒤 `pkill` 하는 것이 안전합니다.',
   'pgrep -l worker     # 대상 확인 (PID 와 이름)
pkill worker          # 이름이 worker 인 프로세스 모두 종료

# -l : PID 와 함께 이름을 표시',
   '["sh", "-c", "cp /bin/sleep /tmp/worker; for i in 1 2 3; do nohup /tmp/worker 600 >/dev/null 2>&1 & done; sleep 1"]',
   '["sh", "-c", "! pgrep -x worker >/dev/null"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 3 AND order_index = 11);
UPDATE quest SET title='CPU 를 가장 많이 쓰는 프로세스 찾기', description='서버가 갑자기 느려졌습니다. 범인은 보통 **CPU 를 독점하는 프로세스 하나**입니다. 지금 그런 프로세스가 돌고 있습니다.

`PID, CPU 사용률, 명령` 세 열을 **CPU 사용률이 큰 순서**로 정렬해서 `/tmp/cpu_top.txt` 에 저장하세요. (제목 줄 포함)

완료 조건: 제목 바로 아래(2번째 줄)가 CPU 를 가장 많이 쓰는 프로세스여야 합니다.', hint='`ps -eo pid,pcpu,args --sort=-pcpu` 는 CPU 사용률(`pcpu`)이 큰 순서로 프로세스를 보여 줍니다. (`-eo` 는 모든 프로세스를 보여 줄 열을 지정, `--sort=-열이름` 은 큰 값이 먼저 오는 정렬) 결과를 `>` 로 파일에 저장하세요. `top` 으로도 확인할 수 있습니다.', solution='ps -eo pid,pcpu,args --sort=-pcpu > /tmp/cpu_top.txt

# --sort=-pcpu : CPU 사용률 내림차순. 2번째 줄이 1등입니다
# 확인: head -n 3 /tmp/cpu_top.txt', grade_cmd='["sh", "-c", "[ \\"$(awk ''NR==2 {print $1}'' /tmp/cpu_top.txt)\\" = \\"$(pgrep -f ''[w]hile :; do'' | head -n 1)\\" ]"]' WHERE quest_set_id=16 AND order_index=4;
UPDATE quest SET title='메모리를 가장 많이 쓰는 프로세스 3개 저장하기', description='서버의 메모리가 계속 부족해집니다. 원인은 보통 메모리를 크게 점유한 프로세스입니다. 메모리는 `RSS`(실제로 물리 메모리에 올라가 있는 크기) 열로 비교합니다.

`PID, RSS, 명령` 세 열을 **RSS 가 큰 순서**로 정렬하고, **제목 줄과 상위 3개 프로세스**(모두 4줄)만 `/tmp/mem_top3.txt` 에 저장하세요.

완료 조건: 파일이 4줄이고, 제목 바로 아래(2번째 줄)가 메모리를 가장 많이 쓰는 프로세스여야 합니다.', hint='`ps -eo pid,rss,args --sort=-rss` 는 `RSS` 가 큰 순서로 프로세스를 보여 줍니다. (`-e` 모든 프로세스, `-o` 보여 줄 열, `--sort=-rss` 큰 값이 먼저) 앞에서부터 몇 줄만 남기려면 `| head -n 4` 를 붙입니다. (`head -n 4` 는 맨 앞 4줄만 출력, 제목 1줄 + 프로세스 3개)', solution='ps -eo pid,rss,args --sort=-rss | head -n 4 > /tmp/mem_top3.txt

# --sort=-rss : 실제 메모리(RSS) 내림차순
# head -n 4 : 맨 앞 4줄(제목 + 상위 3개)만', grade_cmd='["sh", "-c", "[ \\"$(wc -l < /tmp/mem_top3.txt)\\" -eq 4 ] && [ \\"$(awk ''NR==2 {print $1}'' /tmp/mem_top3.txt)\\" = \\"$(pgrep -x perl | head -n 1)\\" ]"]' WHERE quest_set_id=27 AND order_index=1;
