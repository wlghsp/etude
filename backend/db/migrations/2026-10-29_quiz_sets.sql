-- 객관식 퀴즈 세트 28(리눅스 명령어 확인), 29(k8s CKA 개념·명령) 추가. 여러 번 실행해도 안전하도록 NOT EXISTS 가드를 둔다 (원본: 02_quest_set.sql, 03_quest_set28.sql, 03_quest_set29.sql).
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 28, '리눅스 명령어 확인 퀴즈', '명령어의 옵션 의미, 권한과 출력 읽기, 용량·메모리 해석, 종료 코드, NFS 장애 해석까지 객관식으로 확인합니다. 정답과 함께 오답이 왜 틀렸는지 해설을 봅니다.', 'quiz', '리눅스' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 28,  1, '대기 중인 TCP 포트를 프로세스와 함께 보는 명령 고르기',
   '서비스가 포트를 열고 기다리는지 확인하려고 합니다. **TCP 포트 중 대기(listen) 중인 것을 숫자로, 어떤 프로세스인지와 함께** 보여 주는 명령은 무엇일까요?',
   '옵션을 하나씩 떠올려 보세요: `t`(TCP), `u`(UDP), `l`(listen), `n`(numeric), `p`(process).',
   NULL,
   NULL,
   '[]',
   'choice',
   '["`ss -ulnp`", "`ss -s`", "`ss -tlnp`", "`ss -r`"]',
   2,
   '정답은 **C `ss -tlnp`** 입니다. `-t` TCP, `-l` 대기(listen) 중인 소켓만, `-n` 포트를 이름 대신 숫자로, `-p` 프로세스를 함께 표시합니다.

- A `ss -ulnp` : `-u` 는 **UDP** 입니다. TCP 가 아닙니다.
- B `ss -s` : 소켓 개수 통계 요약만 보여 줍니다. 포트 목록이 아닙니다.
- D `ss -r` : 주소를 이름으로 해석(resolve)해서 보여 주는 옵션이라 대기 중인 포트만 걸러 주지 않습니다.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 28 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 28,  2, 'chmod 숫자 권한이 ls -l 에서 어떻게 보이는지 읽기',
   '`chmod 640 app.conf` 를 실행했습니다. 이 파일의 권한은 `ls -l` 에서 어떻게 표시될까요?',
   '숫자는 **소유자, 그룹, 기타** 순서입니다. 읽기(r)=4, 쓰기(w)=2, 실행(x)=1 을 더한 값입니다.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["`-rw-r--r--`", "`-rw-r-----`", "`-rwxr-----`", "`-rw-rw----`"]',
   1,
   '정답은 **B `-rw-r-----`** 입니다. 6 = 4+2 → `rw-`(소유자), 4 → `r--`(그룹), 0 → `---`(기타) 입니다.

- A `-rw-r--r--` 는 `644` 입니다. 기타 사용자도 읽을 수 있습니다.
- C `-rwxr-----` 는 `740` 입니다. 소유자에게 실행 권한이 있습니다.
- D `-rw-rw----` 는 `660` 입니다. 그룹도 쓸 수 있습니다.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 28 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 28,  3, '디렉토리 권한 문자열을 읽고 할 수 있는 일 판단하기',
   '`ls -l` 결과가 `drwxr-x--- 2 root dev 4096 Oct 29 10:00 logs` 입니다. `dev` 그룹에 속한 사용자 `kim` 이 `logs` 디렉토리에서 **할 수 있는 일**은 무엇일까요?',
   '그룹 권한은 두 번째 묶음 `r-x` 입니다. 디렉토리에서 `r` 은 목록 보기, `w` 는 파일 만들기·지우기, `x` 는 안으로 들어가기입니다.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["파일 목록 보기, 새 파일 만들기와 삭제", "아무것도 할 수 없다", "새 파일은 만들 수 있지만 목록은 볼 수 없다", "안으로 들어가 목록을 보고 파일을 읽을 수는 있지만 새 파일을 만들 수는 없다"]',
   3,
   '정답은 **D** 입니다. 그룹 권한이 `r-x` 이므로 목록 보기(`r`)와 진입(`x`)은 되고, 쓰기(`w`)가 없어 파일을 만들거나 지울 수 없습니다.

