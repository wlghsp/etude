# 세트 507: 계정·권한 설계 실습 (docs/specs/spec_gap_set507.md). 로컬 DB 미리보기: python3 scripts/content-gen/new_sets/set507.py
import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *

USERS = ['appuser', 'reader', 'report', 'olduser', 'alice', 'bob', 'backup']
BASE = DBUP + "; mariadb -e '" + ' '.join(f'DROP USER IF EXISTS "{u}"@"localhost";' for u in USERS) + ' DROP USER IF EXISTS "backup"@"%"; DROP ROLE IF EXISTS reader_role; DROP DATABASE IF EXISTS shop; CREATE DATABASE shop; CREATE TABLE shop.items (id INT PRIMARY KEY, name VARCHAR(30), price INT); INSERT INTO shop.items VALUES (1,"apple",1000),(2,"pear",2000),(3,"grape",3000),(4,"peach",4000),(5,"plum",5000);\'; ' + CLEAN
def mk(sql): return BASE + "; mariadb -e '" + sql + "'"
def one(sql): return f"mariadb -N -e '{sql}'"

b = SetBuilder(507, '계정·권한 설계 실습: 앱·읽기 전용 계정, 최소 권한, ROLE, 비밀번호, 호스트 제한',
               'MariaDB 계정을 직접 설계합니다. 호스트를 제한한 앱 계정 만들기, 필요한 권한만 주기(최소 권한), 읽기 전용 계정과 거부 오류 확인, SHOW GRANTS 로 과한 권한 점검, REVOKE 로 회수, DROP USER 로 삭제, ROLE 로 묶어 주기와 기본 역할, 비밀번호 변경, 원격 접속 호스트 제한을 터미널에서 실습합니다.',
               'linux-db', '데이터베이스', 20, 728, '🛡️',
               [{"title": "CREATE USER", "url": "https://mariadb.com/kb/en/create-user/"}, {"title": "GRANT", "url": "https://mariadb.com/kb/en/grant/"}, {"title": "Roles", "url": "https://mariadb.com/kb/en/roles_overview/"}], 5)

b.nt('앱 전용 계정 만들기 (접속 호스트 제한)', '`shop` 데이터베이스를 쓰는 앱을 위해 계정을 하나 만듭니다. 계정 이름은 **`appuser`**, 접속을 허용할 곳은 **이 서버 안(`localhost`)만**, 비밀번호는 **`AppPass1`** 입니다. MariaDB 계정은 `\'이름\'@\'접속 위치\'` 두 부분으로 이루어져, 같은 이름이라도 접속 위치가 다르면 다른 계정입니다. 만든 뒤 그 계정으로 접속해 `SELECT 1` 이 되어야 합니다.',
     '`CREATE USER \'이름\'@\'호스트\' IDENTIFIED BY \'비밀번호\';` 를 `mariadb -e` 로 실행합니다. 접속 시험은 `mariadb -u이름 -p비밀번호 -e "SELECT 1"` 입니다.',
     "mariadb -e \"CREATE USER 'appuser'@'localhost' IDENTIFIED BY 'AppPass1'\"\nmariadb -uappuser -pAppPass1 -e 'SELECT 1'\n\n# 호스트 부분을 localhost 로 두면 그 서버 안에서만 접속할 수 있다. '%' 는 어디서나 접속 허용이라 꼭 필요할 때만 쓴다",
     BASE, [chk('appuser@localhost 계정이 있다', one('SELECT COUNT(*) FROM mysql.user WHERE user="appuser" AND host="localhost"') + ' | grep -qx 1'), chk('그 계정으로 접속된다', 'mariadb -uappuser -pAppPass1 -N -e "SELECT 1" | grep -qx 1')])
