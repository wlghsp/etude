import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 581: 백업·복원 손연습(tar 증분, 체크섬, 부분 복원, 복원 순서). 명세: docs/specs/spec_gap_set581.md
# 샌드박스 linux(비특권). rsync 가 이미지에 없어 tar 와 sha256sum 으로 구성한다.

BASE = """rm -rf /tmp/src /tmp/restore /tmp/part /tmp/data
rm -f /tmp/*.tar.gz /tmp/*.snar /tmp/*.sha256 /tmp/*.txt
mkdir -p /tmp/src/docs /tmp/src/logs
echo alpha > /tmp/src/a.txt
echo bravo > /tmp/src/b.txt
echo "quarterly report" > /tmp/src/docs/report.txt
echo "meeting notes" > /tmp/src/docs/notes.txt
echo "log line" > /tmp/src/logs/x.log
"""
S81 = BASE + "true"
S81_INC = BASE + """tar --listed-incremental=/tmp/backup.snar -czf /tmp/level0.tar.gz -C /tmp/src .
sleep 1
echo "bravo v2" > /tmp/src/b.txt
echo "new file" > /tmp/src/new.txt
true"""
S81_RESTORE = BASE + """tar --listed-incremental=/tmp/backup.snar -czf /tmp/level0.tar.gz -C /tmp/src .
sleep 1
echo "bravo v2" > /tmp/src/b.txt
echo "new file" > /tmp/src/new.txt
tar --listed-incremental=/tmp/backup.snar -czf /tmp/level1.tar.gz -C /tmp/src .
true"""
S81_PART = BASE + """tar czf /tmp/backup_full.tar.gz -C /tmp/src .
true"""
S81_SUM = BASE + """mkdir -p /tmp/data
printf 'one\\n' > /tmp/data/a.txt
printf 'two\\n' > /tmp/data/b.txt
printf 'three\\n' > /tmp/data/c.txt
printf 'four\\n' > /tmp/data/d.txt
(cd /tmp/data && sha256sum a.txt b.txt c.txt d.txt > /tmp/data.sha256)
printf 'THREE changed\\n' > /tmp/data/c.txt
true"""

b = SetBuilder(581, '백업·복원 손연습: tar 전체·증분 백업, 체크섬 검증, 부분 복원, 복원 순서',
               '백업은 복원해 봐야 쓸모가 있습니다. tar 로 전체 백업과 증분 백업을 만들고, 체크섬으로 백업과 원본이 같은지 확인하고, 증분 백업이 쌓인 상태에서 올바른 순서로 복원하고, 전체 백업에서 파일 하나만 꺼내는 일을 직접 해 봅니다. 백업의 기본 원칙(RAID 는 백업이 아님, 복구 목표 시점)도 짚습니다.',
               'linux', '스토리지', 21, 841, '🗃️',
               [{"title": "GNU tar 증분 백업", "url": "https://www.gnu.org/software/tar/manual/html_node/Incremental-Dumps.html"}, {"title": "sha256sum 매뉴얼", "url": "https://man7.org/linux/man-pages/man1/sha256sum.1.html"}], 5)

# 1
b.nt('전체 백업 만들기', '`/tmp/src` 디렉터리 전체를 **gzip 으로 압축한 tar 백업**으로 만들어 `/tmp/full.tar.gz` 에 저장하세요. 압축을 풀었을 때 `/tmp/src` 바로 아래에 있던 `a.txt`, `docs/` 같은 이름이 최상위에 나오도록(상위 경로 없이) 만드세요.',
     '`tar` 로 묶고 gzip 압축하는 옵션 조합이 있습니다. 묶을 때 기준 디렉터리를 바꾸는 옵션으로 상위 경로를 뺄 수 있습니다.',
     "tar czf /tmp/full.tar.gz -C /tmp/src .\ntar tzf /tmp/full.tar.gz\n\n# 목록(t)으로 내용을 확인하는 습관이 중요하다. 백업 파일은 원본과 다른 디스크·서버에 보관해야 의미가 있다",
     S81, [chk('백업 파일이 압축 tar 다', 'tar tzf /tmp/full.tar.gz >/dev/null 2>&1'), chk('a.txt 가 최상위에 있다', 'tar tzf /tmp/full.tar.gz | grep -Eq "^(\\./)?a\\.txt$"'), chk('docs/report.txt 가 포함됐다', 'tar tzf /tmp/full.tar.gz | grep -Eq "^(\\./)?docs/report\\.txt$"')])