- A 는 `w` 가 있어야 가능합니다. `r-x` 에는 없습니다.
- B 는 그룹 권한이 `r-x` 라서 틀렸습니다. (기타 사용자 권한 `---` 와 헷갈린 경우)
- C 는 반대입니다. 쓰기 권한이 없어서 파일을 만들 수 없습니다.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 28 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 28,  4, '용량은 남았는데 파일이 안 만들어지는 이유 찾기',
   '`df -h` 로 보면 `/data` 는 40% 만 쓰고 있는데 `touch newfile` 이 `No space left on device` 오류를 냅니다. `df -i` 를 보니 `/data` 의 `IUse%` 가 `100%` 입니다. 원인과 해결로 맞는 것은?',
   '`df -h` 는 **용량**을, `df -i` 는 **inode(파일 개수 한도)** 를 보여 줍니다.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["inode(파일 개수 한도)가 가득 찼다. 작은 파일이 많이 쌓인 디렉토리를 찾아 정리한다", "디스크 용량이 가득 찼다. 큰 파일을 지운다", "파일 권한 문제다. `chmod 777 /data` 로 풀어 준다", "메모리가 부족하다. 서버를 재부팅한다"]',
   0,
   '정답은 **A** 입니다. 파일 시스템은 파일 하나마다 inode 를 하나씩 씁니다. 용량이 남아 있어도 inode 가 다 차면 새 파일을 만들 수 없고, 같은 `No space left on device` 오류가 납니다. 로그나 캐시처럼 **작은 파일이 수없이 쌓이는 디렉토리**에서 흔합니다.

- B 는 `df -h` 가 40% 라서 아닙니다.
- C 는 권한 오류라면 `Permission denied` 가 납니다.
- D 는 메모리와 무관합니다.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 28 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 28,  5, 'free 출력을 보고 메모리가 부족한지 판단하기',
   '`free -h` 결과가 `Mem: total 15Gi, used 3.2Gi, free 210Mi, shared 120Mi, buff/cache 12Gi, available 11Gi` 입니다. 이 서버는 메모리가 부족한 상태일까요?',
   '새 프로그램이 실제로 쓸 수 있는 양은 어느 열일까요? 리눅스는 남는 메모리를 디스크 캐시로 씁니다.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["부족하다. `free` 가 210Mi 밖에 없다", "부족하다. `buff/cache` 가 12Gi 나 차지하고 있다", "부족하지 않다. 캐시는 필요하면 반환되므로 실제 쓸 수 있는 `available` 이 11Gi 다", "알 수 없다. swap 을 봐야만 판단할 수 있다"]',
   2,
   '정답은 **C** 입니다. 리눅스는 남는 메모리를 디스크 캐시(`buff/cache`)로 활용하고, 프로그램이 메모리를 요구하면 캐시를 반환합니다. 그래서 `free` 열이 작아도 문제가 아니고, **`available`** 이 새로 쓸 수 있는 양의 추정값입니다.

- A 는 가장 흔한 오해입니다. `free` 만 보면 항상 부족해 보입니다.
- B 캐시는 반환할 수 있는 메모리라 문제가 아닙니다.
- D swap 을 보면 도움이 되지만 `available` 로도 충분히 판단할 수 있습니다.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 28 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 28,  6, '정상 출력과 에러를 모두 파일로 저장하는 리다이렉션 고르기',
   '`ls /etc/hostname /nonexistent` 는 정상 출력(`/etc/hostname`)과 에러 메시지(`/nonexistent` 없음)를 모두 냅니다. **둘 다 `out.txt` 에 저장**하는 명령은 무엇일까요?',
   '정상 출력은 1번, 에러는 2번입니다. `2>&1` 은 ''2번을 지금 1번이 가는 곳으로 보낸다''는 뜻이고, **순서**가 중요합니다.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["`ls /etc/hostname /nonexistent > out.txt 2>&1`", "`ls /etc/hostname /nonexistent 2>&1 > out.txt`", "`ls /etc/hostname /nonexistent 2> out.txt`", "`ls /etc/hostname /nonexistent > out.txt`"]',
   0,
   '정답은 **A** 입니다. 먼저 `> out.txt` 로 1번을 파일로 보내고, 그다음 `2>&1` 로 2번을 ''지금 1번이 가는 곳(파일)''으로 보냅니다.

