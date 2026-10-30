-- 세트 36(리눅스 이름으로 통신하기) 추가와 표시 순서 지정(세트 18 바로 뒤). 여러 번 실행해도 안전하도록 NOT EXISTS 가드를 둔다 (원본: 02_quest_set.sql, 03_quest_set36.sql, 05_display_order.sql).
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 36, '리눅스 이름으로 통신하기', '서버끼리 이름으로 통신하게 만드는 /etc/hosts 사용법(여러 서버 등록, 별칭, 옛 IP 고치기, 백업과 복구)과, 이름으로 포트에 접속되는지 확인하는 법을 연습합니다. 접속 오류 메시지가 어느 단계(이름 해석, 포트, 서비스)의 문제인지 읽고 확인 순서를 익힙니다.', 'linux', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 36);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 36, 1, '서버 3대를 /etc/hosts 에 한 번에 등록하기',
   '서버끼리 **이름으로** 통신하려면, 이름을 IP 로 바꿔 주는 곳이 필요합니다. 가장 간단한 방법이 `/etc/hosts` 파일에 `IP 이름` 을 한 줄씩 적는 것입니다. 시스템은 DNS 서버를 보기 **전에** 이 파일을 먼저 봅니다.

`/etc/hosts` 에 아래 세 서버를 등록하세요. **기존 내용(localhost 등)은 지우지 마세요.**
- `10.0.0.11` → `web1`
- `10.0.0.12` → `web2`
- `10.0.0.13` → `db`

이름이 제대로 해석되는지는 **`getent hosts 이름`** 으로 확인합니다. 이 명령은 시스템이 실제로 이름을 해석하는 방식 그대로(먼저 `/etc/hosts`, 없으면 DNS) 그 이름이 **어떤 IP 로 바뀌는지** 보여 줍니다. 해석이 안 되면 아무것도 출력하지 않습니다.

완료 조건: `getent hosts web1`, `web2`, `db` 가 각각 위 IP 로 해석되고 `localhost` 도 그대로여야 합니다.',
   '`echo "10.0.0.11 web1" >> /etc/hosts` 처럼 한 줄씩 **이어쓰기(`>>`)** 로 추가합니다. (형식: `IP주소 공백 이름`) 한 번에 여러 줄은 `printf ''%s\\n'' "줄1" "줄2" >> /etc/hosts` 로 쓸 수 있습니다. **`>` 를 쓰면 파일 전체가 지워져** `localhost` 까지 사라집니다. 확인은 `getent hosts web1`(이름 → IP 해석 결과 출력) 또는 `cat /etc/hosts` 로 합니다. 파일을 직접 열어 고치고 싶다면 `vi /etc/hosts` 로 열어 줄을 추가하고 저장(`:wq`)해도 됩니다.',
   'printf ''%s\\n'' "10.0.0.11 web1" "10.0.0.12 web2" "10.0.0.13 db" >> /etc/hosts

# >> : 기존 내용 뒤에 이어쓰기 (> 는 파일을 지워서 localhost 도 사라짐)
# 형식 : IP주소 이름
getent hosts web1',
   NULL,
   '["sh", "-c", "getent hosts web1 | grep -q 10.0.0.11 && getent hosts web2 | grep -q 10.0.0.12 && getent hosts db | grep -q 10.0.0.13 && getent hosts localhost >/dev/null"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 36 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 36, 2, '한 IP 에 이름을 여러 개 붙이기 (별칭)',
   '서버 하나를 **여러 이름**으로 부르는 경우가 많습니다. (예: 짧은 이름 `api` 와 전체 이름 `api.internal`) `/etc/hosts` 는 한 줄에 **이름을 여러 개** 적을 수 있습니다. `IP 이름1 이름2 ...` 형태입니다.

IP `10.0.0.20` 이 `api` 와 `api.internal` **두 이름 모두**로 해석되게 하세요. (한 줄로)

