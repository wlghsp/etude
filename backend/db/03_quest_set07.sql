-- 세트 7: 리눅스 압축과 아카이브 (order 1~9)
-- 실무 조합: -cvf, -tvf, -xvf, -czvf, -xzvf 중심
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (7,  1, 'tar 로 디렉토리를 하나로 묶기',
   '`tar` 는 여러 파일과 디렉토리를 **하나의 파일(아카이브)** 로 묶습니다. 백업, 전송, 배포에 쓰고, 서버 작업에서 가장 자주 쓰는 명령 중 하나입니다.

`/tmp/files` 디렉토리를 묶어 `/tmp/files.tar` 로 저장하세요. 묶이는 파일 목록이 화면에 출력되어야 합니다.',
   '`tar -cvf <만들파일> <대상>` 형식입니다.
- `c` : 아카이브 생성(create)
- `v` : 진행 중인 파일 목록 출력(verbose)
- `f` : 파일 이름 지정(file) — 반드시 마지막에 오고 바로 뒤에 파일 이름이 옵니다
`tar: Removing leading ''/''` 메시지가 나와도 정상입니다(절대 경로의 맨 앞 `/` 를 제거한다는 안내).',
   'tar -cvf /tmp/files.tar /tmp/files

# c : 만들기, v : 목록 출력, f : 파일 이름 지정',
   '["sh", "-c", "mkdir -p /tmp/files && echo hello > /tmp/files/a.txt && echo world > /tmp/files/b.txt"]',
   '["sh", "-c", "tar -tf /tmp/files.tar | grep -q a.txt"]'),

  (7,  2, 'tar 아카이브 안의 내용 확인하기',
   '압축을 풀기 전에 안에 무엇이 들어 있는지 먼저 확인하는 것이 안전합니다.

`/tmp/files.tar` 안에 들어 있는 파일 목록을 `/tmp/tar_list.txt` 에 저장하세요. (풀지 않고 목록만 봅니다)',
   '`tar -tvf <파일>` 형식입니다.
- `t` : 내용 목록 보기(list)
- `v` : 권한·크기·날짜까지 상세 출력
- `f` : 파일 이름 지정
출력을 `>` 로 파일에 저장하세요.',
   'tar -tvf /tmp/files.tar > /tmp/tar_list.txt

# t : 풀지 않고 목록만 보기',
   '["sh", "-c", "mkdir -p /tmp/files && echo hello > /tmp/files/a.txt && tar -cf /tmp/files.tar /tmp/files"]',
   '["sh", "-c", "grep -q a.txt /tmp/tar_list.txt"]'),

  (7,  3, 'tar 아카이브 풀기',
   '묶인 파일을 원래대로 꺼내는 것이 해제입니다. 대상 디렉토리를 지정하지 않으면 현재 위치에 풀려 어지러워질 수 있습니다.

`/tmp/files.tar` 를 `/tmp/extract` 디렉토리에 푸세요. 풀리는 파일 목록이 출력되어야 합니다.',
   '`tar -xvf <파일> -C <대상디렉토리>` 형식입니다.
- `x` : 해제(extract), `v` : 목록 출력, `f` : 파일 이름 지정
- `-C` : 이 디렉토리로 이동해서 풉니다(대상 디렉토리는 **먼저 만들어야** 합니다: `mkdir -p`)',
   'mkdir -p /tmp/extract && tar -xvf /tmp/files.tar -C /tmp/extract

# x : 풀기, -C : 풀 위치 지정',
   '["sh", "-c", "mkdir -p /tmp/files && echo hello > /tmp/files/a.txt && tar -cf /tmp/files.tar /tmp/files"]',
   '["sh", "-c", "find /tmp/extract -name a.txt | grep -q a.txt"]'),

  (7,  4, 'tar.gz 로 묶고 압축하기',
   '`tar` 는 묶기만 하고 용량을 줄이지는 않습니다. `gzip` 압축을 함께 하면 용량이 크게 줄어 전송과 보관에 유리합니다. `.tar.gz` 는 현장에서 가장 많이 쓰는 형식입니다.

`/tmp/files` 디렉토리를 gzip 압축까지 적용해 `/tmp/archive.tar.gz` 로 만드세요. 묶이는 파일 목록이 출력되어야 합니다.',
   '`tar -czvf <만들파일> <대상>` 형식입니다. 앞의 `tar -cvf` 에 `z`(gzip 압축)가 추가된 것입니다.',
   'tar -czvf /tmp/archive.tar.gz /tmp/files

# c : 만들기, z : gzip 압축, v : 목록 출력, f : 파일 이름',
   '["sh", "-c", "mkdir -p /tmp/files && echo hello > /tmp/files/a.txt && echo world > /tmp/files/b.txt"]',
   '["sh", "-c", "tar -tzf /tmp/archive.tar.gz | grep -q a.txt"]'),

  (7,  5, 'tar.gz 안의 내용 확인하기',
   '압축된 아카이브도 풀지 않고 내용을 확인할 수 있습니다.

`/tmp/archive.tar.gz` 안의 파일 목록을 `/tmp/targz_list.txt` 에 저장하세요.',
   '`tar -tzvf <파일>` 형식입니다. `.gz` 파일을 읽으려면 `z` 옵션이 필요합니다(`t` 목록, `z` gzip, `v` 상세, `f` 파일). 결과를 `>` 로 저장하세요.',
   'tar -tzvf /tmp/archive.tar.gz > /tmp/targz_list.txt

# z 가 없으면 .gz 압축 파일을 읽지 못합니다',
   '["sh", "-c", "mkdir -p /tmp/files && echo hello > /tmp/files/a.txt && tar -czvf /tmp/archive.tar.gz /tmp/files"]',
   '["sh", "-c", "grep -q a.txt /tmp/targz_list.txt"]'),

  (7,  6, 'tar.gz 압축 풀기',
   '`.tar.gz` 는 `z` 옵션을 붙여 풉니다.

`/tmp/archive.tar.gz` 를 `/tmp/extract` 디렉토리에 푸세요. 풀리는 파일 목록이 출력되어야 합니다.',
   '`tar -xzvf <파일> -C <대상디렉토리>` 형식입니다(`x` 해제, `z` gzip, `v` 목록 출력, `f` 파일, `-C` 풀 위치). 대상 디렉토리는 먼저 `mkdir -p` 로 만드세요.',
   'mkdir -p /tmp/extract && tar -xzvf /tmp/archive.tar.gz -C /tmp/extract',
   '["sh", "-c", "mkdir -p /tmp/files && echo hello > /tmp/files/a.txt && tar -czvf /tmp/archive.tar.gz /tmp/files"]',
   '["sh", "-c", "find /tmp/extract -name a.txt | grep -q a.txt"]'),

  (7,  7, 'zip 으로 압축하기',
   '`zip` 은 윈도우·맥과도 호환되는 압축 형식이라, 다른 환경과 파일을 주고받을 때 씁니다.

`/tmp/files` 디렉토리를 zip 으로 압축해 `/tmp/files.zip` 으로 만드세요.',
   '`zip -r <만들파일> <대상>` 형식입니다. `-r` 은 디렉토리 안의 파일까지 재귀적으로(recursive) 포함합니다. `-r` 이 없으면 디렉토리 자체만 담기고 안의 파일은 빠집니다.',
   'zip -r /tmp/files.zip /tmp/files

# -r : 디렉토리 안의 내용까지 포함',
   '["sh", "-c", "mkdir -p /tmp/files && echo hello > /tmp/files/a.txt && echo world > /tmp/files/b.txt"]',
   '["sh", "-c", "unzip -l /tmp/files.zip | grep -q a.txt"]'),

  (7,  8, 'zip 압축 풀기',
   'zip 파일은 `unzip` 으로 풉니다.

`/tmp/files.zip` 을 `/tmp/unzipped` 디렉토리에 푸세요.',
   '`unzip <파일> -d <대상디렉토리>` 형식입니다. `-d` 는 풀 위치(directory)를 지정하며, 없으면 자동으로 만들어 줍니다.',
   'unzip /tmp/files.zip -d /tmp/unzipped

# -d : 풀 디렉토리 지정',
   '["sh", "-c", "mkdir -p /tmp/files && echo hello > /tmp/files/a.txt && zip -r /tmp/files.zip /tmp/files"]',
   '["sh", "-c", "find /tmp/unzipped -name a.txt | grep -q a.txt"]'),

  (7,  9, '압축 형식별 파일 크기 비교하기',
   '같은 디렉토리도 형식에 따라 압축 후 크기가 달라질 수 있습니다. 전송이나 보관 방식을 고를 때 비교해 봅니다.

`/tmp/files` 디렉토리를 `tar.gz` 와 `zip` 두 가지로 압축한 뒤(`/tmp/compare.tar.gz`, `/tmp/compare.zip`), 두 파일의 크기를 `/tmp/size_compare.txt` 에 저장하세요.',
   '1) `tar -czvf /tmp/compare.tar.gz /tmp/files`
2) `zip -r /tmp/compare.zip /tmp/files`
3) `ls -lh <파일1> <파일2>` — `-l` 상세 정보(크기 포함), `-h` 사람이 읽기 쉬운 단위(KB, MB). 결과를 `>` 로 저장하세요.',
   'tar -czvf /tmp/compare.tar.gz /tmp/files && zip -r /tmp/compare.zip /tmp/files && ls -lh /tmp/compare.tar.gz /tmp/compare.zip > /tmp/size_compare.txt