- B 는 순서가 반대라서, 2번이 먼저 ''화면''으로 복사된 뒤 1번만 파일로 갑니다. 에러가 화면에 나옵니다.
- C 는 에러만 파일로 저장합니다. 정상 출력은 화면에 나옵니다.
- D 는 정상 출력만 저장합니다.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 28 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 28,  7, 'ps | grep | wc 결과 1 의 의미 해석하기',
   '`ps aux | grep nginx | wc -l` 을 실행했더니 `1` 이 나왔습니다. 이 결과는 무엇을 의미할까요?',
   '`ps aux` 는 `grep nginx` **자기 자신**의 프로세스도 보여 줍니다. 그 줄에도 `nginx` 라는 글자가 들어 있습니다.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["nginx 프로세스가 정확히 1개 실행 중이다", "nginx 는 실행 중이 아닐 가능성이 높다. 1 은 grep 명령 자신이 매칭된 줄이다", "nginx 가 에러로 종료되었다", "grep 명령이 실패했다"]',
   1,
   '정답은 **B** 입니다. 파이프로 연결된 `grep nginx` 프로세스의 명령줄에도 `nginx` 가 있어서, `ps` 출력에 그 줄이 포함되고 grep 에 잡힙니다. nginx 가 없어도 1 이 나옵니다.

정확히 확인하려면 `pgrep nginx` 를 쓰거나 `grep [n]ginx` 처럼 패턴이 자기 자신과 매칭되지 않게 씁니다.

- A 는 흔한 오해입니다. 그 1줄이 nginx 가 아니라 grep 일 수 있습니다.
- C, D 는 이 출력으로 알 수 없고 근거가 없습니다.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 28 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 28,  8, 'find -mtime +7 이 찾는 파일 읽기',
   '`find /var/log -name "*.log" -mtime +7` 은 어떤 파일을 찾을까요?',
   '`-mtime` 은 파일을 마지막으로 **수정(modify)한 시간**입니다. `+7` 은 ''7일보다 더''라는 뜻입니다.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["최근 7일 이내에 수정된 `.log` 파일", "정확히 7일 전에 수정된 `.log` 파일", "7일 뒤에 삭제될 `.log` 파일", "수정한 지 7일이 넘은(오래된) `.log` 파일"]',
   3,
   '정답은 **D** 입니다. `-mtime +7` 은 수정한 지 7일보다 오래된 파일입니다. 오래된 로그를 정리할 때 `-delete` 와 함께 씁니다.

- A 는 `-mtime -7` 입니다. (`-` 는 ''이내'')
- B 는 `-mtime 7` 입니다. (부호 없이 숫자만이면 정확히 그 일수)
- C 는 `find` 에 그런 기능이 없습니다.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 28 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 28,  9, '멈춘 프로세스를 종료할 때 먼저 시도할 방법 고르기',
   '응답 없는 프로세스를 종료하려고 합니다. **가장 먼저 시도해야 하는 방법**은 무엇일까요?',
   '`kill` 은 프로세스에 **신호**를 보냅니다. 기본 신호가 무엇인지, `-9` 는 무엇인지 떠올려 보세요.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["`kill -9 PID` : 즉시 강제 종료", "`kill PID` : 정리할 시간을 주고 종료를 요청 (SIGTERM)", "`kill -1 PID`", "서버를 재부팅한다"]',
   1,
   '정답은 **B** 입니다. `kill PID` 는 기본 신호 SIGTERM(15)을 보내, 프로세스가 열린 파일 저장과 연결 종료 같은 **정리 작업을 한 뒤 끝나게** 합니다.

