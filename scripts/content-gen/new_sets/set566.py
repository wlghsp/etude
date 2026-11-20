import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 566: TLS 와 인증서 읽기: openssl x509·verify·s_client. 명세: docs/specs/spec_gap_set566.md
# 샌드박스 linux(비특권, OpenSSL 3.0.2). 인증서는 setup 이 만든다(만료된 인증서는 openssl ca 로 과거 날짜를 지정해 만든다). 선행: 117(인증서 오류 한 문항), 556 없음.

STOP66 = "pkill -x openssl >/dev/null 2>&1; sleep 0.5; rm -f /tmp/*.txt /tmp/my.pem /tmp/my.key"
EC = "-newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -nodes"
PKI66 = (STOP66 + "; rm -rf /tmp/pki; mkdir -p /tmp/pki/certs /tmp/pki/db; cd /tmp/pki; "
         f"openssl req -x509 {EC} -keyout ca.key -out ca.pem -days 3650 -subj '/CN=Etude Test CA' 2>/dev/null; "
         f"openssl req -x509 {EC} -keyout other.key -out other-ca.pem -days 3650 -subj '/CN=Other CA' 2>/dev/null; "
         f"openssl req {EC} -keyout server.key -out server.csr -subj '/CN=shop.example.com' 2>/dev/null; "
         "printf 'subjectAltName=DNS:shop.example.com,DNS:www.shop.example.com\\n' > ext.cnf; "
         "openssl x509 -req -in server.csr -CA ca.pem -CAkey ca.key -CAcreateserial -out server.pem -days 90 -extfile ext.cnf 2>/dev/null; "
         f"for n in a c; do openssl req -x509 {EC} -keyout certs/$n.key -out certs/$n.pem -days 200 -subj \"/CN=$n.example.com\" 2>/dev/null; done; "
         "touch db/index.txt; echo 01 > db/serial; "
         "printf '[ca]\\ndefault_ca=d\\n[d]\\ndatabase=/tmp/pki/db/index.txt\\nnew_certs_dir=/tmp/pki/db\\nserial=/tmp/pki/db/serial\\ndefault_md=sha256\\npolicy=p\\nunique_subject=no\\n[p]\\ncommonName=supplied\\n' > ca.cnf; "
         f"openssl req {EC} -keyout certs/b.key -out b.csr -subj '/CN=b.example.com' 2>/dev/null; "
         "openssl ca -batch -config ca.cnf -cert ca.pem -keyfile ca.key -in b.csr -out certs/b.pem -startdate 20200101000000Z -enddate 20200201000000Z -notext >/dev/null 2>&1; "
         "rm -f b.csr server.csr; cd /; true")
# TLS 서버(8443)를 띄운 상태
SRV66 = PKI66 + "; nohup openssl s_server -accept 8443 -cert /tmp/pki/server.pem -key /tmp/pki/server.key -www >/dev/null 2>&1 & sleep 1"
SCL = "openssl s_client -connect 127.0.0.1:8443 -servername shop.example.com"

b = SetBuilder(566, 'TLS 와 인증서 읽기: 만료·SAN·체인 검증·s_client·직접 만들기',
               'HTTPS 가 안 될 때 인증서를 직접 읽어 원인을 찾는 연습입니다. openssl x509 로 만료 시각과 SAN(유효한 이름) 읽기, 만료된 인증서 찾기, openssl verify 로 체인(CA) 검증 성공과 실패 비교, openssl s_client 로 서버에 접속해 검증 결과 코드와 호스트 이름 불일치 확인, 시험용 인증서 직접 만들기, TLS 핸드셰이크 큰 흐름을 익힙니다.',
               'linux', '네트워크', 47, 826, '🔏',
               [{"title": "openssl x509", "url": "https://docs.openssl.org/3.0/man1/openssl-x509/"}, {"title": "openssl s_client", "url": "https://docs.openssl.org/3.0/man1/openssl-s_client/"}], 6)