완료 조건: `getent hosts api` 와 `getent hosts api.internal` 이 모두 `10.0.0.20` 이어야 합니다.',
   '`echo "10.0.0.20 api api.internal" >> /etc/hosts` 처럼 IP 뒤에 이름을 **공백으로 이어서** 적습니다. 첫 이름이 공식 이름이고 뒤는 별칭이지만, 어느 이름으로 찾아도 같은 IP 가 나옵니다. 확인은 두 이름을 각각 `getent hosts` 로 해 봅니다.',
   'echo "10.0.0.20 api api.internal" >> /etc/hosts

# IP 뒤에 이름을 공백으로 여러 개 : 모두 같은 IP 로 해석됨
getent hosts api
getent hosts api.internal',
   NULL,
   '["sh", "-c", "getent hosts api | grep -q 10.0.0.20 && getent hosts api.internal | grep -q 10.0.0.20 && getent hosts localhost >/dev/null"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 36 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 36, 3, '서버를 옮긴 뒤 옛 IP 줄을 새 IP 로 고치기',
   '서버를 옮기거나 IP 가 바뀌면 `/etc/hosts` 의 줄도 고쳐야 합니다. **옛 줄을 지우지 않고 새 줄만 추가하면** 같은 이름이 IP 두 개로 해석되어, 어느 서버로 갈지 알 수 없게 됩니다.

`db` 서버가 `10.0.0.30` 에서 **`10.0.0.31`** 로 옮겨졌습니다. `/etc/hosts` 에서 `db` 가 새 IP **하나로만** 해석되게 고치세요.

완료 조건: `getent hosts db` 결과가 `10.0.0.31` 한 줄뿐이어야 하고 `localhost` 는 그대로여야 합니다.',
   '먼저 `getent hosts db`(이름 → IP 해석 결과)와 `cat /etc/hosts` 로 현재 상태를 확인하세요. 파일을 고치는 **방법은 자유**이고, 결과만 맞으면 됩니다. 가장 쉬운 방법은 `vi /etc/hosts` 로 열어 옛 줄(`10.0.0.30 db`)의 IP 를 `10.0.0.31` 로 고치고 저장(`:wq`)하는 것입니다. 명령으로 하려면 ① 옛 줄을 뺀 내용을 임시 파일에 만들고 `grep -v '' db$'' /etc/hosts > /tmp/hosts.new` ② 새 줄을 추가하고 `echo "10.0.0.31 db" >> /tmp/hosts.new` ③ 내용을 덮어씁니다 `cat /tmp/hosts.new > /etc/hosts`. (`grep -v` 는 패턴이 들어 있는 줄을 **제외**, `$` 는 줄의 끝)',
   'grep -v '' db$'' /etc/hosts > /tmp/hosts.new
echo "10.0.0.31 db" >> /tmp/hosts.new
cat /tmp/hosts.new > /etc/hosts

# grep -v '' db$'' : db 로 끝나는 줄(옛 줄)만 뺌
# cat 임시 > /etc/hosts : 임시 파일의 내용으로 덮어쓴다
# (vi /etc/hosts 로 직접 고치고 :wq 로 저장해도 됩니다)
# 참고: 이 연습 환경에서는 /etc/hosts 가 특수한 파일이라 sed -i 는 동작하지 않습니다
getent hosts db',
   '["sh", "-c", "echo ''10.0.0.30 db'' >> /etc/hosts"]',
   '["sh", "-c", "getent hosts db | grep -q 10.0.0.31 && ! getent hosts db | grep -q 10.0.0.30 && [ \\"$(getent hosts db | wc -l)\\" = 1 ] && getent hosts localhost >/dev/null"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 36 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 36, 5, '이름으로 포트에 접속되는지 확인하기 (nc)',
   '통신이 되려면 **이름 → IP → 포트** 가 모두 맞아야 합니다. 이 서버의 `9000` 포트에는 서비스가 떠 있지만, 아직 `appsrv` 라는 **이름은 등록되어 있지 않습니다.** `nc -zv 이름 포트` 는 그 포트에 접속이 되는지 확인합니다. (`-z` 접속만 확인, `-v` 결과를 자세히 표시)