- A `kill -9` 는 SIGKILL 로 정리 없이 강제 종료해서 데이터 손상 위험이 있어, SIGTERM 으로 안 끝날 때의 **마지막 수단**입니다.
- C `kill -1` 은 SIGHUP 입니다. 보통 설정을 다시 읽으라는 신호이고 종료용이 아닙니다.
- D 는 과합니다.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 28 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 28, 10, 'grep 종료 코드 1 의 의미 알기',
   '`grep -q ERROR app.log; echo $?` 를 실행했더니 `1` 이 출력되었습니다. 무슨 뜻일까요?',
   '`grep` 의 종료 코드: 찾으면 0, **못 찾으면 1**, 오류(파일 없음 등)면 2 입니다.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["ERROR 가 1개 있다", "grep 명령이 오류로 실패했다 (문법 오류)", "`app.log` 에서 ERROR 를 찾지 못했다", "ERROR 가 첫 번째 줄에 있다"]',
   2,
   '정답은 **C** 입니다. `grep -q` 는 출력 없이 종료 코드만 남기고, 종료 코드는 `0` 찾음, `1` 못 찾음, `2` 오류(파일 없음, 잘못된 옵션 등)입니다. 스크립트에서 `if grep -q ... ; then` 처럼 씁니다.

- A, D 는 종료 코드가 위치나 개수를 알려 주지 않습니다.
- B 는 오류였다면 `2` 입니다.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 28 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 28, 11, 'tar 옵션 z 의 역할 고르기',
   '`tar -czvf backup.tar.gz /etc` 에서 `z` 옵션의 역할은 무엇일까요?',
   '`c`, `z`, `v`, `f` 를 각각 떠올려 보세요. 파일 이름 `backup.tar.gz` 의 `.gz` 가 힌트입니다.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["gzip 으로 압축한다", "압축을 푼다", "파일 목록을 자세히 보여 준다 (verbose)", "아카이브 파일 이름을 지정한다"]',
   0,
   '정답은 **A** 입니다. `-czvf` 는 `c` 만들기(create), `z` gzip 압축, `v` 진행 과정 출력(verbose), `f` 파일 이름 지정(file) 입니다.

- B 는 압축 풀기 옵션 `x`(extract)입니다.
- C 는 `v` 입니다.
- D 는 `f` 입니다.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 28 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 28, 12, '서비스를 재부팅 후에도 자동으로 시작되게 하는 명령 고르기',
   '서비스 `nginx` 를 지금 시작했습니다. 서버를 재부팅해도 **자동으로 다시 시작**되게 하려면 어떤 명령이 필요할까요?',
   '''지금 켜기''와 ''부팅 때 자동으로 켜기''는 다른 명령입니다.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["`systemctl start nginx` : 이미 했으므로 충분하다", "`systemctl restart nginx`", "`systemctl status nginx`", "`systemctl enable nginx`"]',
   3,
   '정답은 **D** 입니다. `start` 는 지금 시작이고, `enable` 은 부팅 때 자동 시작으로 등록합니다. 둘을 한 번에 하려면 `systemctl enable --now nginx` 입니다.

- A 는 지금만 켜므로 재부팅하면 꺼집니다.
- B 는 서비스를 다시 시작할 뿐 자동 시작 설정과 무관합니다.
- C 는 상태 확인입니다.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 28 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 28, 13, 'NFS 서버가 멈췄을 때 df 가 멈추는 이유 알기',
   'NFS 서버가 갑자기 응답하지 않습니다. 그 뒤로 `df -h` 와 `ls /mnt/data` 가 **끝나지 않고 멈춥니다.** 마운트 옵션을 보니 `hard` 입니다. 왜 그럴까요?',
   '`hard` 와 `soft` 마운트는 **서버가 응답하지 않을 때** 어떻게 동작할지를 정합니다.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["`df` 명령이 고장 났다", "`hard` 마운트는 서버가 돌아올 때까지 I/O 를 계속 기다리므로, 그 경로를 건드리는 명령이 멈춘다", "클라이언트의 디스크가 가득 찼다", "`hard` 는 읽기 전용이라 쓰기를 기다린다"]',
   1,
   '정답은 **B** 입니다. `hard` 마운트는 데이터 안전을 위해 서버가 응답할 때까지 **무한정 재시도**합니다. 그래서 그 마운트를 조회하는 `df`, `ls` 도 함께 멈춥니다. (`soft` 는 일정 횟수 뒤 오류를 돌려주지만 데이터 유실 위험이 있습니다.)

장애 때는 `df -l`(로컬 파일시스템만)이나 `timeout 5 df` 로 피하고, 복구는 서버를 살리거나 `umount -f`(안 되면 `umount -l`)를 씁니다.

- A, C 는 근거가 없고, D 는 `hard` 가 읽기 전용이라는 뜻이 아닙니다(읽기 전용은 `ro`).'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 28 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 28, 14, 'NFS 에서 Stale file handle 오류의 원인 찾기',
   'NFS 로 마운트한 디렉토리에서 `ls` 를 했더니 `Stale file handle` 오류가 납니다. 가장 가능성 높은 원인은 무엇일까요?',
   '''stale'' 은 ''오래되어 더는 유효하지 않은''이라는 뜻입니다. 클라이언트가 서버의 파일을 가리키는 **핸들**을 갖고 있습니다.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["서버 쪽에서 그 디렉토리(또는 export)가 삭제·재생성되어 클라이언트가 가진 파일 핸들이 더는 유효하지 않다", "클라이언트의 메모리가 부족하다", "`nfs-utils` 가 설치되지 않았다", "파일 권한이 777 이어서 거부되었다"]',
   0,
   '정답은 **A** 입니다. NFS 클라이언트는 서버의 파일을 ''파일 핸들''로 가리키는데, 서버에서 그 파일이나 디렉토리가 지워지거나 다시 만들어지면 핸들이 무효가 되어 `Stale file handle` 이 납니다.