# 1
b.nt('인증서의 만료 시각 읽기', '`/tmp/pki/server.pem` 은 웹 서버가 쓰는 인증서(PEM 형식 파일)입니다. 인증서에는 유효 기간이 들어 있고, 만료되면 브라우저가 경고합니다. 이 인증서의 **만료 시각 한 줄**(`notAfter=...` 형태 그대로)을 `/tmp/end.txt` 에 저장하세요.',
     '`openssl x509 -in 파일 -noout 옵션` 형태입니다. `-noout` 은 인증서 본문 출력을 생략합니다. 옵션 이름은 `openssl x509 -help` 에서 date 가 들어간 것을 찾아 보세요.',
     "openssl x509 -in /tmp/pki/server.pem -noout -enddate > /tmp/end.txt\ncat /tmp/end.txt\n\n# 시작 시각은 -startdate, 둘 다 보려면 -dates. 서버 인증서는 갱신 날짜를 달력에 걸어 두고 만료 전에 교체한다",
     PKI66, [chk('만료 시각 줄이 저장됐다', '[ "$(cat /tmp/end.txt)" = "$(openssl x509 -in /tmp/pki/server.pem -noout -enddate)" ]')])
# 2
b.nt('SAN: 이 인증서는 어느 이름에 유효한가', '브라우저는 접속한 이름이 인증서의 **SAN(Subject Alternative Name, 유효한 이름 목록)** 에 있는지 확인합니다. `/tmp/pki/server.pem` 의 SAN 에서 **`www.` 로 시작하는 이름 하나**를 찾아 `/tmp/san.txt` 에 저장하세요. (이름만)',
     '`openssl x509 -ext subjectAltName` 으로 SAN 확장만 볼 수 있습니다. 출력은 `DNS:이름, DNS:이름` 형태입니다. `tr`·`grep -o` 로 원하는 이름을 고르세요.',
     "openssl x509 -in /tmp/pki/server.pem -noout -ext subjectAltName\nopenssl x509 -in /tmp/pki/server.pem -noout -ext subjectAltName | grep -o 'DNS:www[^,]*' | sed 's/DNS://' > /tmp/san.txt\ncat /tmp/san.txt\n\n# 요즘 브라우저는 CN 이 아니라 SAN 만 본다. 접속 이름(www.shop.example.com)이 SAN 에 없으면 CN 이 맞아도 '이름 불일치' 오류가 난다",
     PKI66, [chk('이름이 저장됐다', '[ "$(cat /tmp/san.txt)" = www.shop.example.com ]')])
# 3
b.nt('만료된 인증서 찾기', '`/tmp/pki/certs/` 에 인증서 세 개(`a.pem`, `b.pem`, `c.pem`)가 있습니다. 그중 **이미 만료된 인증서의 파일 이름**을 `/tmp/expired.txt` 에 저장하세요. (파일 이름만, 예: `x.pem`)\n\n(`openssl x509 -checkend 초` 는 "지금부터 그 초 안에 만료되면" 종료 코드 1 을 돌려줍니다. `0` 을 주면 지금 만료됐는지 확인합니다.)',
     '세 파일에 같은 명령을 반복하면 됩니다. `for f in ...; do ...; done` 과 종료 코드를 `if` 로 검사하거나, 하나씩 직접 확인해도 됩니다. `-noout` 과 `-checkend 0` 을 함께 쓰세요.',
     "for f in a b c; do if ! openssl x509 -in /tmp/pki/certs/$f.pem -noout -checkend 0 >/dev/null; then echo $f.pem; fi; done > /tmp/expired.txt\ncat /tmp/expired.txt\n\n# 모니터링은 보통 -checkend 604800(7일)처럼 만료 임박을 미리 알린다",
     PKI66, [chk('만료된 파일이 b.pem 이다', '[ "$(cat /tmp/expired.txt)" = b.pem ]')])
