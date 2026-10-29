-- 세트 3: 리눅스 기초 3 — 프로세스와 시스템 (order 1~8)
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (3,  1, '실행 중인 프로세스 목록 저장하기',
   '프로세스는 실행 중인 프로그램입니다. 서버가 느리거나 이상할 때 가장 먼저 무엇이 돌고 있는지 봅니다.

현재 실행 중인 **모든 프로세스 목록**을 `/tmp/ps_result.txt` 에 저장하세요.',
   '`ps aux` 는 모든 사용자의 프로세스를 상세하게 보여 줍니다. 결과를 `>` 로 파일에 저장하세요.',
   'ps aux > /tmp/ps_result.txt

# ps : 프로세스 목록 (process status)',
   NULL,
   '["test", "-s", "/tmp/ps_result.txt"]'),

  (3,  2, '특정 프로세스만 찾기',
   '프로세스가 수십~수백 개라 전체에서 원하는 것만 걸러서 봐야 합니다. 앞 명령의 출력을 `grep` 으로 걸러내는 것이 대표적인 파이프(`|`) 사용법입니다.

`ps` 결과 중 `bash` 가 들어간 줄만 걸러 `/tmp/bash_proc.txt` 에 저장하세요.',
   '`ps aux | grep bash` 형태입니다. `|`(파이프)는 앞 명령의 출력을 뒤 명령의 입력으로 넘깁니다. 마지막에 `> 파일` 로 저장하세요.',
   'ps aux | grep bash > /tmp/bash_proc.txt

# | : 앞 명령의 출력을 뒤 명령으로 전달',
   NULL,
   '["sh", "-c", "grep -q bash /tmp/bash_proc.txt"]'),

  (3,  3, '백그라운드로 프로세스 실행하기',
   '오래 걸리는 명령을 실행해 두고 다른 작업을 하려면 **백그라운드**로 돌립니다.

1. `sleep 60`(60초 동안 아무것도 하지 않는 명령)을 백그라운드로 실행합니다.
2. 그 프로세스의 번호(PID)를 `/tmp/sleep_pid.txt` 에 저장합니다.',
   '명령 끝에 `&` 를 붙이면 백그라운드로 실행됩니다. 직전에 백그라운드로 띄운 프로세스의 PID 는 `$!` 에 들어 있으니, 바로 이어서 `echo $!` 로 저장하세요.',
   'sleep 60 & echo $! > /tmp/sleep_pid.txt

# & : 백그라운드 실행
# $! : 마지막으로 띄운 백그라운드 프로세스의 PID',
   NULL,
   '["sh", "-c", "test -s /tmp/sleep_pid.txt"]'),

  (3,  4, '프로세스 종료하기',
   '멈추지 않거나 필요 없는 프로세스는 PID 로 종료합니다.

`/tmp/sleep_pid.txt` 에 저장된 PID 의 프로세스를 종료하세요.',
   '`kill <PID>` 로 종료를 요청합니다. 파일에 들어 있는 PID 를 인자로 쓰려면 `$(cat <파일>)` 로 파일 내용을 끼워 넣을 수 있습니다.',
   'kill $(cat /tmp/sleep_pid.txt)

# $(...) : 안의 명령 결과(파일의 PID)로 대체됨',
   '["sh", "-c", "sleep 60 & echo $! > /tmp/sleep_pid.txt"]',
   '["sh", "-c", "! kill -0 $(cat /tmp/sleep_pid.txt) 2>/dev/null"]'),

  (3,  5, '디스크 사용량 확인하기',
   '디스크가 가득 차면 서비스가 멈춥니다. 정기적으로 확인하는 항목입니다.

서버 **전체 디스크의 사용량**을 `/tmp/df_result.txt` 에 저장하세요.',
   '`df -h` 는 파일시스템(디스크)별 전체 용량, 사용량, 남은 용량을 보여 줍니다. `-h` 는 읽기 쉬운 단위입니다.',
   'df -h > /tmp/df_result.txt

# df : 디스크 여유 공간 (disk free)',
   NULL,
   '["sh", "-c", "grep -q Filesystem /tmp/df_result.txt"]'),

  (3,  6, '메모리 사용량 확인하기',
   '메모리가 부족하면 서버가 느려지거나 프로세스가 강제 종료됩니다.

현재 **메모리 사용량**을 `/tmp/mem_result.txt` 에 저장하세요.',
   '`free -h` 는 전체/사용/여유 메모리를 읽기 쉬운 단위로 보여 줍니다.',
   'free -h > /tmp/mem_result.txt',
   NULL,
   '["sh", "-c", "grep -q Mem /tmp/mem_result.txt"]'),

  (3,  7, '환경변수 설정하기',
   '환경변수는 프로그램이 참고하는 설정값입니다(경로, 모드 등). `export` 로 설정하면 그 터미널에서 실행하는 프로그램이 값을 읽을 수 있습니다.

환경변수 `MY_NAME` 에 `etude` 를 설정하고, 그 값을 `/tmp/env_result.txt` 에 저장하세요.',
   '`export <이름>=<값>` 으로 설정합니다 (`=` 양쪽에 공백 없음). 값은 `echo $이름` 으로 출력할 수 있습니다.',
   'export MY_NAME=etude
echo $MY_NAME > /tmp/env_result.txt

# $MY_NAME : 변수의 값으로 바뀜',
   NULL,
   '["sh", "-c", "grep -q etude /tmp/env_result.txt"]'),

  (3,  8, '전체 환경변수 저장하기',
   '현재 터미널에 어떤 환경변수가 설정되어 있는지 한꺼번에 확인해야 할 때가 있습니다(PATH 문제 등).

현재 설정된 **모든 환경변수 목록**을 `/tmp/all_env.txt` 에 저장하세요.',
   '`env` 또는 `printenv` 는 모든 환경변수를 `이름=값` 형태로 출력합니다.',
   'env > /tmp/all_env.txt',
   NULL,
   '["sh", "-c", "grep -q PATH /tmp/all_env.txt"]');