1. `appsrv` 가 `127.0.0.1` 로 해석되게 `/etc/hosts` 에 등록합니다.
2. `nc -zv appsrv 9000` 의 **결과 메시지**를 `/tmp/nc_result.txt` 에 저장하세요. (`nc -v` 의 결과 메시지는 오류 출력으로 나옵니다)

완료 조건: `/tmp/nc_result.txt` 에 접속 성공 메시지(`succeeded`)가 있어야 합니다.',
   '이름을 등록하려면 `echo "127.0.0.1 appsrv" >> /etc/hosts` 입니다. 등록 전에 `nc -zv appsrv 9000` 을 실행하면 이름을 찾지 못한다는 오류가 나옵니다. 등록 뒤 결과를 저장할 때, `nc -v` 의 메시지는 **표준 에러(2번)** 로 나오므로 `2>&1` 로 1번에 합쳐야 파일에 들어갑니다. 예: `nc -zv appsrv 9000 > /tmp/nc_result.txt 2>&1`',
   'echo "127.0.0.1 appsrv" >> /etc/hosts
nc -zv appsrv 9000 > /tmp/nc_result.txt 2>&1

# 먼저 이름을 등록해야 nc 가 appsrv 를 IP 로 바꿀 수 있다
# nc -v 의 메시지는 표준 에러라 2>&1 로 합쳐서 저장
cat /tmp/nc_result.txt',
   '["sh", "-c", "nohup perl -MIO::Socket::INET -e ''$s = IO::Socket::INET->new(LocalAddr => \\"127.0.0.1\\", LocalPort => 9000, Listen => 5, ReuseAddr => 1) or die; sleep 3600'' >/dev/null 2>&1 & sleep 1"]',
   '["sh", "-c", "grep -q succeeded /tmp/nc_result.txt"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 36 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 36, 6, '고치기 전에 /etc/hosts 를 백업하고 복구하기',
   '설정 파일을 고치기 전에는 **백업**을 만들어 두면, 잘못 고쳤을 때 바로 되돌릴 수 있습니다. 운영 서버에서 `/etc/hosts` 를 고치다 실수하면 통신이 끊기므로 꼭 필요한 습관입니다.

아래 순서대로 하세요.
1. `/etc/hosts` 를 `/etc/hosts.bak` 로 **백업**합니다.
2. `/etc/hosts` 에 `10.0.0.50 temp` 를 **추가**합니다.
3. 수정된 상태를 확인용으로 `/tmp/hosts.edited` 에 복사해 둡니다.
4. 백업(`/etc/hosts.bak`)으로 `/etc/hosts` 를 **되돌립니다.**

완료 조건: `/etc/hosts.bak` 이 있고, `/tmp/hosts.edited` 에는 `temp` 줄이 있고, 최종 `/etc/hosts` 에는 `temp` 줄이 없어야 합니다.',
   '`cp 원본 사본` 은 파일을 복사합니다. 백업은 `cp /etc/hosts /etc/hosts.bak`, 복구는 반대로 `cp /etc/hosts.bak /etc/hosts` 입니다. 줄 추가는 `echo "10.0.0.50 temp" >> /etc/hosts` 입니다. 단계마다 `cat /etc/hosts` 로 상태를 확인하세요.',
   'cp /etc/hosts /etc/hosts.bak
echo "10.0.0.50 temp" >> /etc/hosts
cp /etc/hosts /tmp/hosts.edited
cp /etc/hosts.bak /etc/hosts

# 고치기 전 백업, 문제가 생기면 백업으로 되돌린다
grep -c temp /etc/hosts   # 0',
   NULL,
   '["sh", "-c", "[ -f /etc/hosts.bak ] && grep -q temp /tmp/hosts.edited && ! grep -q temp /etc/hosts && getent hosts localhost >/dev/null"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 36 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 36, 4, '같은 이름이 두 줄이면 생기는 문제 읽기',
   '`/etc/hosts` 에 `cache` 라는 이름이 **두 줄** 있습니다. 터미널에서 `cat /etc/hosts` 와 `getent hosts cache` 를 실행해 보세요. 이름 하나가 **IP 두 개**로 나옵니다.

