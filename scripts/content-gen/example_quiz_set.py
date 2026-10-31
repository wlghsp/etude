# 예시 생성기: 세트 131 를 만든 스크립트. 이 파일을 그대로 실행하지 않는다 (02·05·06·08 파일과 마이그레이션에 같은 행이 중복으로 붙는다).
# 복사해서 SID, 제목, 설명, display_order, 문제를 바꾼 뒤 쓴다. 사용법: docs/ops/guide_new_pc_setup.md 의 "새 세트 만드는 법".
import json, os, re, sys
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
SID = 131
assert SID != 131, '예시 세트 번호입니다. SID 를 새 번호로 바꾸세요'
DOC = json.dumps([{"title": "GNU Coreutils 문서", "url": "https://www.gnu.org/software/coreutils/manual/"}], ensure_ascii=False)
UNIT_SQL = "INSERT INTO unit (id, category, title, display_order) SELECT 1, '리눅스', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 1);\n"
def terminal(n, title, desc, hint, sol, setup, checks): return dict(n=n, kind='terminal', title=title, desc=desc, hint=hint, sol=sol, setup=setup, checks=checks)
def _choice(n, title, desc, hint, opts, ans, expl): return dict(n=n, kind='choice', title=title, desc=desc, hint=hint, opts=opts, ans=ans, expl=expl)
def chk(label, cmd): return dict(label=label, cmd=cmd)
POS = {n: (n*7+3) % 4 for n in range(1, 60)}
def choice(n, title, desc, hint, opts, ans, expl):
    pos = POS.get(n, ans)
    o = list(opts); right = o.pop(ans); o.insert(pos, right)
    return _choice(n, title, desc, hint, o, pos, expl)