# 4
b.nt('체인 검증: 믿는 CA 가 맞는가', '서버 인증서는 **CA(인증기관)** 가 서명해 줍니다. 클라이언트는 자신이 믿는 CA 목록으로 서명을 확인합니다. `openssl verify -CAfile CA파일 인증서` 로 확인하세요.\n\n1. 올바른 CA(`/tmp/pki/ca.pem`)로 `/tmp/pki/server.pem` 을 검증한 출력을 `/tmp/ok.txt` 에 저장\n2. **다른 CA**(`/tmp/pki/other-ca.pem`)로 같은 인증서를 검증한 출력을 `/tmp/bad.txt` 에 저장\n\n(오류 메시지까지 저장하려면 표준 에러도 함께 `2>&1` 로 저장합니다.)',
     '`openssl verify -CAfile ... 인증서` 를 두 번 실행하되, 두 번째는 CA 파일만 바꿉니다. 결과 파일에서 성공은 `OK`, 실패는 `unable to ...` 메시지를 확인하세요.',
     "openssl verify -CAfile /tmp/pki/ca.pem /tmp/pki/server.pem > /tmp/ok.txt 2>&1\nopenssl verify -CAfile /tmp/pki/other-ca.pem /tmp/pki/server.pem > /tmp/bad.txt 2>&1\ncat /tmp/ok.txt /tmp/bad.txt\n\n# 'unable to get local issuer certificate' 는 이 인증서를 서명한 CA 를 내 신뢰 목록에서 못 찾았다는 뜻이다. 사설 CA 인증서를 신뢰 목록에 넣지 않았을 때 자주 본다",
     PKI66, [chk('올바른 CA 로 OK 다', 'grep -q "server.pem: OK" /tmp/ok.txt'), chk('다른 CA 는 발급자를 못 찾는다', 'grep -q "unable to get local issuer certificate" /tmp/bad.txt')])
# 5
b.nt('s_client 로 접속해 검증 결과 읽기', '`8443` 포트에 TLS 서버(`shop.example.com` 인증서)가 떠 있습니다. `openssl s_client` 는 TLS 로 접속해 인증서와 검증 결과를 보여 줍니다. 서버 이름은 `-servername shop.example.com` 으로 알려 줍니다. 아래 두 번 접속해 각각 **`Verify return code:` 로 시작하는 줄**만 저장하세요.\n- `/tmp/rc_ok.txt` : `-CAfile /tmp/pki/ca.pem` 을 줘서 믿을 CA 를 알려 준 접속\n- `/tmp/rc_bad.txt` : CA 를 주지 않은 접속\n\n(`s_client` 는 입력을 기다리므로 `</dev/null` 로 끝내고, 출력은 `2>&1` 로 합칩니다.)',
     '접속 결과 전체를 보고, 검증 결과를 알려 주는 줄만 고르세요. 두 결과의 숫자와 괄호 안 설명을 비교해 보세요.',
     SCL + " -CAfile /tmp/pki/ca.pem </dev/null 2>&1 | grep 'Verify return code' > /tmp/rc_ok.txt\n" + SCL + " </dev/null 2>&1 | grep 'Verify return code' > /tmp/rc_bad.txt\ncat /tmp/rc_ok.txt /tmp/rc_bad.txt\n\n# 0 (ok) 면 검증 성공. 0 이 아니면 괄호 안 설명(unable to verify the first certificate 등)이 원인의 단서다",
     SRV66, [chk('CA 를 주면 0 (ok) 다', 'grep -q "Verify return code: 0 (ok)" /tmp/rc_ok.txt'), chk('CA 없이는 0 이 아니다', 'grep -q "Verify return code:" /tmp/rc_bad.txt && ! grep -q "0 (ok)" /tmp/rc_bad.txt')])