# 2
b.nt('체크섬 목록 만들기', '백업과 원본이 같은지 나중에 확인하려면 파일마다 **SHA-256 체크섬**을 적어 둡니다. `/tmp/src` 안의 **모든 일반 파일**의 체크섬을 `/tmp/src.sha256` 에 저장하세요. 이 파일로 `/tmp/src` 안에서 `sha256sum -c` 검증이 통과해야 합니다.',
     '체크섬 도구에 파일 목록을 넘기면 한 줄에 하나씩 적어 줍니다. 검증은 `/tmp/src` 안에서 하므로 경로가 그 기준이 되도록 만드세요.',
     "cd /tmp/src && find . -type f | sort | xargs sha256sum > /tmp/src.sha256\ncd /tmp/src && sha256sum -c /tmp/src.sha256\n\n# 체크섬이 맞으면 내용이 한 비트도 다르지 않다는 뜻이다. 복원 후 원본(또는 백업 시점의 목록)과 대조해 복원이 정확한지 확인한다",
     S81, [chk('검증이 통과한다', 'cd /tmp/src && sha256sum -c /tmp/src.sha256 >/dev/null 2>&1'), chk('모든 파일이 들어 있다', '[ "$(wc -l < /tmp/src.sha256)" -eq "$(find /tmp/src -type f | wc -l)" ]')])
# 3
b.nt('증분 백업 만들기', '`/tmp/level0.tar.gz` 는 `/tmp/src` 의 **전체 백업(레벨 0)** 이고, 그때의 상태를 기록한 스냅샷 파일 `/tmp/backup.snar` 가 있습니다. 그 뒤 `b.txt` 가 바뀌고 `new.txt` 가 추가됐습니다. **바뀐 것만 담는 증분 백업**을 같은 스냅샷 파일로 만들어 `/tmp/level1.tar.gz` 에 저장하세요. `a.txt` 같은 바뀌지 않은 파일은 들어가면 안 됩니다. (같은 스냅샷 파일로 명령을 다시 실행하면 빈 증분이 되므로 한 번만 실행하세요.)',
     '`tar` 에는 "이전 상태 기록 파일"을 지정해 그 이후 바뀐 것만 담게 하는 옵션이 있습니다. 전체 백업을 만들 때도 같은 옵션을 썼습니다.',
     "tar --listed-incremental=/tmp/backup.snar -czf /tmp/level1.tar.gz -C /tmp/src .\ntar tzf /tmp/level1.tar.gz\n\n# 증분은 용량과 시간을 크게 줄이지만 복원할 때 전체 + 증분을 순서대로 모두 풀어야 한다. 증분 하나가 없어지면 그 뒤가 모두 쓸모없어진다",
     S81_INC, [chk('b.txt 가 들어 있다', 'tar tzf /tmp/level1.tar.gz | grep -Eq "(^|/)b\\.txt$"'), chk('new.txt 가 들어 있다', 'tar tzf /tmp/level1.tar.gz | grep -Eq "(^|/)new\\.txt$"'), chk('바뀌지 않은 a.txt 는 없다', '! tar tzf /tmp/level1.tar.gz | grep -Eq "(^|/)a\\.txt$"')])
# 4
b.nt('전체 + 증분 복원', '`/tmp/level0.tar.gz`(전체)와 `/tmp/level1.tar.gz`(그 이후 증분)로 **`/tmp/restore`** 에 `/tmp/src` 의 최신 상태를 복원하세요. 복원 결과는 현재 `/tmp/src` 와 모든 파일이 같아야 합니다.',
     '복원 대상 디렉터리를 먼저 만드세요. 증분은 무엇을 기준으로 만들어졌는지 생각해 보세요.',
     "mkdir -p /tmp/restore\ntar -xzf /tmp/level0.tar.gz -C /tmp/restore\ntar -xzf /tmp/level1.tar.gz -C /tmp/restore\ndiff -r /tmp/restore /tmp/src && echo same\n\n# 삭제까지 반영하는 정석 복원은 --listed-incremental=/dev/null 을 함께 준다. 반대로 풀면 최신이 옛것으로 덮인다. 증분 체인은 정해진 순서로만 의미가 있고, 복원 훈련을 해 두지 않으면 장애 때 순서를 몰라 허둥댄다",
     S81_RESTORE, [chk('복원본이 현재 src 와 같다', 'diff -r /tmp/restore /tmp/src >/dev/null 2>&1')])
# 5
b.nt('파일 하나만 복원', '`/tmp/backup_full.tar.gz` 는 `/tmp/src` 의 전체 백업입니다. 사용자가 `docs/report.txt` 를 실수로 지웠다고 가정하고, **그 파일 하나만** 백업에서 꺼내 `/tmp/part` 아래에 복원하세요. 다른 파일은 풀리면 안 됩니다.',
     '`tar` 로 풀 때 꺼낼 파일 이름을 인자로 줄 수 있습니다. 먼저 목록에서 정확한 경로(앞의 `./` 여부)를 확인하세요.',
     "mkdir -p /tmp/part\ntar tzf /tmp/backup_full.tar.gz\ntar -xzf /tmp/backup_full.tar.gz -C /tmp/part ./docs/report.txt\nfind /tmp/part -type f\n\n# 목록의 경로와 정확히 일치해야 한다. 전체를 풀어서 덮어쓰면 그 사이 바뀐 다른 파일까지 옛날로 돌아가므로 필요한 것만 꺼낸다",
     S81_PART, [chk('report.txt 가 복원됐다', '[ "$(cat /tmp/part/docs/report.txt 2>/dev/null)" = "quarterly report" ]'), chk('다른 파일은 풀리지 않았다', '[ "$(find /tmp/part -type f | wc -l)" -eq 1 ]')])
