-- 보강 문제: 세트 7 에 gzip·gunzip, 세트 21 에 userdel 을 추가한다. 여러 번 실행해도 안전하도록 NOT EXISTS 가드를 둔다. docs/specs/spec_gap_fill_batch.md
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 7, 10, 'gzip 으로 파일 하나 압축하기',
   '`tar` 는 여러 파일을 **묶는** 도구이고, 파일 **하나**를 압축할 때는 `gzip` 을 씁니다. 로그 파일처럼 큰 텍스트를 줄일 때 많이 씁니다.

`/tmp/gz/notes.txt` 를 `gzip` 으로 압축하세요.

완료 조건: `/tmp/gz/notes.txt.gz` 가 있어야 합니다. (`gzip` 은 기본적으로 **원본을 지우고** `.gz` 파일만 남깁니다)',
   '`gzip 파일이름` 입니다. 압축하면 `파일이름.gz` 가 만들어지고 원본 `파일이름` 은 사라집니다. 원본을 남기려면 `-k`(keep) 옵션을 붙입니다. 결과는 `ls -l /tmp/gz` 로 확인하세요.',
   'gzip /tmp/gz/notes.txt

# 원본(notes.txt)은 사라지고 notes.txt.gz 만 남는다 (원본을 남기려면 gzip -k)
ls -l /tmp/gz',
   '["sh", "-c", "mkdir -p /tmp/gz && for i in $(seq 1 200); do echo \\"line $i of the notes file\\"; done > /tmp/gz/notes.txt"]',
   '["sh", "-c", "[ -f /tmp/gz/notes.txt.gz ] && [ ! -f /tmp/gz/notes.txt ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 7 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 7, 11, 'gunzip 으로 .gz 파일 풀기',
   '`.gz` 로 압축된 파일은 `gunzip` 으로 풉니다. (`gzip -d` 와 같습니다) `tar.gz` 가 아니라 **파일 하나**를 `gzip` 으로만 압축한 파일입니다.

`/tmp/gz2/data.txt.gz` 를 풀어서 원래 파일 `data.txt` 를 만드세요.

완료 조건: `/tmp/gz2/data.txt` 가 있고 내용에 `hello` 가 있어야 합니다.',
   '`gunzip 파일.gz` 입니다. 풀면 `.gz` 를 뗀 이름의 파일이 만들어지고 `.gz` 파일은 사라집니다. `.gz` 를 남기려면 `-k` 를 붙입니다. 풀린 내용은 `cat` 으로 확인하세요.',
   'gunzip /tmp/gz2/data.txt.gz

# data.txt.gz 가 data.txt 로 풀린다 (gzip -d 와 같다, .gz 를 남기려면 -k)
cat /tmp/gz2/data.txt',
   '["sh", "-c", "mkdir -p /tmp/gz2 && echo hello gzip > /tmp/gz2/data.txt && gzip /tmp/gz2/data.txt"]',
   '["sh", "-c", "[ -f /tmp/gz2/data.txt ] && grep -q hello /tmp/gz2/data.txt"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 7 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd)
SELECT 21, 16, '사용자를 삭제하고 홈 디렉터리까지 정리하기',
   '퇴사나 계정 정리로 사용자를 지울 때 `userdel 이름` 만 쓰면 **계정만** 지워지고 **홈 디렉터리(`/home/이름`)와 파일은 남습니다.** 남은 파일은 나중에 같은 번호(UID)를 받은 다른 사용자가 열 수 있어 보안상 정리해야 합니다.

사용자 `olduser` 를 삭제하고 **홈 디렉터리도 함께** 지우세요.

완료 조건: 사용자 `olduser` 가 없고 `/home/olduser` 도 없어야 합니다.',
   '`userdel -r 이름` 입니다. (`-r` 은 remove 로 홈 디렉터리와 메일 보관함까지 함께 삭제) 먼저 `id olduser` 와 `ls -ld /home/olduser` 로 계정과 홈이 있는지 확인하고, 삭제한 뒤 다시 확인해 보세요.',
   'userdel -r olduser

# -r : 홈 디렉터리와 메일 보관함까지 삭제
id olduser          # 오류: no such user
ls -ld /home/olduser # 오류: 없음',
   '["sh", "-c", "useradd -m olduser >/dev/null 2>&1; echo data > /home/olduser/file.txt"]',
   '["sh", "-c", "! id olduser >/dev/null 2>&1 && [ ! -d /home/olduser ]"]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 21 AND order_index = 16);