b.nt('필요한 권한만 주기', '`appuser` 가 만들어져 있지만 **아직 아무 데이터도 볼 수 없습니다**. 앱은 `shop` 의 모든 테이블을 **조회·추가·수정·삭제**만 하면 됩니다. 이 네 가지 권한(`SELECT, INSERT, UPDATE, DELETE`)만 `shop.*` 에 주세요. 테이블을 만들거나 지우는 권한까지 주는 `ALL` 은 쓰지 않습니다.',
     '`GRANT 권한, 권한 ON DB이름.* TO \'계정\'@\'호스트\';` 형식입니다. `shop.*` 는 shop 의 모든 테이블을 뜻합니다.',
     "mariadb -e \"GRANT SELECT, INSERT, UPDATE, DELETE ON shop.* TO 'appuser'@'localhost'\"\nmariadb -e \"SHOW GRANTS FOR 'appuser'@'localhost'\"\n\n# 필요한 만큼만 주는 것이 최소 권한 원칙. 앱이 침해돼도 피해가 shop 의 데이터 변경까지로 한정된다",
     mk("CREATE USER \"appuser\"@\"localhost\" IDENTIFIED BY \"AppPass1\";"),
     [chk('shop 에 네 권한이 있다', one('SELECT GROUP_CONCAT(privilege_type ORDER BY privilege_type) FROM information_schema.schema_privileges WHERE grantee LIKE "%appuser%" AND table_schema="shop"') + ' | grep -qx "DELETE,INSERT,SELECT,UPDATE"'), chk('앱 계정으로 조회된다', 'mariadb -uappuser -pAppPass1 -N -e "SELECT COUNT(*) FROM shop.items" | grep -qx 5')])
b.nt('읽기 전용 계정과 거부 오류', '분석 담당자를 위한 **읽기 전용 계정**을 만듭니다. 이름 **`reader`**, 위치 `localhost`, 비밀번호 **`ReadPass1`**, 권한은 `shop.*` 에 **`SELECT` 만** 줍니다. 그다음 이 계정으로 `shop.items` 에 `INSERT` 를 시도해 **거부되는 오류 메시지를 `/tmp/denied.txt`** 에 저장하세요. (INSERT 는 아무 값이나 괜찮습니다.)',
     '계정을 만들고 `GRANT SELECT ...` 한 뒤, `mariadb -ureader -pReadPass1 shop -e "INSERT ..." 2> /tmp/denied.txt` 처럼 오류(표준 에러)를 파일로 보냅니다. 오류 번호는 1142 입니다.',
     "mariadb -e \"CREATE USER 'reader'@'localhost' IDENTIFIED BY 'ReadPass1'; GRANT SELECT ON shop.* TO 'reader'@'localhost'\"\nmariadb -ureader -pReadPass1 shop -e \"INSERT INTO items VALUES (6,'kiwi',6000)\" 2> /tmp/denied.txt\ncat /tmp/denied.txt\n\n# 권한이 없는 동작은 ERROR 1142 ... command denied 로 거부된다. 읽기만 필요한 사람에게는 SELECT 만 준다",
     BASE, [chk('reader 의 shop 권한이 SELECT 뿐이다', one('SELECT GROUP_CONCAT(privilege_type) FROM information_schema.schema_privileges WHERE grantee LIKE "%reader%" AND table_schema="shop"') + ' | grep -qx SELECT'), chk('거부 오류가 저장됐다', 'grep -q "INSERT command denied" /tmp/denied.txt'), chk('데이터는 그대로 5행이다', one('SELECT COUNT(*) FROM shop.items') + ' | grep -qx 5')])
b.nt('SHOW GRANTS 로 과한 권한 찾기', '보고서용으로 만든 계정 **`report`@`localhost`** 가 있습니다. 보고서는 조회만 하면 되는데 권한이 적절한지 점검하려 합니다. 이 계정의 **권한 목록을 `/tmp/report_grants.txt`** 에 저장하세요. (저장한 내용에 `ALL PRIVILEGES ON *.*` 가 있으면 서버 전체에 대한 모든 권한이라 과한 상태입니다.)',
     '`SHOW GRANTS FOR \'계정\'@\'호스트\';` 를 `mariadb -e` 로 실행하고 `>` 로 저장합니다. 계정 이름은 작은따옴표로 두 부분을 감쌉니다.',
     "mariadb -e \"SHOW GRANTS FOR 'report'@'localhost'\" > /tmp/report_grants.txt\ncat /tmp/report_grants.txt\n\n# ON *.* 는 모든 DB·모든 테이블이다. ALL PRIVILEGES 가 *.* 에 있다면 사실상 관리자 권한이라 보고서 계정에 어울리지 않는다",
     mk("CREATE USER \"report\"@\"localhost\" IDENTIFIED BY \"ReportPw1\"; GRANT ALL PRIVILEGES ON *.* TO \"report\"@\"localhost\";"),
     [chk('파일이 있다', '[ -s /tmp/report_grants.txt ]'), chk('report 의 권한 목록이다', 'grep -q "report" /tmp/report_grants.txt'), chk('ALL PRIVILEGES 가 보인다', 'grep -q "ALL PRIVILEGES ON \\*\\.\\*" /tmp/report_grants.txt')])