# 6
b.nt('변조된 파일 찾기', '`/tmp/data.sha256` 은 `/tmp/data` 의 파일들을 백업하던 때 만든 체크섬 목록입니다. 그 뒤 파일 하나의 내용이 바뀌었습니다. 체크섬 검증으로 **내용이 달라진 파일의 이름**을 찾아 `/tmp/corrupt.txt` 에 저장하세요. (이름만)',
     '체크섬 도구에는 목록을 읽어 파일마다 맞는지 검사하는 모드가 있습니다. 실패한 줄만 골라내세요. 검사는 `/tmp/data` 안에서 해야 경로가 맞습니다.',
     "cd /tmp/data && sha256sum -c /tmp/data.sha256 2>&1 | grep -v ': OK$'\ncd /tmp/data && sha256sum -c /tmp/data.sha256 2>/dev/null | grep FAILED | cut -d: -f1 > /tmp/corrupt.txt\ncat /tmp/corrupt.txt\n\n# 디스크 오류나 의도치 않은 변경으로 데이터가 조용히 바뀌는 것을 발견하는 방법이다. 체크섬 목록은 원본과 다른 곳에 보관해야 믿을 수 있다",
     S81_SUM, [chk('c.txt 다', '[ "$(cat /tmp/corrupt.txt)" = c.txt ]')])
# 7
b.choice('RAID 는 백업이 아니다', 'RAID1 로 디스크를 미러링하고 있으니 백업은 필요 없다고 합니다. 한 사용자가 실수로 중요한 디렉터리를 `rm -rf` 로 지웠습니다. 이 상황에서 RAID1 은 어떻게 동작할까요?', '미러링이 복제하는 것이 무엇인지 생각해 보세요.',
         ['삭제도 양쪽에 즉시 반영되어 복구에 도움이 안 된다', '삭제를 감지해 한쪽 디스크에서 자동으로 복구해 준다', '삭제된 파일은 일주일간 휴지통에 보관된다', '두 번째 디스크는 삭제를 반영하지 않는다'], 0,
         'RAID 는 디스크 고장에 대비한 가용성 기술이지 데이터 보호(삭제·변조·랜섬웨어·재해) 대책이 아닙니다. 미러링은 모든 변경을 양쪽에 즉시 반영하므로 삭제도 그대로 복제됩니다. 별도 시점의 백업이 있어야 복구할 수 있습니다.')
# 8
b.choice('RPO 와 RTO', '"장애가 나면 최대 1시간 치 데이터까지만 잃어도 된다"는 목표를 무엇이라 부를까요?', '복구 시간이 아니라 시점과 관련된 목표입니다.',
         ['RPO (복구 목표 시점)', 'RTO (복구 목표 시간)', 'SLA (서비스 수준 협약)', 'RAID 레벨'], 0,
         'RPO(Recovery Point Objective)는 장애 때 허용하는 데이터 손실의 시간 범위라 백업 주기를 정합니다. RTO(Recovery Time Objective)는 서비스를 복구하는 데 허용되는 시간이라 복원 속도·절차를 정합니다. RPO 가 1시간이면 최소 1시간마다 백업·복제가 필요합니다.')
# 9
b.fill('증분 백업의 상태 기록 옵션', '이전 백업 시점의 상태를 스냅샷 파일에 기록해 두고 **그 이후 바뀐 것만 담는** GNU tar 의 옵션을 채우세요.', '`tar --help` 에서 "incremental" 이 들어간 옵션을 찾아 보세요.',
       'tar --{0}=/tmp/backup.snar -czf /tmp/level1.tar.gz -C /tmp/src .', ['listed-incremental', 'strip-components', 'exclude', 'preserve-permissions'], [0],
       '`--listed-incremental=파일` 은 스냅샷 파일에 파일들의 상태를 기록해 다음 실행에서 바뀐 것만 담게 합니다. `--strip-components` 는 풀 때 경로 앞부분 제거, `--exclude` 는 제외할 패턴, `--preserve-permissions` 는 권한 보존 옵션입니다.')
# 10
b.order('증분 백업 복원 순서', '월요일 전체 백업, 화요일·수요일 증분 백업이 있고 목요일에 장애가 나서 복원해야 합니다. 복원 결과를 믿을 수 있도록 올바른 순서로 놓으세요.', '증분은 앞선 백업을 기준으로 하므로 순서가 중요합니다.',
        ['월요일 전체 백업을 풀고 그 뒤 증분 백업을 날짜 순서대로 차례로 푼다', '복원 결과를 원본 체크섬이나 백업 시점 목록과 대조한다', '비어 있는 새 디렉터리를 복원 위치로 정한다'], [2, 0, 1],
        '복원은 기존 데이터와 섞이지 않게 빈 위치에서 시작하고, 전체 백업을 먼저 푼 뒤 증분을 시간 순서대로 덮어 풀며, 마지막에 체크섬 등으로 결과가 정확한지 확인합니다.')

if __name__ == '__main__':
    preview(b)
