import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 523: SQL 윈도 함수·WITH 입문. 명세: docs/specs/spec_gap_set523.md

SCH = DBUP + """; mariadb -e 'DROP DATABASE IF EXISTS school; CREATE DATABASE school; USE school; CREATE TABLE scores (id INT PRIMARY KEY, class CHAR(1), student VARCHAR(20), score INT, tested_on DATE); INSERT INTO scores VALUES (1,"A","kim",90,"2026-03-01"),(2,"A","lee",85,"2026-03-02"),(3,"A","park",90,"2026-03-03"),(4,"A","oh",70,"2026-03-04"),(5,"B","choi",95,"2026-03-01"),(6,"B","han",80,"2026-03-02"),(7,"B","jung",80,"2026-03-03"),(8,"B","yoon",60,"2026-03-04"); CREATE TABLE daily (day DATE PRIMARY KEY, visitors INT); INSERT INTO daily VALUES ("2026-03-01",100),("2026-03-02",120),("2026-03-03",90),("2026-03-04",150),("2026-03-05",130);'; """ + CLEAN
# 기대 결과를 표로 적어 파일 내용과 그대로 비교한다 (탭 구분)
EXP = lambda f, rows: '[ "$(cat %s)" = "$(printf \'%s\')" ]' % (f, '\\n'.join('\\t'.join(r) for r in rows))
INTRO = '`school` 데이터베이스(`mariadb school -e \'쿼리\'`)를 씁니다. 문제마다 처음 상태에서 다시 시작합니다. `-N` 을 붙이면 열 이름 줄 없이 값만 나옵니다.'

b = SetBuilder(523, 'SQL 윈도 함수·WITH 입문: WITH(CTE), ROW_NUMBER, RANK·DENSE_RANK, PARTITION BY, 누적 합계, LAG',
               '쿼리에 이름을 붙이는 WITH(CTE)부터 시작해, 행을 합치지 않고 순위·누적값을 옆에 붙이는 윈도 함수를 한 가지씩 익힙니다. ROW_NUMBER, RANK 와 DENSE_RANK 의 차이, PARTITION BY, 누적 합계, 바로 앞 행 값을 가져오는 LAG 를 터미널 실습과 퀴즈로 연습합니다.',
               'linux-db', '데이터베이스', 44, 744, '🪟',
               [{"title": "MariaDB 윈도 함수", "url": "https://mariadb.com/kb/en/window-functions/"}, {"title": "MariaDB WITH(CTE)", "url": "https://mariadb.com/kb/en/with/"}], 3)

b.choice('WITH 는 무엇을 하나', '긴 쿼리의 중간 결과에 **이름을 붙여** 두고, 아래 `SELECT` 에서 그 이름을 테이블처럼 쓰는 문법이 있습니다. `WITH passed AS (SELECT * FROM scores WHERE score >= 85) SELECT * FROM passed;` 에서 `passed` 는 무엇일까요?', '`AS (...)` 안의 쿼리에 붙인 이름입니다. 진짜 테이블을 만드는 문장은 `CREATE TABLE` 입니다.',
         ['괄호 안 쿼리 결과에 붙인 임시 이름 (이 쿼리가 끝나면 사라짐)', '디스크에 저장되는 새 테이블', '`scores` 테이블의 새 이름', '인덱스의 이름'], 0,
         '`WITH 이름 AS (쿼리)` 로 만든 것을 CTE(공통 테이블 식)라 부릅니다. 이 문장 하나가 실행되는 동안만 존재하는 임시 이름이라 테이블이 새로 생기지 않고, 복잡한 쿼리를 단계로 나눠 읽기 쉽게 만들 때 씁니다.')
b.nt('WITH 로 이름 붙여 쓰기', INTRO + '\n\n`scores` 는 반별(`class`) 시험 점수 8건(`student`, `score`)입니다. **85점 이상** 만 뽑은 결과에 `WITH` 로 `passed` 라는 이름을 붙이고, 그 `passed` 에서 **반별 인원 수**(별칭 `cnt`)를 구해 `class`, `cnt` 를 `class` 순서로 **`/tmp/q2.txt`** 에 저장하세요.',
     '`WITH passed AS (SELECT ... WHERE ...) SELECT class, COUNT(*) AS cnt FROM passed GROUP BY class ORDER BY class` 모양입니다. 괄호 안에는 조건 거르기만 둡니다.',
     "mariadb -N school -e 'WITH passed AS (SELECT * FROM scores WHERE score >= 85) SELECT class, COUNT(*) AS cnt FROM passed GROUP BY class ORDER BY class' > /tmp/q2.txt\ncat /tmp/q2.txt\n\n# 괄호 안 결과에 passed 라는 이름을 붙이고, 바깥 SELECT 에서 테이블처럼 쓴다",
     SCH, [chk('결과 파일이 있다', '[ -s /tmp/q2.txt ]'), chk('반별 85점 이상 인원이 맞다 (A 3명, B 1명)', EXP('/tmp/q2.txt', [['A', '3'], ['B', '1']]))])