# ls -lh : 크기를 읽기 쉬운 단위로',
   '["sh", "-c", "mkdir -p /tmp/files && for i in $(seq 1 10); do echo content$i > /tmp/files/file$i.txt; done"]',
   '["sh", "-c", "grep -q compare /tmp/size_compare.txt"]');

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (7, 10, 'gzip 으로 파일 하나 압축하기',
   '`tar` 는 여러 파일을 **묶는** 도구이고, 파일 **하나**를 압축할 때는 `gzip` 을 씁니다. 로그 파일처럼 큰 텍스트를 줄일 때 많이 씁니다.

`/tmp/gz/notes.txt` 를 `gzip` 으로 압축하세요.

완료 조건: `/tmp/gz/notes.txt.gz` 가 있어야 합니다. (`gzip` 은 기본적으로 **원본을 지우고** `.gz` 파일만 남깁니다)',
   '`gzip 파일이름` 입니다. 압축하면 `파일이름.gz` 가 만들어지고 원본 `파일이름` 은 사라집니다. 원본을 남기려면 `-k`(keep) 옵션을 붙입니다. 결과는 `ls -l /tmp/gz` 로 확인하세요.',
   'gzip /tmp/gz/notes.txt

# 원본(notes.txt)은 사라지고 notes.txt.gz 만 남는다 (원본을 남기려면 gzip -k)
ls -l /tmp/gz',
   '["sh", "-c", "mkdir -p /tmp/gz && for i in $(seq 1 200); do echo \\"line $i of the notes file\\"; done > /tmp/gz/notes.txt"]',
   '["sh", "-c", "[ -f /tmp/gz/notes.txt.gz ] && [ ! -f /tmp/gz/notes.txt ]"]');

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (7, 11, 'gunzip 으로 .gz 파일 풀기',
   '`.gz` 로 압축된 파일은 `gunzip` 으로 풉니다. (`gzip -d` 와 같습니다) `tar.gz` 가 아니라 **파일 하나**를 `gzip` 으로만 압축한 파일입니다.

`/tmp/gz2/data.txt.gz` 를 풀어서 원래 파일 `data.txt` 를 만드세요.

완료 조건: `/tmp/gz2/data.txt` 가 있고 내용에 `hello` 가 있어야 합니다.',
   '`gunzip 파일.gz` 입니다. 풀면 `.gz` 를 뗀 이름의 파일이 만들어지고 `.gz` 파일은 사라집니다. `.gz` 를 남기려면 `-k` 를 붙입니다. 풀린 내용은 `cat` 으로 확인하세요.',
   'gunzip /tmp/gz2/data.txt.gz

# data.txt.gz 가 data.txt 로 풀린다 (gzip -d 와 같다, .gz 를 남기려면 -k)
cat /tmp/gz2/data.txt',
   '["sh", "-c", "mkdir -p /tmp/gz2 && echo hello gzip > /tmp/gz2/data.txt && gzip /tmp/gz2/data.txt"]',
   '["sh", "-c", "[ -f /tmp/gz2/data.txt ] && grep -q hello /tmp/gz2/data.txt"]');