해결: 클라이언트에서 `umount -f /mnt/data`(안 되면 `umount -l /mnt/data`) 후 다시 `mount` 합니다.

- B, C 는 다른 증상(메모리 오류, 마운트 자체 실패)입니다.
- D 권한 문제라면 `Permission denied` 입니다.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 28 AND order_index = 14);

INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 29, 'k8s CKA 개념·명령 퀴즈', 'Pod/Deployment/Service, 장애 상태(CrashLoopBackOff, Pending, OOMKilled), 프로브, 롤백, Secret, kubectl 사용법을 CKA 연습처럼 객관식으로 확인합니다.', 'quiz', 'k8s' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 29);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 29,  1, 'Pod 가 사라져도 자동으로 다시 만들어 주는 리소스 고르기',
   'Pod 를 `kubectl run web --image=nginx` 로 직접 만들었습니다. 노드 장애로 이 Pod 가 사라지면 다시 만들어 줄까요? 사라져도 **자동으로 다시 만들어 주도록** 하려면 무엇으로 배포해야 할까요?',
   'Pod 개수를 원하는 수로 **유지**해 주는 상위 리소스를 떠올려 보세요.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["Service", "Deployment", "ConfigMap", "Namespace"]',
   1,
   '정답은 **B Deployment** 입니다. Deployment 는 ReplicaSet 을 통해 Pod 개수를 원하는 수로 유지하고 롤링 업데이트와 롤백도 관리합니다. 단독으로 만든 Pod 는 사라져도 되살아나지 않습니다.

- A Service 는 Pod 앞의 고정 접속 지점(로드밸런싱)입니다.
- C ConfigMap 은 설정값을 담는 리소스입니다.
- D Namespace 는 리소스를 논리적으로 나누는 공간입니다.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 29 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 29,  2, 'Pod 를 만들지 않고 YAML 뼈대만 출력하는 명령 고르기',
   'Pod 를 **실제로 만들지 않고** YAML 뼈대만 파일로 저장하려고 합니다. 올바른 명령은 무엇일까요? (CKA 에서 자주 쓰는 방법입니다)',
   '만들지 않고 시험만 하는 옵션과, 출력 형식을 YAML 로 바꾸는 옵션이 둘 다 필요합니다.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["`kubectl run web --image=nginx > web.yaml`", "`kubectl create web.yaml`", "`kubectl get pod web -o yaml > web.yaml`", "`kubectl run web --image=nginx --dry-run=client -o yaml > web.yaml`"]',
   3,
   '정답은 **D** 입니다. `--dry-run=client` 는 서버에 요청하지 않고 객체만 만들어 보고, `-o yaml` 은 그 결과를 YAML 로 출력합니다. 이 출력을 파일로 저장하면 뼈대가 됩니다.