def fill(n, title, desc, hint, tpl, chips, spec, expl): return dict(n=n, kind='fill', title=title, desc=desc, hint=hint, tpl=tpl, chips=chips, spec=spec, expl=expl)
GIT = "rm -f ~/.gitconfig; rm -rf /tmp/lab && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com"
P = '/tmp/lab/proj'
def order(n, title, desc, hint, pieces, spec, expl): return dict(n=n, kind='order', title=title, desc=desc, hint=hint, pieces=pieces, spec=spec, expl=expl)
Q = []
def nf(*a): Q.append(fill(len(Q)+1, *a))
def nc(*a): Q.append(choice(len(Q)+1, *a))
def no(*a): Q.append(order(len(Q)+1, *a))
def c(title, desc, hint, right, wrong, expl): nc(title, desc, hint, [right] + wrong, 0, expl)
c('IP 주소는 무엇일까', '네트워크에서 IP 주소는 무엇을 가리킬까요?', '집 주소처럼 컴퓨터를 찾는 번호예요.', '네트워크에서 컴퓨터(장치)를 구분하는 주소', ['프로그램을 구분하는 번호', '파일의 위치', '사용자의 비밀번호'], 'IP 는 "어느 컴퓨터"를 가리키고, 포트는 그 컴퓨터 안의 "어느 프로그램(문)"을 가리킵니다.')
c('포트는 무엇일까', '`80`, `443`, `22` 같은 포트 번호는 무엇을 구분할까요?', '건물의 호수 같은 거예요.', '한 컴퓨터 안에서 통신하는 프로그램(서비스)', ['컴퓨터의 위치', '파일의 크기', '사용자 계정'], '웹은 보통 80(HTTP), 443(HTTPS), SSH 는 22 포트를 씁니다. IP 와 포트를 합쳐야 정확한 접속 대상이 돼요.')
c('localhost 는 어디일까', '`curl http://localhost:8080` 에서 `localhost` 는 어느 컴퓨터를 가리킬까요?', '"나 자신"을 뜻하는 이름이에요.', '지금 명령을 실행하는 바로 이 컴퓨터(자기 자신)', ['인터넷의 어딘가에 있는 서버', '같은 회사의 다른 서버', '게이트웨이 장비'], '`localhost`(127.0.0.1)는 자기 자신입니다. 컨테이너 안에서는 컨테이너 자신이고, 다른 컨테이너나 호스트가 아니에요.')
c('ping 은 무엇을 확인할까', '`ping 8.8.8.8` 은 무엇을 확인해 줄까요?', '상대에게 작은 신호를 보내 답을 기다려요.', '상대 컴퓨터까지 신호가 오가는지와 걸리는 시간', ['상대 컴퓨터의 파일 목록', '상대의 비밀번호', '상대 서비스의 버전'], 'ping 이 되면 길은 열려 있다는 뜻이지만, 보안 설정으로 ping 만 막아 둔 서버도 많습니다. 안 된다고 서버가 죽었다는 뜻은 아니에요.')
c('curl 은 무엇일까', '`curl http://example.com` 은 무엇을 할까요?', '터미널에서 웹 요청을 보내 보는 도구예요.', '그 주소로 HTTP 요청을 보내고 응답을 터미널에 출력한다', ['웹 브라우저를 설치한다', '웹 서버를 새로 만든다', '파일을 압축한다'], '`curl` 은 API 나 웹 서비스가 응답하는지 확인할 때 가장 많이 씁니다. `-I` 는 헤더만, `-v` 는 과정을 자세히 보여 줘요.')
c('DNS 는 무엇일까', 'DNS 는 어떤 일을 할까요?', '전화번호부와 같아요.', '이름(example.com)을 IP 주소로 바꿔 준다', ['IP 주소를 이름으로 숨긴다', '파일을 암호화한다', '프로세스를 종료한다'], '사람은 이름을, 컴퓨터는 숫자를 씁니다. 이름으로는 접속이 안 되고 IP 로는 된다면 DNS(이름 해석)를 의심하세요.')
c('listen 이라는 상태', '`ss -tln` 결과에서 포트 8080 이 `LISTEN` 입니다. 무슨 뜻일까요?', '문을 열고 손님을 기다리는 상태예요.', '그 포트에서 프로그램이 접속을 기다리고 있다', ['그 포트가 막혀 있다', '그 포트로 방금 접속이 실패했다', '그 포트가 삭제됐다'], '서비스가 떠 있는지는 포트가 LISTEN 인지로 확인합니다. LISTEN 이 없다면 서비스가 안 떠 있는 거예요.')
c('Connection refused', '`curl: (7) Failed to connect ... Connection refused` 는 무슨 뜻일까요?', '"거절"은 그곳에 듣는 프로그램이 없다는 신호예요.', '서버 컴퓨터에는 닿았지만 그 포트에서 듣는 프로그램이 없다', ['이름을 IP 로 바꾸지 못했다', '비밀번호가 틀렸다', '디스크가 가득 찼다'], '서비스가 꺼져 있거나 다른 포트로 떠 있는 경우입니다. 서버 쪽에서 `ss -tln` 으로 확인하세요.')
c('IP 확인하는 명령', '이 컴퓨터가 가진 IP 주소를 확인하는 명령으로 알맞은 것은 무엇일까요?', 'address 의 줄임말이 들어가요.', '`ip addr`', ['`ls -l`', '`df -h`', '`ps aux`'], '`ip addr` 은 네트워크 인터페이스와 IP 를 보여 줍니다. 옛날 명령 `ifconfig` 도 비슷하지만 `ip` 가 표준이에요.')
c('grep -v 의 의미', '`grep -v ERROR app.log` 는 어떤 줄을 보여 줄까요?', 'v 는 반대(invert)를 떠올려 보세요.', 'ERROR 가 **없는** 줄', ['ERROR 가 있는 줄', 'ERROR 의 줄 번호', 'ERROR 의 개수'], '`-v` 는 일치하지 않는 줄을 보여 줍니다. 노이즈를 걸러낼 때 `grep -v 불필요한패턴` 을 이어 붙여요.')
c('grep -c 와 wc -l', '`grep -c ERROR app.log` 는 무엇을 출력할까요?', 'c 는 count(세기)예요.', 'ERROR 가 든 줄의 개수', ['ERROR 가 든 줄 전체', '파일의 전체 줄 수', 'ERROR 의 위치'], '`grep -c` 는 일치하는 줄 수를 바로 셉니다. `grep ERROR app.log | wc -l` 과 같은 결과예요.')
c('grep -r 은 무엇일까', '`grep -r timeout /etc/app` 에서 `-r` 은 무엇을 뜻할까요?', '폴더 안의 하위 폴더까지 들어가요.', '폴더 안의 모든 하위 폴더까지 뒤져서 찾는다', ['대소문자를 구분하지 않는다', '결과를 거꾸로 정렬한다', '일치하는 줄을 지운다'], '`-r` 은 recursive(재귀)입니다. 설정이 어느 파일에 있는지 모를 때 폴더 전체를 훑어 찾는 데 씁니다.')
c('sed 로 바꾸기', '`sed \'s/old/new/\' file.txt` 는 무엇을 할까요?', 's 는 substitute(치환)예요.', '각 줄에서 처음 나오는 old 를 new 로 바꿔 출력한다 (파일 자체는 그대로)', ['파일에서 old 줄을 삭제한다', '파일 이름을 바꾼다', 'old 의 개수를 센다'], '`sed` 는 기본으로 출력만 바꾸고 파일은 건드리지 않습니다. 파일을 바로 수정하려면 `-i` 를 쓰며, 그때는 백업을 권합니다.')
c('awk 로 첫 칸 뽑기', '`awk \'{print $1}\' access.log` 는 무엇을 출력할까요?', '$1 은 첫 번째 칸이에요.', '각 줄의 첫 번째 칸(공백으로 나뉜 첫 단어)', ['각 줄의 마지막 단어', '파일의 첫 줄만', '줄의 개수'], '`awk` 는 칸 단위 처리에 강합니다. 접속 로그의 첫 칸이 보통 IP 라서, IP 별 개수를 세는 데 `awk | sort | uniq -c` 를 씁니다.')
nf('IP 주소 보기', '이 컴퓨터의 IP 주소를 보는 명령입니다. 빈칸을 채우세요.', 'address 의 줄임말이에요.', 'ip {0}', ['addr', 'link', 'route', 'dns'], [0], '`ip addr` 은 주소, `ip route` 는 길(라우팅), `ip link` 는 인터페이스 상태를 보여 줍니다.')
nf('열린 포트 보기', '듣고 있는(LISTEN) TCP 포트를 숫자로 보는 명령입니다. 빈칸을 채우세요.', 'tcp, listening, numeric 의 첫 글자를 모았어요.', 'ss -{0}', ['tln', 'abc', 'xyz', 'ls'], [0], '`ss -tln` 은 열린 TCP 포트를, `-p` 를 더하면 어느 프로세스인지도 보여 줍니다(권한 필요).')
nf('ping 횟수 정하기', '`ping` 을 **3번만** 보내고 끝내는 옵션을 채우세요.', 'count 의 첫 글자예요.', 'ping {0} 3 example.com', ['-c', '-n', '-t', '-s'], [0], '리눅스의 `ping` 은 멈추지 않고 계속 보내서 Ctrl+C 로 끝내야 합니다. `-c 횟수` 를 쓰면 스크립트에서도 편해요.')
nf('응답 헤더만 보기', '`curl` 로 응답 본문 없이 **헤더만** 확인하는 옵션을 채우세요.', 'head 를 뜻하는 대문자 I 예요.', 'curl {0} http://localhost:8080', ['-I', '-v', '-o', '-s'], [0], '`-I` 는 상태 코드(200, 404)와 헤더만 가져옵니다. 서비스가 살아 있는지 빠르게 볼 때 유용해요.')
nf('포트 열렸는지 확인', '서버 `192.0.2.10` 의 22번 포트가 **열렸는지만** 가볍게 확인하는 명령입니다. 옵션을 채우세요.', 'zero-I/O 와 verbose 의 약자예요.', 'nc {0} 192.0.2.10 22', ['-zv', '-ls', '-ok', '-rf'], [0], '`nc -zv 호스트 포트` 는 접속만 시도하고 결과를 알려 줍니다. `succeeded` 가 보이면 포트가 열려 있는 거예요.')
nf('줄 번호와 함께 찾기', '`app.log` 에서 `ERROR` 를 **줄 번호와 함께** 찾는 옵션을 채우세요.', 'number 의 첫 글자예요.', 'grep {0} ERROR app.log', ['-n', '-v', '-c', '-r'], [0], '`-n` 은 줄 번호를 붙여 줍니다. 로그의 몇 번째 줄 근처인지 볼 때 편해요.')
nf('일치하지 않는 줄 보기', '`app.log` 에서 `DEBUG` 가 **없는** 줄만 보는 옵션을 채우세요.', '반대(invert)의 v 예요.', 'grep {0} DEBUG app.log', ['-v', '-n', '-i', '-c'], [0], '`-v` 는 반대 조건입니다. 시끄러운 DEBUG 줄을 빼고 진짜 문제를 보는 데 씁니다.')
nf('큰 수 먼저 정렬', '숫자를 **큰 것부터** 정렬해 보여 주는 옵션 조합을 채우세요.', '숫자(numeric)로, 거꾸로(reverse)예요.', 'sort {0} numbers.txt', ['-nr', '-ab', '-xy', '-zz'], [0], '`sort -n` 은 숫자로, `-r` 은 거꾸로 정렬합니다. 문자로 정렬하면 `10` 이 `2` 보다 앞에 오는 것에 주의하세요.')
nf('빈도 순위 만들기', '정렬된 줄을 `uniq -c` 로 센 뒤 **많은 순서로** 다시 정렬하는 마지막 단계를 채우세요.', '이미 앞에서 배운 옵션 조합이에요.', 'sort names.txt | uniq -c | sort {0}', ['-rn', '-ab', '-xy', '-zz'], [0], '`sort | uniq -c | sort -rn` 은 로그 분석의 대표 조합입니다. 가장 많이 나온 값이 위에 와요.')
nf('글자 바꾸기', '각 줄에서 `old` 를 `new` 로 바꿔 출력하는 `sed` 의 빈칸을 채우세요.', 'substitute 의 첫 글자예요.', "sed '{0}/old/new/' file.txt", ['s', 'd', 'p', 'q'], [0], '`s/찾을것/바꿀것/` 이 치환입니다. 뒤에 `g` 를 붙이면 한 줄의 모든 일치를 바꿔요.')
nf('마지막 칸 뽑기', '`awk` 로 각 줄의 **마지막 칸**을 출력하는 빈칸을 채우세요.', 'Number of Fields 를 뜻하는 변수예요.', "awk '{print ${0}}' file.txt", ['NF', 'NR', 'FS', 'OFS'], [0], '`$NF` 는 마지막 칸입니다. `NF` 는 칸의 개수, `NR` 은 줄 번호예요.')
nf('결과를 화면과 파일에 둘 다', '명령의 출력을 **화면에도 보여 주고 파일에도 저장**하는 명령입니다. 빈칸을 채우세요.', 'T 자 배관 모양에서 이름이 왔어요.', 'ls | {0} out.txt', ['tee', 'cat', 'cut', 'tr'], [0], '`tee` 는 입력을 화면과 파일로 동시에 보냅니다. 추가는 `tee -a` 예요.')
nf('이름으로 접속 확인', '`example.com` 의 **IP 주소를 조회**하는 도구입니다. 빈칸을 채우세요.', 'name server lookup 의 줄임말이에요.', '{0} example.com', ['nslookup', 'traceroute', 'ping6', 'netstat'], [0], '`nslookup`(또는 `dig`)은 이름을 IP 로 바꿔 보여 줍니다. 이름 해석이 되는지 따로 확인할 수 있어요.')
no('서비스에 연결이 안 될 때', '이름으로 접속이 안 될 때의 점검 순서입니다. 순서에 맞게 놓아 보세요.', '내 주소 → 이름 → 도달 → 포트 순서예요.', ['`ip addr` 로 내 IP 가 정상인지 본다', '`nslookup 이름` 으로 이름이 IP 로 바뀌는지 본다', '`ping IP` 로 상대에게 닿는지 본다', '`nc -zv IP 포트` 로 포트가 열렸는지 본다'], [0, 1, 2, 3], '아래 층(내 쪽)에서 위 층으로 좁혀 가면 원인 범위가 줄어듭니다. ping 이 막힌 환경에서는 포트 확인이 더 정확해요.')
no('로그에서 IP 별 접속 수 세기', '접속 로그의 첫 칸이 IP 입니다. IP 별 접속 횟수를 많은 순으로 보는 조합입니다. 순서에 맞게 놓아 보세요.', '뽑기 → 정렬 → 세기 → 순위 순서예요.', ["`awk '{print $1}' access.log`", '`sort`', '`uniq -c`', '`sort -rn`'], [0, 1, 2, 3], '`uniq` 는 이웃한 줄만 합치므로 먼저 `sort` 가 필요합니다. 이 조합은 로그 분석에서 매우 자주 써요.')
no('설정 파일에서 값 찾기', '설정 폴더에서 `timeout` 설정이 어느 파일에 있는지 찾는 순서입니다. 순서에 맞게 놓아 보세요.', '찾기 → 줄 번호 → 열어 보기 순서예요.', ['`grep -rn timeout /etc/app` 로 파일과 줄 번호를 찾는다', '찾은 파일을 `cat` 이나 `less` 로 주변을 본다', '값을 확인하고 수정한다', '수정한 뒤 `grep` 으로 다시 확인한다'], [0, 1, 2, 3], '`grep -rn` 은 폴더 전체에서 파일 이름과 줄 번호까지 알려 줍니다. 수정 전에 백업하는 습관도 잊지 마세요.')
no('포트가 열렸는지 로컬에서 확인', '내 컴퓨터에서 서비스가 8080 으로 떠 있는지 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '포트 목록 → 응답 확인 순서예요.', ['`ss -tln` 으로 8080 이 LISTEN 인지 본다', '`curl -I http://localhost:8080` 으로 응답을 본다', '응답이 없으면 서비스 로그를 본다', '원인을 고치고 다시 `curl` 로 확인한다'], [0, 1, 2, 3], '포트가 열려 있는지(LISTEN)와 실제로 응답하는지(curl)는 다른 확인입니다. 둘 다 해 보세요.')

def sq(s): return s.replace('\\', '\\\\').replace("'", "''")
def lit(s): return 'NULL' if s is None else "'" + sq(s) + "'"

def j(o): return json.dumps(o, ensure_ascii=False)
def sh(c): return ['sh', '-c', c]

rows = []; answers = {}
for q in Q:
    k = q['kind']
    if k == 'terminal':
        grade = ' && '.join(f'( {c["cmd"]} )' for c in q['checks'])
        answers[str(q['n'])] = q['sol']
        vals = [lit(q['title']), lit(q['desc']), lit(q['hint']), lit(q['sol']), lit(j(sh(q['setup']))), lit(j(sh(grade))), "'terminal'", 'NULL','NULL','NULL','NULL','NULL', lit(j([dict(label=c['label'], cmd=sh(c['cmd'])) for c in q['checks']])), lit(DOC)]
    elif k == 'choice':
        vals = [lit(q['title']), lit(q['desc']), lit(q['hint']), 'NULL','NULL', "'[]'", "'choice'", lit(j(q['opts'])), str(q['ans']), lit(q['expl']), 'NULL','NULL','NULL', 'NULL']
    elif k == 'fill':
        vals = [lit(q['title']), lit(q['desc']), lit(q['hint']), 'NULL','NULL', "'[]'", "'fill'", lit(j(q['chips'])), 'NULL', lit(q['expl']), lit(j(q['spec'])), lit(q['tpl']), 'NULL', 'NULL']
    else:
        vals = [lit(q['title']), lit(q['desc']), lit(q['hint']), 'NULL','NULL', "'[]'", "'order'", lit(j(q['pieces'])), 'NULL', lit(q['expl']), lit(j(q['spec'])), 'NULL','NULL','NULL']
    rows.append(f"({SID}, {q['n']}, " + ', '.join(vals) + ')')

COLS = 'quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs'
TITLE = '리눅스 쉬운 문제 3: 네트워크 기본과 텍스트 도구 한 줄씩'
DESC = '리눅스 네트워크와 텍스트 처리의 기본을 한 개념씩 쉬운 문제로 반복합니다. IP·포트·localhost·DNS, ping·curl·ss·nc·ip addr 의 쓰임과 refused 읽기, grep -v/-c/-r/-n, sort -nr·uniq -c, sed 치환, awk 칸 뽑기, tee, 연결이 안 될 때와 로그에서 IP 별 접속 수 세기의 점검 순서를 짧은 객관식·빈칸·순서 문제로 익힙니다.'
body = f"-- 세트 {SID}: {TITLE}\n-- 기본기 사다리(docs/specs/spec_foundations_ladder.md). 정답·해설은 서버만 안다. 실습 문제의 grade_cmd 는 checks 의 조건을 && 로 이은 것과 같다.\nINSERT INTO quest ({COLS}) VALUES\n  " + ',\n  '.join(rows) + ';\n'
open(f'{ROOT}/backend/db/03_quest_set{SID}.sql','w').write(body)
json.dump(dict(setId=SID, answers=answers), open(f'{ROOT}/backend/verify/set{SID}.json','w'), ensure_ascii=False, indent=2)

setrow = f"  ({SID}, {lit(TITLE)}, {lit(DESC)}, 'quiz', '리눅스')"
p = f'{ROOT}/backend/db/02_quest_set.sql'
s = open(p).read().rstrip('\n')
assert s.endswith("');")
s = s[:-1] + ',\n' + setrow + ';\n'
open(p,'w').write(s)
open(f'{ROOT}/backend/db/05_display_order.sql','a').write(f'UPDATE quest_set SET display_order = 9 WHERE id = {SID};\n')
open(f'{ROOT}/backend/db/06_units.sql','a').write(UNIT_SQL + f'UPDATE quest_set SET unit_id = 1 WHERE id = {SID};\n')
open(f'{ROOT}/backend/db/08_set_icons.sql','a').write(f"UPDATE quest_set SET icon = '🔌' WHERE id = {SID};\n")

mig_unit = UNIT_SQL
mig = f"""-- 미들웨어 세트 {SID}. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set{SID}.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
{mig_unit}INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT {SID}, {lit(TITLE)}, {lit(DESC)}, 'quiz', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = {SID});
UPDATE quest_set SET display_order = 9, unit_id = (SELECT id FROM unit WHERE id = 1), icon = '🔌' WHERE id = {SID};
"""
for q, r in zip(Q, rows):
    mig += f"\nINSERT INTO quest ({COLS})\nSELECT {r[1:-1]}\nFROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = {SID} AND order_index = {q['n']});\n"
open(f'{ROOT}/backend/db/migrations/2026-10-31_linux_easy3_set{SID}.sql','w').write(mig)
print('ok', len(Q))