# 6
b.nt('접속 이름이 인증서와 다르면', '같은 서버에 **접속한 이름이 인증서의 SAN 에 있는지**까지 검증하게 할 수 있습니다. `s_client` 에 `-verify_hostname 이름` 을 주면 그 이름으로 검사합니다. CA 는 `-CAfile /tmp/pki/ca.pem` 으로 믿게 하고 두 번 접속해 `Verify return code:` 줄을 저장하세요.\n- `/tmp/host_bad.txt` : 이름을 **`api.example.com`** 으로 검사\n- `/tmp/host_ok.txt` : 이름을 **`www.shop.example.com`** 으로 검사',
     '앞 문제의 접속에 `-verify_hostname` 만 더합니다. 이름이 SAN 에 없으면 결과 코드의 설명에 hostname 이 들어갑니다.',
     SCL + " -CAfile /tmp/pki/ca.pem -verify_hostname api.example.com </dev/null 2>&1 | grep 'Verify return code' > /tmp/host_bad.txt\n" + SCL + " -CAfile /tmp/pki/ca.pem -verify_hostname www.shop.example.com </dev/null 2>&1 | grep 'Verify return code' > /tmp/host_ok.txt\ncat /tmp/host_bad.txt /tmp/host_ok.txt\n\n# 62 (hostname mismatch): 인증서는 믿을 수 있어도 접속한 이름이 SAN 에 없다. 해결은 접속 이름을 SAN 에 있는 것으로 바꾸거나 SAN 에 이름을 넣은 인증서로 교체",
     SRV66, [chk('없는 이름은 hostname mismatch 다', 'grep -qi "hostname mismatch" /tmp/host_bad.txt'), chk('SAN 에 있는 이름은 0 (ok) 다', 'grep -q "0 (ok)" /tmp/host_ok.txt')])
# 7
b.nt('시험용 자체 서명 인증서 만들기', '테스트 서버에 쓸 **자체 서명(self-signed) 인증서**를 만드세요. 조건은 다음과 같습니다.\n- 인증서 `/tmp/my.pem`, 개인 키 `/tmp/my.key`\n- 주체(CN) `test.example.com`, SAN 도 `test.example.com`\n- 유효 기간 **30일**\n- 키는 암호 없이(`-nodes`)\n\n(`openssl req -x509 ...` 한 줄로 만들 수 있습니다. SAN 은 `-addext` 로 추가합니다.)',
     '`openssl req -x509` 에 키 생성·암호 없음·출력 파일·기간·주체·추가 확장 옵션을 조합합니다. 옵션 이름은 `openssl req -help` 에서 확인하세요.',
     "openssl req -x509 -newkey rsa:2048 -nodes -keyout /tmp/my.key -out /tmp/my.pem -days 30 -subj '/CN=test.example.com' -addext 'subjectAltName=DNS:test.example.com' 2>/dev/null\nopenssl x509 -in /tmp/my.pem -noout -subject -enddate -ext subjectAltName\n\n# 자체 서명 인증서는 발급자=주체라서 브라우저가 믿지 않는다. 시험용으로만 쓰고 운영은 신뢰하는 CA 에서 발급받는다",
     PKI66, [chk('인증서와 키가 있다', '[ -s /tmp/my.pem ] && [ -s /tmp/my.key ]'), chk('CN 이 test.example.com 이다', 'openssl x509 -in /tmp/my.pem -noout -subject | grep -q "test.example.com"'), chk('SAN 에 이름이 있다', 'openssl x509 -in /tmp/my.pem -noout -ext subjectAltName | grep -q "DNS:test.example.com"'), chk('유효 기간이 약 30일이다', 'openssl x509 -in /tmp/my.pem -noout -checkend $((29*86400)) >/dev/null && ! openssl x509 -in /tmp/my.pem -noout -checkend $((31*86400)) >/dev/null')])