- A 는 Pod 를 **실제로 만들고**, 파일에는 `pod/web created` 한 줄만 저장됩니다.
- B 는 `create` 에 파일을 쓰려면 `-f web.yaml` 이 필요하고, 그 파일이 먼저 있어야 합니다.
- C 는 **이미 있는** Pod 의 YAML 을 가져오는 것이라 없는 Pod 에는 오류가 납니다.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 29 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 29,  3, '클러스터 밖에서 노드 IP 와 포트로 접근하는 Service 유형 고르기',
   '클러스터 **밖**에서 `노드IP:포트` 로 서비스에 접근할 수 있게 하려면 Service 유형을 무엇으로 해야 할까요?',
   '기본값 `ClusterIP` 는 클러스터 **안**에서만 접근됩니다. 노드의 포트를 여는 유형이 있습니다.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["NodePort", "ClusterIP", "Headless (`clusterIP: None`)", "ExternalName"]',
   0,
   '정답은 **A NodePort** 입니다. 각 노드의 지정된 포트(기본 30000~32767)를 열어 외부에서 접근하게 합니다.

- B ClusterIP(기본값)는 클러스터 내부 전용입니다.
- C Headless 는 가상 IP 없이 Pod IP 를 직접 돌려주는 방식(StatefulSet 등)입니다.
- D ExternalName 은 외부 DNS 이름으로 연결해 주는 별칭입니다.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 29 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 29,  4, 'CrashLoopBackOff 의 의미와 가장 먼저 볼 곳 알기',
   '`kubectl get pods` 에서 Pod 상태가 `CrashLoopBackOff` 입니다. 이 상태가 의미하는 것과 **가장 먼저 볼 곳**으로 맞는 것은?',
   '''Crash''(충돌)와 ''Loop''(반복)입니다. 컨테이너가 **시작된 뒤**에 어떻게 되는지 생각해 보세요.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["이미지를 받지 못하고 있다 → 레지스트리 접속을 확인한다", "스케줄링을 기다리고 있다 → 노드 자원을 확인한다", "컨테이너가 시작하자마자 종료되기를 반복한다 → `kubectl logs` 와 `describe` 의 종료 코드·이벤트를 확인한다", "정상이며 곧 Running 이 된다"]',
   2,
   '정답은 **C** 입니다. `CrashLoopBackOff` 는 컨테이너가 시작 후 계속 종료되어, 쿠버네티스가 **재시작 간격을 점점 늘리며** 다시 띄우는 상태입니다. `kubectl logs`(필요하면 `--previous`)로 앱 오류를, `kubectl describe pod` 로 `Exit Code` 와 이벤트를 확인합니다.

- A 는 `ErrImagePull`/`ImagePullBackOff` 입니다.
- B 는 `Pending` 입니다.
- D 는 아닙니다. 원인을 고치지 않으면 계속 반복합니다.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 29 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 29,  5, 'ImagePullBackOff 의 원인이 아닌 것 고르기',
   '`ImagePullBackOff` 상태의 원인으로 **가능성이 가장 낮은 것**은 무엇일까요?',
   '이 상태는 컨테이너가 시작되기 **전에** 이미지를 받는 단계에서 생깁니다.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["이미지 이름이나 태그의 오타", "컨테이너 안 애플리케이션 코드의 버그", "사설 레지스트리 인증 정보(`imagePullSecrets`) 누락", "노드에서 레지스트리로의 네트워크 접속 불가"]',
   1,
   '정답은 **B** 입니다. 애플리케이션 버그는 이미지를 받은 **뒤** 컨테이너가 실행되면서 드러나므로 `CrashLoopBackOff` 같은 상태가 됩니다.

- A, C, D 는 모두 이미지를 **받는 단계**에서 실패하는 대표 원인입니다. `kubectl describe pod` 의 Events 에서 `Failed to pull image` 의 이유를 확인합니다.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 29 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 29,  6, 'Pending 과 Insufficient memory 이벤트의 원인 알기',
   'Pod 가 `Pending` 이고, `kubectl describe pod` 의 Events 에 `0/1 nodes are available: 1 Insufficient memory` 가 있습니다. 원인은 무엇일까요?',
   '스케줄러는 Pod 가 **요청한 자원**을 보장할 수 있는 노드에만 배치합니다.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["컨테이너의 memory `limits` 가 너무 낮다", "이미지가 너무 크다", "`livenessProbe` 가 실패하고 있다", "Pod 의 memory `requests` 가 노드에 남은 메모리보다 커서 배치할 곳이 없다"]',
   3,
   '정답은 **D** 입니다. 스케줄러는 `requests`(요청량)를 기준으로 노드를 고릅니다. 어느 노드에도 그만큼 남은 메모리가 없으면 `Pending` 으로 남고 `Insufficient memory` 가 기록됩니다. `requests` 를 줄이거나 노드 자원을 늘립니다.

- A `limits` 는 실행 중 상한이라 스케줄링과 무관합니다(초과 시 `OOMKilled`).
- B 이미지 크기는 `ContainerCreating` 시간에 영향을 줍니다.
- C 프로브는 Pod 가 **실행된 뒤**의 문제입니다.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 29 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 29,  7, 'Readiness Probe 와 Liveness Probe 구분하기',
   '컨테이너는 시작했지만 아직 요청을 받을 준비가 되지 않았을 때, **Service 로 트래픽을 보내지 않게** 하는 장치는 무엇일까요? (컨테이너를 재시작하지는 않습니다)',
   '두 프로브의 실패 결과가 다릅니다. 하나는 ''트래픽에서 빼기'', 다른 하나는 ''컨테이너 재시작''입니다.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["readinessProbe", "livenessProbe", "restartPolicy", "resources.limits"]',
   0,
   '정답은 **A readinessProbe** 입니다. 실패하면 Pod 가 Service 의 엔드포인트에서 빠져 트래픽을 받지 않습니다(`READY 0/1`). 컨테이너는 그대로 둡니다.

- B livenessProbe 는 실패하면 컨테이너를 **재시작**합니다.
- C restartPolicy 는 종료된 컨테이너를 다시 시작할지 정합니다.
- D limits 는 자원 상한입니다.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 29 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 29,  8, '이전 버전으로 즉시 되돌리는 명령 고르기',
   '새 이미지로 롤링 업데이트를 했더니 장애가 났습니다. Deployment `app` 을 **이전 버전으로 즉시 되돌리는** 명령은 무엇일까요?',
   '배포 이력(revision)을 관리하는 명령 그룹이 있습니다.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["`kubectl rollout restart deployment/app`", "`kubectl delete deployment app`", "`kubectl rollout undo deployment/app`", "`kubectl scale deployment app --replicas=0`"]',
   2,
   '정답은 **C** 입니다. `rollout undo` 는 직전 revision 으로 되돌립니다(`--to-revision=N` 으로 특정 버전도 가능). 이력은 `kubectl rollout history` 로 봅니다.

- A `restart` 는 **같은 버전**의 Pod 를 새로 띄울 뿐입니다.
- B 는 Deployment 자체를 삭제합니다.
- D 는 Pod 를 모두 0개로 만들어 서비스가 중단됩니다.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 29 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 29,  9, 'Secret 의 base64 가 의미하는 것 알기',
   '`kubectl get secret db-secret -o yaml` 을 보면 값이 알아볼 수 없는 문자열로 보입니다. 올바른 설명은 무엇일까요?',
   '''알아볼 수 없다''와 ''안전하다''는 다른 말입니다. 그 문자열을 어떻게 풀 수 있는지 생각해 보세요.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["AES 로 암호화되어 있어서 누구도 읽을 수 없다", "base64 로 인코딩된 것일 뿐 암호화가 아니라서 `base64 -d` 로 누구나 풀 수 있다. 그래서 접근 권한(RBAC) 관리가 중요하다", "해시라서 원문을 복원할 수 없다", "ConfigMap 과 완전히 같아서 차이가 없다"]',
   1,
   '정답은 **B** 입니다. Secret 의 값은 **base64 인코딩**이라 암호화가 아닙니다. `echo 값 | base64 -d` 로 바로 복원됩니다. 그래서 Secret 을 읽을 수 있는 사람(RBAC)을 제한하고, 필요하면 etcd 암호화(encryption at rest)를 켭니다.