b.nt('줄 번호 매기기 (ROW_NUMBER)', INTRO + '\n\n**윈도 함수** 는 행을 하나로 합치지 않고 **각 행 옆에** 순위·번호 같은 값을 붙여 줍니다. `함수() OVER (ORDER BY 정렬)` 모양이고, `ROW_NUMBER()` 는 정렬 순서대로 1, 2, 3, ... 번호를 매깁니다.\n\n모든 시험 기록을 **점수가 높은 순서대로**(점수가 같으면 `id` 순) 번호(별칭 `rn`)를 매겨 `id`, `score`, `rn` 을 `rn` 순서로 **`/tmp/q3.txt`** 에 저장하세요.',
     '`ROW_NUMBER() OVER (ORDER BY score DESC, id) AS rn` 처럼 `OVER` 안에 정렬 기준을 둡니다. 바깥 정렬(`ORDER BY rn`)도 잊지 마세요.',
     "mariadb -N school -e 'SELECT id, score, ROW_NUMBER() OVER (ORDER BY score DESC, id) AS rn FROM scores ORDER BY rn' > /tmp/q3.txt\ncat /tmp/q3.txt\n\n# 8행이 그대로 남고, 각 행 옆에 번호 열이 하나 붙는다 (GROUP BY 와 다른 점). 동점이어도 번호는 겹치지 않는다",
     SCH, [chk('결과 파일이 있다', '[ -s /tmp/q3.txt ]'), chk('8행에 1~8 번호가 순서대로 붙었다', EXP('/tmp/q3.txt', [['5', '95', '1'], ['1', '90', '2'], ['3', '90', '3'], ['2', '85', '4'], ['6', '80', '5'], ['7', '80', '6'], ['4', '70', '7'], ['8', '60', '8']]))])
b.choice('동점이 있을 때 순위는', '점수가 95, 90, 90, 80 인 네 명이 있습니다. 점수가 높은 순으로 `RANK()` 를 매기면 **80점의 순위** 는 몇 위일까요? (`RANK()` 는 같은 값에 같은 순위를 주고, 공동 순위 수만큼 다음 순위를 건너뜁니다.)', '95점 1위, 90점 둘은 공동 2위입니다. 그다음 순위가 몇 번인지 세어 보세요.',
         ['4위', '3위', '2위', '5위'], 0,
         '`RANK()` 는 공동 2위가 둘이면 3위를 건너뛰고 다음을 4위로 매깁니다(1, 2, 2, 4). 건너뛰지 않고 이어서 3위로 매기는 것은 `DENSE_RANK()`(1, 2, 2, 3)입니다. 다음 실습에서 직접 비교합니다.')
b.nt('같은 점수는 같은 순위 (RANK)', INTRO + '\n\n`RANK()` 는 값이 같으면 같은 순위를 주고, 그다음 순위는 건너뜁니다. 모든 시험 기록을 점수가 높은 순으로 순위(별칭 `rk`)를 매겨 `id`, `score`, `rk` 를 `rk`, `id` 순서로 **`/tmp/q5.txt`** 에 저장하세요.',
     '`RANK() OVER (ORDER BY score DESC) AS rk` 입니다. 바깥에서 `ORDER BY rk, id` 로 정렬합니다.',
     "mariadb -N school -e 'SELECT id, score, RANK() OVER (ORDER BY score DESC) AS rk FROM scores ORDER BY rk, id' > /tmp/q5.txt\ncat /tmp/q5.txt\n\n# 90점 둘은 공동 2위, 다음 85점은 3위가 아니라 4위. ROW_NUMBER 와 달리 동점은 같은 번호",
     SCH, [chk('결과 파일이 있다', '[ -s /tmp/q5.txt ]'), chk('공동 순위 뒤 번호를 건너뛴다 (1,2,2,4,5,5,7,8)', EXP('/tmp/q5.txt', [['5', '95', '1'], ['1', '90', '2'], ['3', '90', '2'], ['2', '85', '4'], ['6', '80', '5'], ['7', '80', '5'], ['4', '70', '7'], ['8', '60', '8']]))])