b.nt('REVOKE 로 권한 회수하고 필요한 것만 다시 주기', '앞에서 찾은 `report`@`localhost` 의 **서버 전체 권한을 회수**하고, 보고서에 필요한 **`shop.*` 의 `SELECT` 만** 다시 주세요. 끝나면 서버 전체(`*.*`)에는 사용 권한(`USAGE`, 접속만 가능)만 남아야 합니다.',
     '`REVOKE ALL PRIVILEGES, GRANT OPTION FROM \'report\'@\'localhost\';` 로 전부 회수한 뒤 `GRANT SELECT ON shop.* TO ...` 합니다. `SHOW GRANTS` 로 결과를 확인하세요.',
     "mariadb -e \"REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'report'@'localhost'; GRANT SELECT ON shop.* TO 'report'@'localhost'\"\nmariadb -e \"SHOW GRANTS FOR 'report'@'localhost'\"\n\n# 넓게 준 권한은 회수하고 필요한 범위·종류만 다시 준다. USAGE 는 '권한 없음'(접속만 가능)을 뜻한다",
     mk("CREATE USER \"report\"@\"localhost\" IDENTIFIED BY \"ReportPw1\"; GRANT ALL PRIVILEGES ON *.* TO \"report\"@\"localhost\";"),
     [chk('서버 전체 권한이 USAGE 뿐이다', one('SELECT COUNT(*) FROM information_schema.user_privileges WHERE grantee LIKE "%report%" AND privilege_type<>"USAGE"') + ' | grep -qx 0'), chk('shop 에는 SELECT 만 있다', one('SELECT GROUP_CONCAT(privilege_type) FROM information_schema.schema_privileges WHERE grantee LIKE "%report%" AND table_schema="shop"') + ' | grep -qx SELECT'), chk('계정은 남아 있다', one('SELECT COUNT(*) FROM mysql.user WHERE user="report"') + ' | grep -qx 1')])
b.nt('퇴사자 계정 삭제하기', '퇴사한 담당자의 계정 **`olduser`@`localhost`** 가 아직 남아 있습니다. 이 계정을 **삭제**하세요. 다른 계정(`appuser`)은 지우면 안 됩니다. 삭제 후에는 `olduser` 로 접속이 거부되어야 합니다.',
     '계정을 통째로 지우는 구문은 `DROP USER \'이름\'@\'호스트\';` 입니다. 지우기 전에 `SELECT user, host FROM mysql.user;` 로 대상이 맞는지 확인하세요.',
     "mariadb -e 'SELECT user, host FROM mysql.user'\nmariadb -e \"DROP USER 'olduser'@'localhost'\"\nmariadb -e 'SELECT user, host FROM mysql.user'\n\n# DROP USER 는 계정과 그 권한을 함께 지운다. 쓰지 않는 계정은 공격 경로가 되므로 남기지 않는다",
     mk("CREATE USER \"olduser\"@\"localhost\" IDENTIFIED BY \"OldPass1\"; GRANT SELECT ON shop.* TO \"olduser\"@\"localhost\"; CREATE USER \"appuser\"@\"localhost\" IDENTIFIED BY \"AppPass1\";"),
     [chk('olduser 가 없다', one('SELECT COUNT(*) FROM mysql.user WHERE user="olduser"') + ' | grep -qx 0'), chk('appuser 는 남아 있다', one('SELECT COUNT(*) FROM mysql.user WHERE user="appuser"') + ' | grep -qx 1'), chk('olduser 로 접속이 안 된다', '! mariadb -uolduser -pOldPass1 -e "SELECT 1" >/dev/null 2>&1')])