이 상태에서 생기는 문제로 가장 알맞은 것을 고르세요.',
   '`getent hosts cache` 는 그 이름에 연결된 주소를 **모두** 보여 줍니다. 프로그램은 이 목록에서 주소를 골라 접속합니다. 어느 줄이 쓰이는지는 프로그램과 상황에 따라 달라질 수 있다는 점을 생각해 보세요.',
   NULL,
   '["sh", "-c", "printf ''10.0.0.40 cache\\\\n10.0.0.41 cache\\\\n'' >> /etc/hosts"]',
   '[]',
   'choice',
   '["아무 문제 없다. 두 서버로 자동으로 나뉘어 접속되는 로드밸런싱이 된다", "`/etc/hosts` 는 같은 이름이 두 줄이면 오류로 읽지 못한다", "이름이 IP 두 개로 해석되어 **어느 서버로 접속될지 불확실**하다. 옛 줄이 남아 있으면 옛 서버로 갈 수 있다", "두 번째 줄은 무시되어 항상 첫 줄의 IP 만 쓰인다"]',
   2,
   '정답은 **C 이름이 IP 두 개로 해석되어 어느 서버로 접속될지 불확실하다** 입니다. `getent hosts cache` 가 `10.0.0.40` 과 `10.0.0.41` 을 모두 보여 줍니다.

**원리:** `/etc/hosts` 는 이름 → IP 대응표입니다. 한 이름에 줄이 여러 개면 조회 결과에 **주소가 모두** 담기고, 프로그램이 그중 무엇을 쓰는지는 프로그램에 달려 있습니다. 그래서 서버를 옮겼을 때 옛 줄이 남아 있으면 일부 접속만 옛 서버로 가는 **간헐적 장애**가 되어 원인을 찾기 어렵습니다. 한 이름에는 IP 하나만 두고, 바꿀 때는 옛 줄을 지웁니다.

- A 로드밸런싱 : `/etc/hosts` 는 요청을 나누지 않습니다. 이름 해석 결과 목록일 뿐입니다.
- B 오류로 읽지 못함 : 같은 이름 여러 줄도 읽습니다. 그래서 문제가 눈에 띄지 않습니다.
- D 항상 첫 줄 : 항상 그렇다고 단정할 수 없고, 프로그램마다 다릅니다. 이 가정에 기대면 안 됩니다.

확인: `getent hosts cache`'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 36 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 36, 7, '접속 오류 메시지가 가리키는 단계 구분하기',
   '이름으로 접속할 때 같은 `curl` 인데 **오류 메시지가 다르게** 나옵니다. 터미널에서 두 명령을 실행해 보세요.

- `curl -sS -o /dev/null http://ghost:9100`
- `curl -sS -o /dev/null http://appsrv:9100`

(`appsrv` 는 `/etc/hosts` 에 등록되어 있지만 9100 포트에는 서비스가 없습니다. `ghost` 는 어디에도 없는 이름입니다.) 두 오류 메시지가 각각 가리키는 문제로 맞는 것을 고르세요.',
   '두 오류의 앞부분 문장을 비교해 보세요. 하나는 이름을 **IP 로 바꾸는 단계**에서, 다른 하나는 IP 로 바꾼 **뒤 접속하는 단계**에서 나는 오류입니다.',
   NULL,
   '["sh", "-c", "echo ''127.0.0.1 appsrv'' >> /etc/hosts"]',
   '[]',
   'choice',
   '["둘 다 DNS 서버 설정 문제다", "`Could not resolve host` 는 이름을 IP 로 바꾸지 못한 것(이름 해석 문제)이고, `Connection refused` 는 이름은 해석됐지만 그 IP·포트에 받아 주는 서비스가 없는 것(포트·서비스 문제)이다", "`Could not resolve host` 는 포트가 닫혀서, `Connection refused` 는 이름이 틀려서 난다", "둘 다 방화벽이 막아서 나는 오류다"]',
   1,
   '정답은 **B** 입니다. `ghost` 는 `Could not resolve host: ghost`(이름을 IP 로 바꾸지 못함), `appsrv` 는 `Failed to connect ... Connection refused`(이름은 `127.0.0.1` 로 해석됐지만 9100 포트에서 받는 서비스가 없음)가 나옵니다.