b.nt('점수 2등(공동 포함) 학생 찾기 (DENSE_RANK + WITH)', INTRO + '\n\n`DENSE_RANK()` 는 같은 값에 같은 순위를 주되 다음 순위를 **건너뛰지 않습니다**(1, 2, 2, 3, ...). 그런데 윈도 함수의 결과는 같은 쿼리의 `WHERE` 에 바로 쓸 수 없어서, **먼저 순위를 매긴 쿼리에 `WITH` 로 이름을 붙이고** 바깥 `SELECT` 에서 거릅니다.\n\n전체 시험 기록에서 점수가 높은 순으로 `DENSE_RANK()`(별칭 `dr`)를 매기고, **`dr` 이 2 인 학생의 이름**(`student`)을 `id` 순서로 **`/tmp/q6.txt`** 에 저장하세요.',
     '`WITH ranked AS (SELECT student, id, DENSE_RANK() OVER (ORDER BY score DESC) AS dr FROM scores) SELECT ... FROM ranked WHERE ...` 모양입니다. 이름만 한 줄에 하나씩 저장됩니다.',
     "mariadb -N school -e 'WITH ranked AS (SELECT id, student, DENSE_RANK() OVER (ORDER BY score DESC) AS dr FROM scores) SELECT student FROM ranked WHERE dr = 2 ORDER BY id' > /tmp/q6.txt\ncat /tmp/q6.txt\n\n# 점수가 90점인 kim·park 이 2등. RANK 였다면 다음이 4등이라 \"3등\" 을 찾을 수 없지만 DENSE_RANK 는 빠짐없이 이어진다",
     SCH, [chk('결과 파일이 있다', '[ -s /tmp/q6.txt ]'), chk('2등은 kim 과 park 이다', EXP('/tmp/q6.txt', [['kim'], ['park']]))])
b.fill('반별로 따로 순위 매기기', '반마다 **따로** 순위를 매기는 윈도 함수입니다. `OVER (...)` 안에서 묶음 기준을 정하는 키워드를 채우세요.', '`OVER` 안에서 "이 컬럼 값이 같은 행끼리 한 묶음" 이라고 정하는 말입니다. `GROUP BY` 와 이름이 비슷하지만 행을 합치지는 않습니다.',
       'SELECT class, student, RANK() OVER ({0} class ORDER BY score DESC) FROM scores;', ['PARTITION BY', 'GROUP BY', 'ORDER BY', 'DISTINCT'], [0],
       '`PARTITION BY 컬럼` 은 그 값이 같은 행끼리 묶고 묶음마다 따로 계산하게 합니다. 행을 합치지 않아서 모든 행이 그대로 남습니다. `OVER` 안에는 `GROUP BY` 를 쓸 수 없고, `ORDER BY` 는 묶음 안의 정렬 기준입니다.')
b.nt('반별 순위 (PARTITION BY)', INTRO + '\n\n`PARTITION BY class` 를 쓰면 **반마다 순위가 1 부터 다시** 시작합니다. 각 반 안에서 점수가 높은 순으로 `RANK()`(별칭 `rk`)를 매겨 `class`, `student`, `score`, `rk` 를 `class`, `rk`, `id` 순서로 **`/tmp/q8.txt`** 에 저장하세요.',
     '`RANK() OVER (PARTITION BY class ORDER BY score DESC) AS rk` 이고, 바깥 `ORDER BY class, rk, id` 로 정렬합니다. `id` 는 `SELECT` 에 안 넣어도 정렬에는 쓸 수 있습니다.',
     "mariadb -N school -e 'SELECT class, student, score, RANK() OVER (PARTITION BY class ORDER BY score DESC) AS rk FROM scores ORDER BY class, rk, id' > /tmp/q8.txt\ncat /tmp/q8.txt\n\n# A 반 kim·park 공동 1위, B 반 choi 1위. 반이 바뀌면 순위가 1 부터 다시 시작한다",
     SCH, [chk('결과 파일이 있다', '[ -s /tmp/q8.txt ]'), chk('반마다 순위가 따로 매겨졌다', EXP('/tmp/q8.txt', [['A', 'kim', '90', '1'], ['A', 'park', '90', '1'], ['A', 'lee', '85', '3'], ['A', 'oh', '70', '4'], ['B', 'choi', '95', '1'], ['B', 'han', '80', '2'], ['B', 'jung', '80', '2'], ['B', 'yoon', '60', '4']]))])
