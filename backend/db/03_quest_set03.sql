-- 세트 3: 리눅스 기초 3 — 프로세스와 시스템 (order 1~8)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (3,  1, '실행 중인 프로세스 확인하기',
   '현재 실행 중인 모든 프로세스 목록을 /tmp/ps_result.txt 에 저장하세요.',
   'ps aux 명령어와 리다이렉션(>)을 사용하세요.',
   'ps aux > /tmp/ps_result.txt',
   NULL,
   '["test", "-s", "/tmp/ps_result.txt"]'),

  (3,  2, '특정 프로세스 찾기',
   'ps 결과에서 "bash" 프로세스만 필터링해 /tmp/bash_proc.txt 에 저장하세요.',
   'ps aux | grep 형식으로 파이프를 사용하세요.',
   'ps aux | grep bash > /tmp/bash_proc.txt',
   NULL,
   '["sh", "-c", "grep -q bash /tmp/bash_proc.txt"]'),

  (3,  3, '백그라운드 프로세스 실행하기',
   'sleep 60 명령어를 백그라운드로 실행하고, PID를 /tmp/sleep_pid.txt 에 저장하세요.',
   '명령어 끝에 & 를 붙이면 백그라운드로 실행됩니다. echo $! 로 마지막 백그라운드 PID를 확인할 수 있습니다.',
   'sleep 60 & echo $! > /tmp/sleep_pid.txt',
   NULL,
   '["sh", "-c", "test -s /tmp/sleep_pid.txt"]'),

  (3,  4, '프로세스 종료하기',
   '/tmp/sleep_pid.txt 에 저장된 PID의 프로세스를 종료하세요.',
   'kill 명령어에 PID를 전달합니다. $(cat 파일) 로 파일 내용을 명령어 인자로 사용할 수 있습니다.',
   'kill $(cat /tmp/sleep_pid.txt)',
   '["sh", "-c", "sleep 60 & echo $! > /tmp/sleep_pid.txt"]',
   '["sh", "-c", "! kill -0 $(cat /tmp/sleep_pid.txt) 2>/dev/null"]'),

  (3,  5, '디스크 사용량 확인하기',
   '전체 디스크 사용량을 /tmp/df_result.txt 에 저장하세요.',
   'df -h 명령어를 사용하세요. -h 옵션은 사람이 읽기 쉬운 단위로 출력합니다.',
   'df -h > /tmp/df_result.txt',
   NULL,
   '["sh", "-c", "grep -q Filesystem /tmp/df_result.txt"]'),

  (3,  6, '메모리 사용량 확인하기',
   '현재 메모리 사용량을 /tmp/mem_result.txt 에 저장하세요.',
   'free -h 명령어를 사용하세요.',
   'free -h > /tmp/mem_result.txt',
   NULL,
   '["sh", "-c", "grep -q Mem /tmp/mem_result.txt"]'),

  (3,  7, '환경변수 설정하기',
   'MY_NAME 이라는 환경변수에 "etude" 값을 설정하고, 그 값을 /tmp/env_result.txt 에 저장하세요.',
   'export 명령어로 환경변수를 설정하고, echo $변수명 으로 값을 출력할 수 있습니다.',
   'export MY_NAME=etude
echo $MY_NAME > /tmp/env_result.txt',
   NULL,
   '["sh", "-c", "grep -q etude /tmp/env_result.txt"]'),

  (3,  8, '전체 환경변수 저장하기',
   '현재 설정된 모든 환경변수 목록을 /tmp/all_env.txt 에 저장하세요.',
   'env 또는 printenv 명령어를 사용하세요.',
   'env > /tmp/all_env.txt',
   NULL,
   '["sh", "-c", "grep -q PATH /tmp/all_env.txt"]');