# 8
b.choice('인증서를 갱신했는데도 expired 오류', '서버 인증서를 새로 발급해 교체했는데, 일부 클라이언트에서 여전히 `certificate has expired` 오류가 납니다. 먼저 확인할 것으로 가장 알맞은 것은?', '오류가 나는 클라이언트와 정상인 클라이언트의 차이를 찾아 보세요.',
         ['새 인증서가 안 들어간 서버나 틀린 클라이언트 시계', '서버의 CPU 사용률이 높아져 만료된 것', '인증서 파일 용량이 커져 만료된 것', '서버 포트를 443 에서 바꾸지 않은 것'], 0,
         'expired 는 클라이언트가 본 인증서의 유효 기간이 지났다는 판단입니다. 일부만 실패한다면 일부 서버·로드 밸런서에 새 인증서가 안 들어갔거나, 중간 장비가 옛 것을 내밀거나, 클라이언트 시계가 틀린 경우가 많습니다. s_client 로 문제 대상에 직접 접속해 notAfter 를 확인합니다. CPU 사용률·파일 용량·포트 번호와는 무관합니다.')
# 9
b.choice('인증서의 CN 은 맞는데 이름 불일치', '인증서의 CN 은 `shop.example.com` 인데, 브라우저가 `www.shop.example.com` 으로 접속하자 이름 불일치 오류를 냈습니다. 가장 알맞은 원인은?', '요즘 브라우저는 무엇을 기준으로 이름을 비교하나요?',
         ['SAN 에 접속한 이름이 없다', 'CN 이 너무 길다', '인증서가 PEM 형식이다', '서버의 포트가 443 이다'], 0,
         '최신 브라우저는 CN 이 아니라 SAN 목록으로 이름을 검사합니다. www.shop.example.com 이 SAN 에 없으면 CN 이 맞아도 불일치입니다. 해결은 필요한 모든 이름을 SAN 에 넣은 인증서를 다시 발급하는 것입니다. PEM 형식이나 443 포트는 정상적인 조건입니다.')
# 10
b.fill('만료 시각을 보는 옵션', '`openssl x509` 로 인증서가 **만료되는 시각(notAfter)** 만 출력하는 옵션을 채우세요.', '"끝나는 날짜"를 뜻하는 영어 합성어입니다.',
       'openssl x509 -in server.pem -noout -{0}', ['enddate', 'subject', 'issuer', 'serial'], [0],
       '`-enddate` 는 notAfter(만료), `-startdate` 는 notBefore(시작)를 보여 줍니다. `-subject` 는 주체, `-issuer` 는 발급자, `-serial` 은 일련번호입니다.')
# 11
b.order('TLS 핸드셰이크의 큰 흐름', 'HTTPS 접속에서 데이터가 암호화되어 오가기까지의 큰 흐름입니다. 안전한 데이터 전송은 서버를 믿을 수 있다고 확인한 뒤에 시작됩니다. 올바른 순서로 놓으세요.', '서버가 누구인지 믿을 수 있어야 데이터를 보낸다는 점에서 출발하세요.',
        ['클라이언트가 서버 인증서의 체인·이름·유효 기간을 검증한다', '서버가 인증서를 보내며 응답한다', '핸드셰이크를 마치고 암호화된 데이터를 주고받는다', '클라이언트가 지원하는 암호와 접속할 이름(SNI)을 담아 인사를 보낸다'], [3, 1, 0, 2],
        '클라이언트가 지원 암호 목록과 SNI(접속할 이름)를 담은 ClientHello 를 보내면 서버가 인증서와 함께 응답하고, 클라이언트가 인증서의 체인·이름·기간을 검증합니다. TLS 1.3 에서는 키 합의가 hello 메시지 안에서 먼저 이뤄지지만, 인증서 검증이 통과해야 핸드셰이크가 끝나고 애플리케이션 데이터를 주고받습니다. 검증 실패가 expired·hostname mismatch 같은 오류로 나타납니다.')

if __name__ == '__main__':
    preview(b)