b.nt('누적 합계 (SUM ... OVER)', INTRO + '\n\n`daily` 테이블은 날짜별 방문자 수(`day`, `visitors`) 5건입니다. `SUM(컬럼) OVER (ORDER BY 날짜)` 처럼 집계 함수에 `OVER (ORDER BY ...)` 를 붙이면 **처음부터 현재 행까지의 누적 합계** 가 됩니다. 날짜 순서로 방문자 수의 누적 합계(별칭 `running`)를 붙여 `day`, `visitors`, `running` 을 **`/tmp/q9.txt`** 에 저장하세요.',
     '`SUM(visitors) OVER (ORDER BY day) AS running` 입니다. 바깥 정렬도 `ORDER BY day` 로 맞추세요.',
     "mariadb -N school -e 'SELECT day, visitors, SUM(visitors) OVER (ORDER BY day) AS running FROM daily ORDER BY day' > /tmp/q9.txt\ncat /tmp/q9.txt\n\n# 100, 220, 310, 460, 590. GROUP BY 합계와 달리 5행이 그대로 남고 합계가 한 줄씩 쌓인다",
     SCH, [chk('결과 파일이 있다', '[ -s /tmp/q9.txt ]'), chk('누적 합계가 쌓인다', EXP('/tmp/q9.txt', [['2026-03-01', '100', '100'], ['2026-03-02', '120', '220'], ['2026-03-03', '90', '310'], ['2026-03-04', '150', '460'], ['2026-03-05', '130', '590']]))])
b.nt('전날과 비교하기 (LAG)', INTRO + '\n\n`LAG(컬럼)` 은 정렬했을 때 **바로 앞 행의 값** 을 가져옵니다(첫 행은 앞이 없어 `NULL`). `daily` 에서 날짜 순서로 **전날 대비 방문자 증감**(별칭 `diff`, 오늘 방문자 - 전날 방문자)을 구해 `day`, `visitors`, `diff` 를 **`/tmp/q10.txt`** 에 저장하세요. 첫날은 `NULL` 로 나옵니다.',
     '`visitors - LAG(visitors) OVER (ORDER BY day) AS diff` 처럼 `LAG` 결과로 바로 뺄셈을 할 수 있습니다.',
     "mariadb -N school -e 'SELECT day, visitors, visitors - LAG(visitors) OVER (ORDER BY day) AS diff FROM daily ORDER BY day' > /tmp/q10.txt\ncat /tmp/q10.txt\n\n# 첫날은 앞 행이 없어 NULL, 이후 20, -30, 60, -20. 전일·전월 대비 같은 비교에 쓴다",
     SCH, [chk('결과 파일이 있다', '[ -s /tmp/q10.txt ]'), chk('전날 대비 증감이 맞다', EXP('/tmp/q10.txt', [['2026-03-01', '100', 'NULL'], ['2026-03-02', '120', '20'], ['2026-03-03', '90', '-30'], ['2026-03-04', '150', '60'], ['2026-03-05', '130', '-20']]))])
b.order('반별 1등 구하는 쿼리 조립', '각 반에서 **점수가 가장 높은 학생**(공동 1등 포함)을 뽑는 쿼리입니다. 순위를 먼저 매겨 이름을 붙이고, 그 이름에서 거르는 흐름입니다. 쓰는 순서대로 놓으세요.', '이름을 붙이는 문장이 먼저 있어야 바깥에서 그 이름을 쓸 수 있습니다.',
        ['SELECT class, student FROM ranked WHERE rk = 1', 'WITH ranked AS (', ')', 'SELECT class, student, RANK() OVER (PARTITION BY class ORDER BY score DESC) AS rk FROM scores'], [1, 3, 2, 0],
        '`WITH ranked AS (` 뒤에 반별 순위를 매기는 `SELECT` 를 두고 `)` 로 닫은 다음, 바깥 `SELECT` 가 `WHERE rk = 1` 로 1등만 거릅니다. 윈도 함수의 결과(`rk`)는 같은 쿼리의 `WHERE` 에 쓸 수 없어서 이렇게 한 단계 감싸 줍니다.')

if __name__ == '__main__': preview(b)