- A 기본 설정에서는 암호화가 아닙니다.
- C 해시가 아니라 가역적인 인코딩입니다.
- D ConfigMap 과 쓰임새는 비슷하지만, 민감 정보용으로 분리되어 접근 제어와 마스킹을 다르게 다룹니다.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 29 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 29, 10, 'OOMKilled 의 원인 알기',
   '컨테이너가 `OOMKilled` 로 종료되었습니다. 원인은 무엇일까요?',
   'OOM 은 Out Of Memory 입니다. 어느 자원의 어떤 한도를 넘었을지 생각해 보세요.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["CPU `limits` 를 초과했다", "노드 디스크가 가득 찼다", "readinessProbe 가 실패했다", "컨테이너가 memory `limits` 를 넘어서 커널이 강제 종료했다"]',
   3,
   '정답은 **D** 입니다. 컨테이너가 설정한 memory `limits` 보다 많이 쓰면 커널의 OOM killer 가 프로세스를 종료하고, `kubectl describe pod` 의 `Last State` 에 `OOMKilled` 가 남습니다. `limits` 를 늘리거나 앱의 메모리 사용을 줄입니다.

- A CPU 는 한도를 넘으면 종료가 아니라 **느려질 뿐**(throttling)입니다.
- B 디스크는 `Evicted` 등 다른 증상입니다.
- C readinessProbe 는 트래픽에서 빼기만 합니다.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 29 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 29, 11, '모든 네임스페이스의 Pod 를 한 번에 보는 명령 고르기',
   '모든 네임스페이스의 Pod 를 **한 번에** 보려면 어떤 명령을 써야 할까요?',
   '기본으로는 현재 네임스페이스의 것만 보입니다. 짧은 옵션과 긴 옵션이 둘 다 있습니다.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["`kubectl get pods --all`", "`kubectl get pods -n all`", "`kubectl get pods -A`", "`kubectl get pods --namespace=*`"]',
   2,
   '정답은 **C** 입니다. `-A`(긴 형태 `--all-namespaces`)는 모든 네임스페이스를 대상으로 합니다.

