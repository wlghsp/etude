-- 리눅스 세트 181. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set181.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 1, '리눅스', '기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 1);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 181, '압축과 파일 검증: gzip·tar·zip, 체크섬, diff·patch, split 한 줄씩', '파일을 묶고 줄이고 검증하는 기본기를 한 개념씩 반복합니다. gzip 이 원본을 .gz 로 바꾸는 것과 -k·-c·gunzip, zcat·zgrep, gzip 의 오류와 -r·-t, tar 의 목록 보기·-C·한 파일만 풀기·--strip-components, --exclude, 절대 경로 안내와 -P, -a 와 자동 인식, tar 와 파이프, 압축된 tar 는 갱신할 수 없는 것, zip 의 -r·-l·-d·-o·-t·-p, 해시 길이와 줄바꿈이 해시를 바꾸는 것, sha256sum -c 의 OK·FAILED 와 종료 코드, diff 의 형식과 종료 코드와 cmp, patch 의 --dry-run·-R·-b·.rej 와 디렉터리 패치(-p1), split 으로 나누고 cat 으로 합치기를 짧은 객관식·빈칸·순서 문제로 익히고, 내려받은 파일 검증하고 풀기, 패치로 만들어 적용하기, 큰 파일 나눠 옮기기, 제외 패턴으로 묶고 확인하기의 순서를 연습합니다.', 'quiz', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 181);
UPDATE quest_set SET display_order = 9, unit_id = (SELECT id FROM unit WHERE id = 1), icon = '📦' WHERE id = 181;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 181, 1, 'gzip 은 원본을 바꾼다', '`gzip g1.txt` 를 하면 파일은 어떻게 될까요? 원본을 남기려면 어떻게 할까요? `gunzip` 은 무엇을 할까요?', '압축하면 원래 이름의 파일이 사라져요.', NULL, NULL, '[]', 'choice', '["`g1.txt` 와 `g1.txt.gz` 가 둘 다 남는다", "`gzip` 은 파일 이름을 바꾸지 않고 내용만 압축한다", "`g1.txt` 가 사라지고 `g1.txt.gz` 만 남는다. `gzip -k` 는 원본을 남기고, `gzip -c 파일 > 파일.gz` 도 원본을 남긴다. `gunzip 파일.gz` 은 압축을 풀어 `.gz` 를 지우고 원래 파일로 되돌린다", "`gunzip` 은 `.gz` 파일을 그대로 두고 복사본을 만든다"]', 2, '`gzip -d` 는 `gunzip` 과 같은 일을 합니다. 압축 전에 원본을 따로 보관할지 먼저 생각하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 181 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 181, 2, 'zcat 과 zgrep', '`zcat 파일.gz` 와 `zgrep -c 5 파일.gz` 는 무엇을 할까요? 이때 `파일.gz` 은 어떻게 될까요?', '풀지 않고 읽어요.', NULL, NULL, '[]', 'choice', '["`zcat` 은 파일을 풀어 원본으로 바꾸고 `.gz` 를 지운다", "압축을 풀지 않고 내용을 화면에 출력(`zcat`)하거나 그 안에서 검색(`zgrep`)한다. `.gz` 파일은 그대로 남는다", "`zgrep` 은 압축된 파일에서는 쓸 수 없다", "`zcat` 은 파일을 압축한다"]', 1, '`zcat 파일.gz | head -2` 처럼 파이프로 이어 앞부분만 볼 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 181 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 181, 3, 'gzip 의 오류와 -r, -t', '이미 `dup.txt.gz` 가 있는데 `gzip dup.txt` 를 하면 어떻게 될까요? 디렉터리에 `gzip dd` 를 하면요? `gzip -r rr` 은요? `gzip -t` 는요?', 'gzip 은 파일에만 동작해요.', NULL, NULL, '[]', 'choice', '["이미 있으면 `already exists; not overwritten` 으로 묻고 덮어쓰지 않는다. 디렉터리에는 `is a directory -- ignored` 라며 건너뛰고, `-r` 은 디렉터리 안의 파일을 각각 `.gz` 로 압축한다. `gzip -t` 는 압축 파일이 온전한지 검사하며 정상이면 종료 코드 0, 깨졌으면 1 이다", "`gzip dd` 는 디렉터리 전체를 하나의 `.gz` 로 만든다", "`gzip -r` 은 디렉터리를 하나의 파일로 묶는다", "`gzip -t` 는 압축을 풀어 원본을 덮어쓴다"]', 0, '디렉터리를 하나로 묶으려면 `tar` 를 먼저 쓰고 `gzip` 을 적용합니다(`tar -czf`).', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 181 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 181, 4, 'tar 로 내용 보고 골라 풀기', '`tar -tzf proj.tar.gz`, `tar -xzf proj.tar.gz -C out`, `tar -xzf proj.tar.gz -C out proj/README`, `tar -xzf proj.tar.gz -C out --strip-components=1` 은 각각 무엇을 할까요?', 't 는 목록, C 는 풀 폴더예요.', NULL, NULL, '[]', 'choice', '["`-C` 는 압축 수준을 정한다", "`--strip-components=1` 은 파일 하나를 건너뛴다", "없는 파일을 지정해도 오류 없이 끝난다", "목록만 보고, `out` 폴더에 풀고, `proj/README` 한 파일만 풀고, 맨 앞 경로 한 단계(`proj/`)를 떼고 `out/README` 처럼 푼다. 없는 파일을 지정하면 `Not found in archive` 와 종료 코드 2 이다"]', 3, '`tar -xzOf 아카이브 파일` 은 파일을 풀지 않고 내용만 화면에 출력합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 181 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 181, 5, 'tar --exclude', '`tar -czf nolog.tar.gz --exclude=''*.log'' proj` 와 `--exclude=logs` 는 각각 무엇을 뺄까요?', '패턴에 맞는 이름을 빼요.', NULL, NULL, '[]', 'choice', '["`--exclude` 는 압축 후에 파일을 삭제한다", "`--exclude` 는 패턴을 쓸 수 없다", "`--exclude=''*.log''` 는 `.log` 로 끝나는 파일을 빼지만 빈 `proj/logs/` 디렉터리 항목은 남고, `--exclude=logs` 는 `logs` 라는 이름의 항목(그 안의 파일 포함)을 뺀다", "`--exclude=''*.log''` 는 `logs` 디렉터리까지 모두 뺀다"]', 2, '`tar -tzf` 로 목록을 확인해 빠질 것이 빠졌는지 봅니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 181 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 181, 6, 'tar 의 절대 경로', '`tar -czf abs.tar.gz /tmp/x/proj/README` 처럼 절대 경로를 주면 어떤 메시지가 나올까요? `-P` 는요?', '맨 앞 슬래시를 떼요.', NULL, NULL, '[]', 'choice', '["절대 경로는 오류로 거부된다", "`tar: Removing leading ''/'' from member names` 라는 안내가 나오고 아카이브에는 맨 앞 `/` 가 빠진 경로로 저장된다. `-P`(`--absolute-names`)를 쓰면 절대 경로를 그대로 둔다", "항상 절대 경로 그대로 저장된다", "`-P` 는 압축 수준을 정한다"]', 1, '풀 때 엉뚱한 곳(예: 시스템 폴더)을 덮어쓰지 않게 하는 안전장치입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 181 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 181, 7, 'tar 의 자동 인식', '`tar -caf auto.tar.gz proj` 의 `-a` 는 무엇을 할까요? 풀 때 `tar -xf proj.tar.gz` 처럼 `-z` 없이 써도 될까요?', '확장자나 파일 내용으로 압축 방식을 알아내요.', NULL, NULL, '[]', 'choice', '["`-a` 는 파일 확장자(`.tar.gz`)를 보고 압축 방식을 정해 준다. 풀거나 목록을 볼 때는 `-z` 를 주지 않아도 압축 방식을 자동으로 알아낸다 (`tar -xf proj.tar.gz` 가 동작한다)", "`-a` 는 파일을 아카이브 끝에 추가한다", "풀 때 `-z` 가 없으면 항상 오류가 난다", "`-a` 는 모든 파일의 권한을 바꾼다"]', 0, '`tar -tf` 로 목록을 볼 때도 압축 방식을 따로 알려 줄 필요가 없습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 181 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 181, 8, 'tar 와 파이프', '`tar -cf - -C proj . | tar -xf - -C copydst` 는 무엇을 할까요? `-` 는 무엇일까요?', '한쪽은 만들고 한쪽은 풀어요.', NULL, NULL, '[]', 'choice', '["`-` 는 압축 수준을 뜻한다", "이 명령은 `proj` 를 삭제한다", "`copydst` 에는 아무것도 풀리지 않는다", "`proj` 의 내용을 아카이브로 만들어 파이프로 보내고 `copydst` 에 바로 풀어 폴더를 복사한다. `-` 는 파일 대신 표준 출력·입력을 뜻한다"]', 3, '`tar -czf - proj | tar -tzf -` 처럼 압축한 결과를 파일 없이 바로 확인할 수도 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 181 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 181, 9, 'tar 갱신과 권한', '압축하지 않은 `plain.tar` 에 `tar -rf plain.tar extra.txt` 를 하면 어떻게 될까요? `.tar.gz` 에는요? 파일 권한 750 은 아카이브를 풀면 유지될까요?', '압축된 아카이브는 이어 붙일 수 없어요.', NULL, NULL, '[]', 'choice', '["`.tar.gz` 에도 파일을 추가할 수 있다", "풀면 권한이 항상 644 로 바뀐다", "압축하지 않은 tar 에는 `extra.txt` 가 추가되지만, `.tar.gz` 에는 `Cannot update compressed archives` 오류가 난다. 권한(750)은 풀어도 그대로 유지된다", "`-r` 은 아카이브를 읽기 전용으로 만든다"]', 2, '압축된 아카이브를 바꾸려면 풀어서 고친 뒤 다시 묶어야 합니다. 압축하지 않은 작은 tar 도 10240바이트 단위로 크기가 채워집니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 181 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 181, 10, 'zip 과 unzip', '`zip proj.zip proj` 와 `zip -r proj.zip proj` 의 차이는 무엇일까요? `unzip -l`, `unzip -d out`, `unzip -o`, `unzip -t`, `unzip -p` 는 각각 무엇을 할까요?', '디렉터리는 -r 이 있어야 안의 파일까지 담겨요.', NULL, NULL, '[]', 'choice', '["`-r` 없이도 안의 파일이 모두 담긴다", "`-r` 없이는 디렉터리 항목(`proj/`)만 담기고 `-r` 이어야 안의 파일까지 담긴다. `-l` 은 목록, `-d` 는 풀 폴더, `-o` 는 확인 없이 덮어쓰기, `-t` 는 무결성 검사, `-p` 는 파일 내용을 화면에 출력한다", "`unzip -d` 는 압축 수준을 정한다", "`unzip -p` 는 비밀번호를 지정한다"]', 1, '`zip -qr 파일.zip 폴더 -x ''*.log''` 처럼 `-x` 로 패턴을 제외할 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 181 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 181, 11, '해시값의 성질', '`sha256sum`, `md5sum`, `sha1sum` 의 해시 길이는 각각 몇 자일까요? `echo hello` 와 `echo -n hello` 의 해시는 같을까요? 내용이 같고 이름만 다른 파일은요?', '내용이 한 글자만 달라도 완전히 달라져요.', NULL, NULL, '[]', 'choice', '["`sha256sum` 은 64자, `md5sum` 은 32자, `sha1sum` 은 40자이다. `echo hello` 는 줄바꿈이 붙어 `echo -n hello` 와 해시가 다르고, 내용이 같으면 파일 이름이 달라도 해시가 같다", "셋 다 해시 길이가 같다", "줄바꿈은 해시에 영향을 주지 않는다", "파일 이름이 다르면 해시도 항상 다르다"]', 0, '빈 파일의 `md5sum` 은 `d41d8cd98f00b204e9800998ecf8427e` 입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 181 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 181, 12, 'sha256sum -c 로 검증', '`sha256sum c1.txt c2.txt > SUMS` 로 만든 목록을 `sha256sum -c SUMS` 로 검증합니다. 정상일 때, `c1.txt` 가 변조되었을 때, `c2.txt` 가 없을 때는 각각 어떻게 나올까요?', 'OK 와 FAILED 로 표시돼요.', NULL, NULL, '[]', 'choice', '["변조되어도 `OK` 로 나오고 종료 코드는 0 이다", "파일이 없으면 검증이 조용히 건너뛰어진다", "`SUMS` 파일에는 파일 이름이 들어가지 않는다", "정상이면 `c1.txt: OK`, `c2.txt: OK` 이고 종료 코드 0 이다. 변조되면 `c1.txt: FAILED` 와 `WARNING: 1 computed checksum did NOT match`, 파일이 없으면 `c2.txt: FAILED open or read` 와 `WARNING: 1 listed file could not be read` 가 나오며 둘 다 종료 코드 1 이다. `--quiet` 는 OK 줄을 숨긴다"]', 3, '목록의 각 줄은 `해시  파일이름` 모양입니다. 다운로드한 파일의 변조나 손상을 확인할 때 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 181 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 181, 13, 'diff 와 cmp', '`diff o.txt n.txt` 의 종료 코드는 같을 때, 다를 때, 파일이 없을 때 각각 몇일까요? 기본 출력의 `2c2`, `3a4` 와 `diff -u` 의 `@@ -1,3 +1,4 @@` 는 무엇일까요? `cmp` 는 무엇을 알려 줄까요?', '종료 코드로 같은지 알 수 있어요.', NULL, NULL, '[]', 'choice', '["`diff` 는 다르면 종료 코드 0 이다", "`cmp` 는 달라진 줄을 모두 보여 준다", "같으면 0, 다르면 1, 파일이 없는 등 오류면 2 이다. `2c2` 는 둘째 줄 변경, `3a4` 는 3번째 줄 뒤에 4번째 줄 추가이고, `-u` 의 `@@ -1,3 +1,4 @@` 는 원본 1~3번째 줄이 새 파일 1~4번째 줄이 되었다는 뜻이며 `-`·`+` 로 지운 줄과 더한 줄을 보여 준다. `cmp` 는 처음으로 다른 바이트의 위치(`char 3, line 2`)만 알려 주고 같으면 아무것도 출력하지 않는다(종료 코드 0)", "`-u` 는 파일을 합쳐 준다"]', 2, '`diff -q` 는 `Files ... differ` 만 보여 주고, `diff -w` 는 공백 차이를 무시합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 181 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 181, 14, 'patch 로 변경 적용하기', '`diff -u o.txt n.txt > ch.patch` 로 만든 패치를 `patch w.txt < ch.patch` 로 적용합니다. `--dry-run`, 이미 적용한 패치를 다시 적용하기, `-R`, `-b` 는 각각 어떻게 동작할까요?', '미리 확인하고, 되돌릴 수도 있어요.', NULL, NULL, '[]', 'choice', '["`--dry-run` 은 파일을 바꾼 뒤 원래대로 되돌린다", "`--dry-run` 은 파일을 바꾸지 않고 적용 가능 여부만 보여 준다. 이미 적용한 패치를 다시 하면 `Reversed (or previously applied) patch detected! Assume -R?` 라고 묻는다. `-R` 은 패치를 거꾸로 적용해 되돌리고, `-b` 는 원본을 `.orig` 로 남긴다. 적용하지 못한 부분은 `.rej` 파일에 남는다", "이미 적용한 패치도 오류 없이 한 번 더 적용된다", "`-R` 은 패치 파일을 삭제한다"]', 1, '`.rej` 가 생기면 그 부분은 손으로 반영해야 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 181 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 181, 15, '원본 유지하며 압축', '`gzip` 이 **원본 파일을 남기고** 압축하게 하는 옵션을 채우세요.', '"keep"의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-k", "-c", "-r", "-t"]', NULL, '`-c` 는 결과를 화면으로 보내 `>` 로 파일에 저장할 수 있습니다.', '[0]', 'gzip {0} file', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 181 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 181, 16, '풀지 않고 보기', '`.gz` 파일의 내용을 **풀지 않고 화면에 출력**하는 명령을 채우세요.', '"cat" 앞에 z 가 붙어요.', NULL, NULL, '[]', 'fill', '["zcat", "gcat", "ucat", "catz"]', NULL, '압축 파일은 그대로 남습니다.', '[0]', '{0} file.gz', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 181 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 181, 17, '압축 파일 검사', '`gzip` 파일이 **온전한지 검사**하는 옵션을 채우세요.', '"test"의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-t", "-l", "-c", "-v"]', NULL, '정상이면 종료 코드 0 입니다.', '[0]', 'gzip {0} file.gz', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 181 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 181, 18, '풀 폴더 정하기', '`tar` 로 **풀 폴더를 정하는** 옵션을 채우세요.', '"change dir"의 C 예요.', NULL, NULL, '[]', 'fill', '["-C", "-d", "-o", "-f"]', NULL, '폴더는 미리 만들어 두어야 합니다.', '[0]', 'tar -xzf a.tgz {0} out', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 181 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 181, 19, '패턴 제외', '`tar` 로 묶을 때 패턴에 맞는 파일을 **제외**하는 옵션을 채우세요.', '"제외하다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["--exclude", "--skip", "--ignore", "--except"]', NULL, '빠진 것은 `tar -tzf` 로 확인합니다.', '[0]', 'tar -czf a.tgz {0}=''*.log'' proj', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 181 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 181, 20, '앞 경로 떼기', '아카이브 안의 **맨 앞 디렉터리 한 단계를 떼고** 푸는 옵션을 채우세요.', '"구성 요소 벗기기"를 이어 붙인 이름이에요.', NULL, NULL, '[]', 'fill', '["--strip-components", "--cut-dirs", "--remove-prefix", "--skip-dirs"]', NULL, '`proj/README` 가 `out/README` 가 됩니다.', '[0]', 'tar -xzf a.tgz -C out {0}=1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 181 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 181, 21, 'zip 풀 폴더', '`unzip` 으로 **풀 폴더를 정하는** 옵션을 채우세요.', '"directory"의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-d", "-C", "-o", "-p"]', NULL, '`-o` 는 확인 없이 덮어씁니다.', '[0]', 'unzip file.zip {0} out', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 181 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 181, 22, '체크섬 검증', '`sha256sum` 이 목록 파일(`SUMS`)대로 **검증**하는 옵션을 채우세요.', '"check"의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-c", "-t", "-v", "-s"]', NULL, '변조되면 `FAILED` 와 종료 코드 1 입니다.', '[0]', 'sha256sum {0} SUMS', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 181 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 181, 23, 'unified 형식', '`diff` 가 **unified 형식**(`@@ ... @@`)으로 출력하게 하는 옵션을 채우세요.', '"unified"의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-u", "-y", "-q", "-w"]', NULL, '`patch` 가 읽기 좋은 형식입니다.', '[0]', 'diff {0} old new > p.patch', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 181 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 181, 24, '적용해 보기만', '`patch` 가 **파일을 바꾸지 않고 적용 가능 여부만** 확인하게 하는 옵션을 채우세요.', '"마른 상태로 실행"이라는 뜻의 단어예요.', NULL, NULL, '[]', 'fill', '["--dry-run", "--check", "--test", "--preview"]', NULL, '문제가 없으면 같은 명령에서 `--dry-run` 만 빼고 적용합니다.', '[0]', 'patch {0} w.txt < p.patch', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 181 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 181, 25, '바이트로 나누기', '큰 파일을 **지정한 바이트 크기로 나누는** `split` 옵션을 채우세요.', '"bytes"의 첫 글자예요.', NULL, NULL, '[]', 'fill', '["-b", "-l", "-n", "-d"]', NULL, '`-l` 은 줄 수로 나눕니다.', '[0]', 'split {0} 1000 big.bin part_', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 181 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 181, 26, '내려받은 파일 검증하고 풀기', '내려받은 아카이브를 검증한 뒤 안전하게 푸는 순서입니다. 순서에 맞게 놓아 보세요.', '목록 준비 → 검증 → 목록 확인 → 풀기 순서예요.', NULL, NULL, '[]', 'order', '["제공된 체크섬 목록(`SUMS`)을 아카이브와 같은 폴더에 둔다", "`sha256sum -c SUMS` 로 `OK` 인지 확인한다 (`FAILED` 이면 종료 코드 1 이므로 중단한다)", "`tar -tzf 파일.tar.gz` 로 어떤 파일이 들어 있는지 확인한다", "`tar -xzf 파일.tar.gz -C 폴더` 로 별도의 폴더에 푼다"]', NULL, '검증이 실패한 파일은 사용하지 말고 다시 받으세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 181 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 181, 27, '수정 사항을 패치로 만들어 적용하기', '원본과 수정본의 차이를 패치로 만들어 다른 곳에 적용하는 순서입니다. 순서에 맞게 놓아 보세요.', '패치 만들기 → 미리 확인 → 적용 → 되돌려 보기 순서예요.', NULL, NULL, '[]', 'order', '["`diff -u 원본 수정본 > ch.patch` 로 패치를 만든다", "`patch --dry-run 대상 < ch.patch` 로 적용 가능한지 확인한다", "`patch 대상 < ch.patch` 로 실제로 적용한다", "필요하면 `patch -R 대상 < ch.patch` 로 되돌려 원래대로인지 확인한다"]', NULL, '여러 파일이 든 폴더는 `diff -ruN` 으로 만들고 `patch -p1` 로 적용합니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 181 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 181, 28, '큰 파일을 나눠 옮기기', '큰 파일을 조각으로 나눠 옮긴 뒤 원래대로 합치고 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '나누기 → 해시 기록 → 합치기 → 비교 순서예요.', NULL, NULL, '[]', 'order', '["`split -b 1000 big.bin part_` 로 조각으로 나눈다", "원본의 `sha256sum big.bin` 값을 기록해 둔다", "조각들을 옮긴 뒤 `cat part_* > restored.bin` 으로 이름 순서대로 합친다", "`sha256sum restored.bin` 이 기록한 값과 같은지(또는 `cmp` 가 아무것도 출력하지 않는지) 확인한다"]', NULL, '조각이 하나라도 빠지면 크기가 모자라지만 `cat` 은 오류 없이 합칩니다. 해시 비교로 꼭 확인하세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 181 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 181, 29, '제외 패턴으로 묶고 확인하기', '로그 파일을 빼고 디렉터리를 묶은 뒤 내용을 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '묶기 → 목록 확인 → 풀기 → 파일 확인 순서예요.', NULL, NULL, '[]', 'order', '["`tar -czf nolog.tar.gz --exclude=''*.log'' proj` 로 묶는다", "`tar -tzf nolog.tar.gz` 로 `.log` 파일이 목록에 없는지 확인한다", "`tar -xzf nolog.tar.gz -C out` 으로 새 폴더에 푼다", "`find out -type f` 로 풀린 파일이 의도한 것뿐인지 확인한다"]', NULL, '`--exclude` 는 이름 패턴이라 빈 디렉터리 항목은 남을 수 있습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 181 AND order_index = 29);