b.nt('ROLE 로 묶어서 여러 명에게 주기', '분석팀 **`alice`**, **`bob`** (둘 다 `localhost`)이 같은 권한을 받아야 합니다. 계정마다 `GRANT` 하지 말고 **역할(ROLE) `reader_role`** 을 만들어 `shop.*` 의 `SELECT` 를 주고, 그 역할을 `alice` 와 `bob` 에게 부여하세요. 그리고 두 사람이 **접속하자마자** 조회할 수 있어야 합니다. (`alice` 비밀번호 `AlicePw1`, `bob` 비밀번호 `BobPw1`)',
     '`CREATE ROLE`, `GRANT SELECT ON shop.* TO 역할`, `GRANT 역할 TO 계정` 순서입니다. 역할을 받아도 접속할 때 자동으로 켜지지는 않습니다. 접속 직후 바로 쓰게 하는 "기본 역할" 지정 구문을 찾아보세요. 확인은 `mariadb -ualice -pAlicePw1 -e "SELECT COUNT(*) FROM shop.items"` 입니다.',
     "mariadb -e \"CREATE ROLE reader_role; GRANT SELECT ON shop.* TO reader_role; GRANT reader_role TO 'alice'@'localhost', 'bob'@'localhost'; SET DEFAULT ROLE reader_role FOR 'alice'@'localhost'; SET DEFAULT ROLE reader_role FOR 'bob'@'localhost'\"\nmariadb -ualice -pAlicePw1 -e 'SELECT COUNT(*) FROM shop.items'\n\n# 권한 묶음을 역할로 만들어 두면 사람이 바뀔 때 역할만 주고 뺀다. SET DEFAULT ROLE 이 없으면 역할이 꺼진 채로 접속해 1142 가 난다",
     mk("CREATE USER \"alice\"@\"localhost\" IDENTIFIED BY \"AlicePw1\"; CREATE USER \"bob\"@\"localhost\" IDENTIFIED BY \"BobPw1\";"),
     [chk('역할이 만들어져 있다', one('SELECT COUNT(*) FROM mysql.user WHERE user="reader_role" AND is_role="Y"') + ' | grep -qx 1'), chk('alice 가 바로 조회된다', 'mariadb -ualice -pAlicePw1 -N -e "SELECT COUNT(*) FROM shop.items" | grep -qx 5'), chk('bob 이 바로 조회된다', 'mariadb -ubob -pBobPw1 -N -e "SELECT COUNT(*) FROM shop.items" | grep -qx 5')])
b.nt('비밀번호 바꾸기', '`appuser`@`localhost` 의 비밀번호(`OldPass1`)가 유출되어 **`NewPass2`** 로 바꿔야 합니다. 비밀번호를 변경하세요. 바꾼 뒤에는 새 비밀번호로만 접속되고 옛 비밀번호로는 거부됩니다.',
     '`ALTER USER \'계정\'@\'호스트\' IDENTIFIED BY \'새비밀번호\';` 를 사용합니다. 권한은 그대로 유지됩니다.',
     "mariadb -e \"ALTER USER 'appuser'@'localhost' IDENTIFIED BY 'NewPass2'\"\nmariadb -uappuser -pNewPass2 -e 'SELECT 1'\n\n# 비밀번호만 바뀌고 GRANT 는 그대로다. 유출이 의심되면 바꾸고, 앱 설정 파일의 비밀번호도 함께 고쳐야 한다",
     mk("CREATE USER \"appuser\"@\"localhost\" IDENTIFIED BY \"OldPass1\"; GRANT SELECT ON shop.* TO \"appuser\"@\"localhost\";"),
     [chk('새 비밀번호로 접속된다', 'mariadb -uappuser -pNewPass2 -N -e "SELECT 1" | grep -qx 1'), chk('옛 비밀번호는 거부된다', '! mariadb -uappuser -pOldPass1 -e "SELECT 1" >/dev/null 2>&1'), chk('권한은 그대로다', 'mariadb -uappuser -pNewPass2 -N -e "SELECT COUNT(*) FROM shop.items" | grep -qx 5')])