- A `--all` 은 존재하지 않는 옵션입니다(`unknown flag`).
- B `-n all` 은 이름이 `all` 인 네임스페이스를 찾습니다.
- D 는 `*` 를 와일드카드로 해석하지 않습니다.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 29 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 29, 12, 'Service 의 endpoints 가 비어 있는 흔한 원인 찾기',
   'Service 를 만들었는데 `kubectl get endpoints` 의 ENDPOINTS 가 `<none>` 입니다. Pod 는 `Running` 입니다. 가장 흔한 원인은 무엇일까요?',
   'Service 는 **어떤 Pod 로 보낼지**를 라벨 조건으로 찾습니다.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["Pod 이미지가 오래되었다", "Service 의 `selector` 가 Pod 의 `labels` 와 맞지 않는다", "Service 의 type 이 ClusterIP 다", "네임스페이스에 Pod 가 너무 많다"]',
   1,
   '정답은 **B** 입니다. Service 는 `selector` 와 일치하는 라벨을 가진 Ready 상태의 Pod 를 엔드포인트로 삼습니다. 오타나 불일치가 있으면 엔드포인트가 비어, 접속해도 연결이 안 됩니다. `kubectl describe svc` 의 `Selector` 와 `kubectl get pods --show-labels` 를 비교해 확인합니다.

- A 이미지 버전은 연결과 무관합니다.
- C ClusterIP 는 기본 유형이라 문제가 아닙니다.
- D Pod 개수와 무관합니다.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 29 AND order_index = 12);
