-- 세트 15: 리눅스 로그와 텍스트 처리 (order 1~12)
-- 샘플 데이터(/var/log/app, /etc/app)는 etude-linux 이미지에 들어 있다 (backend/docker/samples/).
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (15,  1, '로그 파일의 마지막 5줄만 저장하기',
   '장애가 났을 때는 로그의 **가장 최근 내용**부터 봅니다. 로그가 아무리 길어도 끝부분만 보면 됩니다.

`/var/log/app/app.log` 의 마지막 5줄을 `/tmp/last5.txt` 에 저장하세요.',
   '`tail -n <줄수> <파일>` 은 파일의 끝에서 N줄을 출력합니다. 화면에 나온 결과를 파일로 저장하려면 `>` 를 씁니다.
확인: `cat /tmp/last5.txt`',
   '# 마지막 5줄을 파일로 저장
tail -n 5 /var/log/app/app.log > /tmp/last5.txt

# > 는 화면에 나올 출력을 파일로 보냅니다 (기존 내용은 덮어씁니다)',
   NULL,
   '["sh", "-c", "[ -s /tmp/last5.txt ] && tail -n 5 /var/log/app/app.log | cmp -s - /tmp/last5.txt"]'),

  (15,  2, '로그에서 ERROR 줄만 골라 저장하기',
   '수천 줄의 로그에서 문제는 보통 `ERROR` 가 들어간 줄에 있습니다. `grep` 으로 원하는 줄만 걸러냅니다.

`/var/log/app/app.log` 에서 `ERROR` 가 들어간 줄만 `/tmp/errors.txt` 에 저장하세요.',
   '`grep <찾을글자> <파일>` 은 그 글자가 들어간 줄만 출력합니다. 결과를 `>` 로 파일에 저장하세요.
확인: `cat /tmp/errors.txt`',
   'grep ERROR /var/log/app/app.log > /tmp/errors.txt

# grep 은 글자가 들어간 줄만 출력합니다',
   NULL,
   '["sh", "-c", "[ -s /tmp/errors.txt ] && grep ERROR /var/log/app/app.log | cmp -s - /tmp/errors.txt"]'),

  (15,  3, 'ERROR 가 몇 번 났는지 세기',
   '문제의 심각도는 에러가 얼마나 자주 났는지로 가늠합니다.

`/var/log/app/app.log` 에서 `ERROR` 가 들어간 줄이 **몇 줄인지** 숫자만 `/tmp/error_count.txt` 에 저장하세요. (예: `5`)',
   '`grep -c <글자> <파일>` 은 일치하는 줄의 **개수**를 출력합니다. 또는 `grep ... | wc -l` 로 줄 수를 셀 수도 있습니다.',
   'grep -c ERROR /var/log/app/app.log > /tmp/error_count.txt

# -c 는 줄을 출력하는 대신 개수를 셉니다
# (다른 방법) grep ERROR /var/log/app/app.log | wc -l > /tmp/error_count.txt',
   NULL,
   '["sh", "-c", "[ \\"$(tr -d ''[:space:]'' < /tmp/error_count.txt)\\" = \\"$(grep -c ERROR /var/log/app/app.log)\\" ]"]'),

  (15,  4, 'ERROR 와 WARN 을 한 번에 골라내기',
   '문제의 징후는 `ERROR` 뿐 아니라 `WARN`(경고)에도 있습니다. 두 가지를 한 번에 찾습니다.

`/var/log/app/app.log` 에서 `ERROR` **또는** `WARN` 이 들어간 줄을 모두 `/tmp/err_warn.txt` 에 저장하세요. (원래 순서 그대로)',
   '`grep -E ''<A>|<B>'' <파일>` 에서 `-E` 는 확장 정규식, `|` 는 ''A 또는 B'' 입니다. 패턴 전체를 작은따옴표로 감싸세요.',
   'grep -E ''ERROR|WARN'' /var/log/app/app.log > /tmp/err_warn.txt

# -E : 확장 정규식 사용, | : 또는',
   NULL,
   '["sh", "-c", "[ -s /tmp/err_warn.txt ] && grep -E ''ERROR|WARN'' /var/log/app/app.log | cmp -s - /tmp/err_warn.txt"]'),

  (15,  5, 'DEBUG 줄을 빼고 보기',
   'DEBUG 로그는 양이 많아 장애 분석에 방해가 되곤 합니다. 특정 글자가 **없는** 줄만 남깁니다.

`/var/log/app/app.log` 에서 `DEBUG` 가 들어간 줄을 제외한 나머지를 `/tmp/no_debug.txt` 에 저장하세요.',
   '`grep -v <글자> <파일>` 의 `-v` 는 반전(invert)이라 그 글자가 **없는** 줄만 출력합니다.',
   'grep -v DEBUG /var/log/app/app.log > /tmp/no_debug.txt

# -v : 일치하지 않는 줄만 출력',
   NULL,
   '["sh", "-c", "[ -s /tmp/no_debug.txt ] && grep -v DEBUG /var/log/app/app.log | cmp -s - /tmp/no_debug.txt"]'),

  (15,  6, '에러 메시지까지 파일에 저장하기',
   '명령의 출력은 두 갈래입니다. 정상 출력(표준 출력)과 에러 메시지(표준 에러)이고, `>` 는 **정상 출력만** 파일로 보냅니다. 에러까지 함께 남기는 것이 운영 로그의 기본입니다.

`ls /etc/hostname /nonexistent` 를 실행하세요. (`/nonexistent` 는 없는 경로라 에러가 납니다.)
정상 출력과 에러 메시지를 **모두** `/tmp/both.txt` 에 저장하고, 화면에는 아무것도 나오지 않게 하세요.',
   '`> 파일` 은 정상 출력(1번)만 보냅니다. 에러(2번)도 같은 곳으로 보내려면 명령 끝에 `2>&1` 을 붙입니다.
형태: `<명령> > <파일> 2>&1`
확인: `cat /tmp/both.txt`',
   'ls /etc/hostname /nonexistent > /tmp/both.txt 2>&1

# > /tmp/both.txt : 정상 출력(1번)을 파일로
# 2>&1           : 에러(2번)를 1번이 가는 곳(같은 파일)으로',
   NULL,
   '["sh", "-c", "grep -q ''/etc/hostname'' /tmp/both.txt && grep -q ''No such file'' /tmp/both.txt"]'),

  (15,  7, '기존 내용을 지우지 않고 이어 쓰기',
   '`>` 는 파일을 **덮어쓰기** 때문에 로그나 설정을 날려 먹는 흔한 사고가 납니다. 내용을 뒤에 붙이는 방법을 익힙니다.

`/tmp/notes.txt` 에는 이미 `first line` 이 들어 있습니다. 기존 내용은 지우지 말고, 그 뒤에 `second line` 한 줄을 추가하세요.

완료 조건: 파일이 `first line`, `second line` 두 줄이어야 합니다.',
   '`>` 는 덮어쓰기, `>>` 는 이어쓰기입니다.
형태: `echo ''<내용>'' >> <파일>`
확인: `cat /tmp/notes.txt`',
   'echo ''second line'' >> /tmp/notes.txt

# >> 는 파일 끝에 덧붙입니다 (> 를 쓰면 first line 이 사라집니다)',
   '["sh", "-c", "echo ''first line'' > /tmp/notes.txt"]',
   '["sh", "-c", "[ \\"$(head -n 1 /tmp/notes.txt)\\" = ''first line'' ] && [ \\"$(sed -n 2p /tmp/notes.txt)\\" = ''second line'' ] && [ \\"$(wc -l < /tmp/notes.txt)\\" -eq 2 ]"]'),

  (15,  8, '접속 로그에서 IP 주소만 뽑기',
   '웹 접속 로그는 한 줄이 `IP - - [시각] "요청" 상태코드 크기` 형태입니다. 누가 접속했는지 보려면 줄마다 첫 번째 칸(IP)만 필요합니다.

`/var/log/app/access.log` 의 각 줄에서 **첫 번째 칸(IP)** 만 뽑아 `/tmp/ips.txt` 에 한 줄씩 저장하세요.',
   '칸은 공백으로 나뉩니다. 두 가지 방법이 있습니다.
- `cut -d'' '' -f1 <파일>` : 구분자를 공백(`-d'' ''`)으로 하고 1번째 칸(`-f1`)
- `awk ''{print $1}'' <파일>` : 1번째 칸을 출력',
   'cut -d'' '' -f1 /var/log/app/access.log > /tmp/ips.txt

# (다른 방법) awk ''{print $1}'' /var/log/app/access.log > /tmp/ips.txt',
   NULL,
   '["sh", "-c", "[ -s /tmp/ips.txt ] && awk ''{print $1}'' /var/log/app/access.log | cmp -s - /tmp/ips.txt"]'),

  (15,  9, '중복 없는 접속 IP 목록 만들기',
   '같은 IP 가 여러 번 접속해 목록이 깁니다. 어떤 IP 들이 있었는지만 보려면 중복을 없앱니다.

`/var/log/app/access.log` 에 접속한 IP 를 **중복 없이, 정렬해서** `/tmp/unique_ips.txt` 에 저장하세요.',
   '`uniq` 는 **바로 이웃한** 같은 줄만 합칩니다. 그래서 먼저 `sort` 로 정렬해야 합니다.
형태: `<IP 뽑기> | sort | uniq > <파일>` (IP 뽑기는 앞 문제 참고)',
   'awk ''{print $1}'' /var/log/app/access.log | sort | uniq > /tmp/unique_ips.txt

# | (파이프) : 앞 명령의 출력을 뒤 명령의 입력으로 넘깁니다
# sort 로 같은 IP 를 이웃하게 모은 뒤 uniq 로 중복을 제거합니다',
   NULL,
   '["sh", "-c", "[ -s /tmp/unique_ips.txt ] && awk ''{print $1}'' /var/log/app/access.log | sort -u | cmp -s - /tmp/unique_ips.txt"]'),

  (15, 10, '접속이 가장 많은 IP 상위 3개 찾기',
   '이상 징후(공격, 오작동)는 특정 IP 의 접속이 비정상적으로 많은 모습으로 나타나곤 합니다.

`/var/log/app/access.log` 에서 접속 횟수가 많은 IP **상위 3개**를 횟수와 함께, 많은 순서대로 `/tmp/top3.txt` 에 저장하세요.
형식 예: `6 10.0.0.1` (횟수 IP)',
   'IP 뽑기 → `sort` → `uniq -c`(횟수 세기) → `sort -rn`(숫자 큰 순) → `head -n 3`(위 3개) 순서로 파이프(`|`)를 이어 갑니다. `uniq -c` 는 줄 앞에 횟수를 붙여 줍니다.',
   'awk ''{print $1}'' /var/log/app/access.log | sort | uniq -c | sort -rn | head -n 3 > /tmp/top3.txt

# uniq -c  : 같은 줄이 몇 번 나왔는지 앞에 붙임
# sort -rn : 숫자(n)로 큰 것부터(r) 정렬
# head -n 3: 위에서 3줄만',
   NULL,
   '["sh", "-c", "[ -s /tmp/top3.txt ] && [ \\"$(awk ''{print $1,$2}'' /tmp/top3.txt)\\" = \\"$(awk ''{print $1}'' /var/log/app/access.log | sort | uniq -c | sort -rn | head -n 3 | awk ''{print $1,$2}'')\\" ]"]'),

  (15, 11, '500 에러가 난 요청의 URL 만 뽑기',
   '상태 코드 `500` 은 서버 내부 오류입니다. 어떤 주소에서 오류가 났는지 찾습니다.

`/var/log/app/access.log` 에서 **상태 코드(9번째 칸)가 500** 인 줄의 **URL(7번째 칸)** 만 뽑아 `/tmp/err_urls.txt` 에 저장하세요.',
   '`awk` 는 ''조건 {동작}'' 형태입니다: `awk ''$9==500 {print $7}'' <파일>`
`$9` 는 9번째 칸(상태 코드), `$7` 은 7번째 칸(URL)입니다. 칸 번호가 헷갈리면 `awk ''{print $1, $7, $9}'' <파일> | head` 로 먼저 확인해 보세요.',
   'awk ''$9==500 {print $7}'' /var/log/app/access.log > /tmp/err_urls.txt

# $9==500 : 9번째 칸이 500 인 줄만
# {print $7} : 그 줄의 7번째 칸(URL)을 출력',
   NULL,
   '["sh", "-c", "[ -s /tmp/err_urls.txt ] && awk ''$9==500 {print $7}'' /var/log/app/access.log | cmp -s - /tmp/err_urls.txt"]'),

  (15, 12, '설정 파일의 값 한 줄 바꾸기',
   '설정 값을 바꿀 때 파일을 열어 고치지 않고도 명령어로 바꿀 수 있습니다. 스크립트로 자동화할 때의 기본입니다.

`/etc/app/app.conf` 에서 `port=8080` 을 `port=9090` 으로 바꾸세요. 다른 줄은 그대로여야 합니다.
확인: `cat /etc/app/app.conf`',
   '`sed -i ''s/<찾을것>/<바꿀것>/'' <파일>` 형태입니다. `-i` 는 파일을 직접 수정(in-place), `s/A/B/` 는 A 를 B 로 바꿉니다.',
   'sed -i ''s/port=8080/port=9090/'' /etc/app/app.conf

# -i       : 결과를 화면이 아니라 파일에 바로 반영
# s/A/B/   : A 를 B 로 치환',
   NULL,
   '["sh", "-c", "F=/etc/app/app.conf; grep -qx ''port=9090'' $F && grep -qx ''host=0.0.0.0'' $F && grep -qx ''timeout=30'' $F && ! grep -q 8080 $F && [ \\"$(wc -l < $F)\\" -eq 6 ]"]');