b.nt('원격 접속 호스트 제한하기', '백업 계정 **`backup`@`%`** 는 어느 곳에서나 접속할 수 있게 만들어져 있습니다. 백업은 이 서버 안에서만 실행되므로 **접속 허용 위치를 `localhost` 로 바꿔** 원격 접속을 막으세요. 계정을 지우고 다시 만들지 말고 **이름을 바꾸는 구문**으로 호스트 부분만 변경해 권한과 비밀번호를 유지합니다.',
     '`RENAME USER \'이름\'@\'옛호스트\' TO \'이름\'@\'새호스트\';` 입니다. 끝나면 `SELECT user, host FROM mysql.user;` 로 호스트가 바뀌었는지 보세요.',
     "mariadb -e \"RENAME USER 'backup'@'%' TO 'backup'@'localhost'\"\nmariadb -e 'SELECT user, host FROM mysql.user WHERE user=\"backup\"'\n\n# '%' 계정은 네트워크 어디서든 비밀번호만 맞으면 들어온다. 접속 위치를 좁히면 계정이 유출돼도 위험이 줄어든다. 서버 자체가 외부에 열려 있는지는 bind-address 설정으로 따로 막는다",
     mk("CREATE USER \"backup\"@\"%\" IDENTIFIED BY \"BackPass1\"; GRANT SELECT, LOCK TABLES ON shop.* TO \"backup\"@\"%\";"),
     [chk('backup 계정은 localhost 하나뿐이다', one('SELECT GROUP_CONCAT(host) FROM mysql.user WHERE user="backup"') + ' | grep -qx localhost'), chk('권한이 유지됐다', one('SELECT GROUP_CONCAT(privilege_type ORDER BY privilege_type) FROM information_schema.schema_privileges WHERE grantee LIKE "%backup%" AND table_schema="shop"') + ' | grep -qx "LOCK TABLES,SELECT"'), chk('비밀번호가 유지됐다', 'mariadb -ubackup -pBackPass1 -N -e "SELECT 1" | grep -qx 1')])
b.choice('가장 안전한 앱 계정 설계', '앱 서버(`192.0.2.10`) 한 곳에서만 `shop` 데이터베이스의 데이터를 조회·추가·수정·삭제하는 앱 계정을 만듭니다. 가장 안전한 정의는 무엇인가요?', '두 가지를 모두 좁혀 보세요. 접속할 수 있는 위치(계정의 호스트 부분)와 줄 권한의 범위입니다.',
         ["`'app'@'192.0.2.10'` 에 `shop.*` 의 `SELECT, INSERT, UPDATE, DELETE` 만 준다", "`'app'@'%'` 에 `*.*` 의 `ALL PRIVILEGES` 를 준다", "`'app'@'localhost'` 에 `*.*` 의 `ALL PRIVILEGES` 를 준다", "`'root'@'%'` 를 앱과 같이 쓴다"], 0,
         '접속 위치를 앱 서버 한 곳으로 좁히고, 권한도 필요한 DB 와 필요한 동작으로만 제한한 것이 최소 권한입니다. `%` 는 어디서든 접속을 허용하고, `*.* ALL PRIVILEGES` 는 서버 전체 관리자 권한이며, root 를 공유하면 앱이 침해될 때 서버 전체가 넘어갑니다. (localhost 로만 적으면 다른 서버의 앱은 접속하지 못합니다.)')
b.fill('접속 직후 켜질 기본 역할 지정', '`alice` 에게 역할을 줬는데 접속하면 권한이 없다고 나옵니다. 접속하자마자 `reader_role` 이 **자동으로 켜지게** 하는 구문의 빈칸을 채우세요.', '역할은 부여만 해서는 켜지지 않습니다. "기본으로 켤 역할"을 계정에 대해 지정합니다.',
       "SET DEFAULT ROLE reader_role {0} 'alice'@'localhost';", ['FOR', 'TO', 'ON', 'FROM'], [0],
       '`SET DEFAULT ROLE 역할 FOR 계정` 이 접속 때 자동으로 켤 역할을 정합니다. TO, ON, FROM 은 이 구문에 쓰이지 않습니다. 부여(`GRANT 역할 TO 계정`)와 활성화는 별개입니다.')
b.order('퇴사자 계정 정리 순서', '퇴사자 계정을 안전하게 정리하는 순서로 놓으세요.', '지울 대상과 권한을 먼저 눈으로 확인합니다. 정리한 뒤 정말 막혔는지 마지막에 확인하는 흐름을 떠올려 보세요.',
        ['DROP USER 로 계정을 삭제한다', '그 계정으로 접속해 거부되는지 확인한다', 'SHOW GRANTS 로 계정과 권한을 확인한다', 'REVOKE 로 남은 권한을 회수한다'], [2, 3, 0, 1],
        '지울 계정이 맞는지 SHOW GRANTS 로 확인하고, 권한을 REVOKE 로 회수한 뒤 DROP USER 로 삭제합니다. 마지막에 그 계정으로 접속해 거부되는지 확인하면 정리가 끝난 것입니다. 삭제 전에 대상 확인이 먼저인 것이 핵심입니다.')

if __name__ == '__main__':
    preview(b)