**원리:** 통신은 **이름 → IP → (경로) → 포트 → 서비스** 순서로 이뤄지고, **어느 단계에서 실패했는지가 오류 메시지에 드러납니다.** `Could not resolve host` 는 첫 단계(이름 해석)에서 막힌 것이라 `/etc/hosts` 나 DNS 를 봐야 하고, `Connection refused` 는 이름과 IP 는 통과했고 마지막 단계에서 그 포트를 열고 있는 프로세스가 없는 것이라 서비스 기동과 포트(`ss -tlnp`)를 봐야 합니다.

- A 둘 다 DNS : `appsrv` 는 이름 해석에 성공했습니다.
- C 반대 : 순서가 거꾸로입니다.
- D 방화벽 : 방화벽이 막으면 보통 `Connection refused` 가 아니라 응답 없이 시간이 초과(timeout)됩니다.

확인: `curl -sS -o /dev/null http://ghost:9100`, `curl -sS -o /dev/null http://appsrv:9100`'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 36 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation)
SELECT 36, 8, '접속 장애를 좁혀 가는 확인 순서 고르기',
   '서비스에 접속이 안 된다는 제보가 왔습니다. 원인이 이름, 경로, 포트, 서비스 중 어디인지 모릅니다. 이럴 때 **어떤 순서로** 확인해야 원인을 가장 빨리 좁힐 수 있을까요? 지금까지 쓴 도구를 떠올려 보세요. (`getent hosts 이름`, `nc -zv 이름 포트`, `curl -v`, `ss -tlnp`)

가장 알맞은 순서를 고르세요.',
   '통신은 앞 단계가 되어야 뒤 단계가 됩니다. 이름이 IP 로 바뀌지 않으면 그 뒤 단계를 확인해도 의미가 없습니다.',
   NULL,
   NULL,
   '[]',
   'choice',
   '["포트가 열려 있는지 → 이름이 해석되는지 → 서버에 닿는지", "이름이 IP 로 해석되는지 → 그 IP 까지 닿는지(경로) → 그 포트에 서비스가 열려 있는지", "방화벽 규칙을 모두 지우고 → 다시 접속해 본다", "서버를 재부팅하고 → 이름을 다시 확인한다"]',
   1,
   '정답은 **B 이름이 IP 로 해석되는지 → 그 IP 까지 닿는지(경로) → 그 포트에 서비스가 열려 있는지** 입니다.

**원리:** 통신은 **이름 해석 → 경로(IP 도달) → 포트 → 서비스 응답** 순서로 진행됩니다. 앞 단계가 실패하면 뒤 단계는 시도조차 되지 않으므로, **앞에서부터** 하나씩 확인하면 어느 단계에서 끊겼는지 바로 보입니다. 이름은 `getent hosts 이름`, 포트는 `nc -zv 이름 포트`, 서비스가 포트를 열고 있는지는 `ss -tlnp`, 응답 내용은 `curl -v` 로 확인합니다.

- A 거꾸로 : 이름이 해석되지 않으면 포트 확인 결과가 의미가 없습니다.
- C 방화벽을 모두 지움 : 원인을 모른 채 보안 설정을 없애는 위험한 방법입니다. 원인을 좁힌 뒤에 필요한 규칙만 손봅니다.
- D 재부팅 : 원인을 모르는 채로 서비스를 중단시킵니다. 이름 확인이 먼저입니다.'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 36 AND order_index = 8);

UPDATE quest_set SET display_order = 115 WHERE id = 36;
