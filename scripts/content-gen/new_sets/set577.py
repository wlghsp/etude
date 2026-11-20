import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 577: 디스크가 가득 찼을 때 진단. 명세: docs/specs/spec_gap_set577.md
# 샌드박스 linux(비특권, 마운트 불가). 큰 디렉터리·삭제됐지만 열린 파일은 실제 프로세스로 재현하고, inode·예약 블록은 이미지 파일(ext4)에 dumpe2fs·tune2fs 로 확인한다.

S77 = """pkill -x sleep 2>/dev/null; sleep 0.3
rm -rf /tmp/lab /tmp/small.img /tmp/.hp /tmp/cmds; rm -f /tmp/*.txt
mkdir -p /tmp/lab/logs /tmp/lab/cache /tmp/lab/data
dd if=/dev/zero of=/tmp/lab/logs/app.log bs=1M count=20 2>/dev/null
dd if=/dev/zero of=/tmp/lab/logs/old.log bs=1M count=6 2>/dev/null
i=0; while [ $i -lt 8 ]; do dd if=/dev/zero of=/tmp/lab/cache/c$i bs=1M count=1 2>/dev/null; i=$((i+1)); done
dd if=/dev/zero of=/tmp/lab/data/db.dat bs=1M count=4 2>/dev/null
truncate -s 8M /tmp/small.img
mke2fs -q -F -t ext4 -N 64 -b 1024 /tmp/small.img
i=0; while [ $i -lt 50 ]; do echo "write /dev/null f$i" >> /tmp/cmds; i=$((i+1)); done
debugfs -w -f /tmp/cmds /tmp/small.img >/dev/null 2>&1
dd if=/dev/zero of=/tmp/lab/held.log bs=1M count=12 2>/dev/null
nohup sh -c 'exec 5</tmp/lab/held.log; rm -f /tmp/lab/held.log; exec sleep 600' >/dev/null 2>&1 &
echo $! > /tmp/.hp
sleep 0.5
true"""

b = SetBuilder(577, '디스크가 가득 찼을 때: 큰 디렉터리, inode 고갈, 지워도 안 줄어드는 공간, 예약 블록',
               '"No space left on device" 신고가 왔을 때 원인을 좁히는 실습입니다. du 로 큰 디렉터리를 찾고, 용량은 남았는데 파일을 못 만드는 inode 고갈을 파일시스템 정보에서 읽고, 파일을 지웠는데 공간이 안 돌아오는 이유(삭제됐지만 프로세스가 열고 있는 파일)를 직접 찾아 비웁니다. 마운트 권한이 없어 inode·예약 블록은 ext4 이미지 파일의 정보를 읽는 방식입니다.',
               'linux', '스토리지', 70, 837, '💽',
               [{"title": "df 매뉴얼", "url": "https://man7.org/linux/man-pages/man1/df.1.html"}, {"title": "dumpe2fs 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/dumpe2fs.8.html"}, {"title": "tune2fs 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/tune2fs.8.html"}], 5)

# 1
b.nt('어디가 가장 큰가', '`/tmp/lab` 아래에 용량을 가장 많이 쓰는 **하위 디렉터리 이름**(경로 말고 이름만)을 찾아 `/tmp/biggest.txt` 에 저장하세요. 디렉터리별 사용량은 `du` 로 봅니다.',
     '`du` 로 하위 디렉터리별 합계를 구한 뒤 크기 순으로 정렬해 끝을 보세요. 단위를 통일하려면 KB 단위 옵션이 편합니다.',
     "du -sk /tmp/lab/* | sort -n\nbasename \"$(du -sk /tmp/lab/*/ | sort -n | tail -1 | awk '{print $2}')\" > /tmp/biggest.txt\ncat /tmp/biggest.txt\n\n# logs(약 26MB)가 가장 크다. df 로 가득 찬 파일시스템을 찾고, du 로 큰 디렉터리를 따라 내려가는 것이 첫 순서다",
     S77, [chk('logs 다', '[ "$(cat /tmp/biggest.txt)" = logs ]')])
# 2
b.nt('inode 가 얼마나 남았나', '`/tmp/small.img` 는 작은 ext4 파일시스템 이미지입니다. 파일마다 inode 가 하나씩 필요한데, 이 이미지는 inode 를 일부러 적게 만들었습니다. 파일시스템 정보에서 **남은 inode 수(`Free inodes`)** 를 읽어 숫자만 `/tmp/free_inodes.txt` 에 저장하세요.',
     'ext2/3/4 파일시스템 정보를 보여 주는 도구가 있습니다. 헤더만 보는 옵션을 쓰면 출력이 짧아집니다.',
     "dumpe2fs -h /tmp/small.img 2>/dev/null | grep -E 'Inode count|Free inodes|Free blocks'\ndumpe2fs -h /tmp/small.img 2>/dev/null | awk '/^Free inodes/{print $3}' > /tmp/free_inodes.txt\ncat /tmp/free_inodes.txt\n\n# inode 는 파일·디렉터리 하나당 하나다. 파일 수가 많은 작은 파일시스템에서는 블록이 남아도 inode 가 먼저 바닥난다. 일반 파일시스템에서는 df -i 로 본다",
     S77, [chk('남은 inode 수와 같다', '[ "$(cat /tmp/free_inodes.txt)" = "$(dumpe2fs -h /tmp/small.img 2>/dev/null | awk \'/^Free inodes/{print $3}\')" ]'), chk('값이 비어 있지 않다', '[ -n "$(cat /tmp/free_inodes.txt)" ]')])
# 3
b.nt('inode 와 블록 중 무엇이 부족한가', '같은 `/tmp/small.img` 에 새 파일을 계속 만들면 곧 "No space left on device" 가 날 상황입니다. 이 파일시스템에서 **먼저 바닥난 것**이 `inode` 인지 `block`(데이터 공간)인지 **단어 하나**로 `/tmp/shortage.txt` 에 저장하세요.',
     '`Inode count`·`Free inodes` 와 `Block count`·`Free blocks` 를 각각 비교해 어느 쪽이 거의 소진됐는지 보세요.',
     "dumpe2fs -h /tmp/small.img 2>/dev/null | grep -E '^(Inode count|Free inodes|Block count|Free blocks)'\necho inode > /tmp/shortage.txt\ncat /tmp/shortage.txt\n\n# 남은 inode 가 3 개뿐인데 블록은 86% 가량 남아 있다. df 는 여유가 있는데 파일을 못 만들면 df -i 를 먼저 본다. 작은 파일이 수만 개 쌓이는 캐시·세션 디렉터리가 흔한 원인이다",
     S77, [chk('inode 다', '[ "$(cat /tmp/shortage.txt)" = inode ]')])
# 4
b.nt('지웠는데 공간이 안 돌아오는 파일', '`/tmp/lab/held.log`(12MB)는 어떤 프로세스가 열어 둔 채로 **삭제**되었습니다. 이런 파일은 이름이 사라졌어도 프로세스가 닫기 전까지 공간을 차지합니다. 이 파일을 **열고 있는 프로세스의 PID** 를 찾아 숫자만 `/tmp/holder_pid.txt` 에 저장하세요.',
     '프로세스가 열어 둔 파일은 `/proc/<PID>/fd/` 아래 링크로 보입니다. 링크 끝에 삭제 표시가 붙은 것을 찾아 보세요. (`lsof` 는 이 이미지에 없습니다)',
     "ls -l /proc/[0-9]*/fd/* 2>/dev/null | grep deleted\nls -l /proc/[0-9]*/fd/* 2>/dev/null | grep 'held.log (deleted)' | head -1 | awk '{print $9}' | cut -d/ -f3 > /tmp/holder_pid.txt\ncat /tmp/holder_pid.txt\n\n# 같은 정보를 lsof +L1 로도 볼 수 있다(링크 수가 0 인 열린 파일). 해결은 프로세스를 재시작하거나 파일을 비우는(truncate) 것이다",
     S77, [chk('PID 가 맞다', '[ "$(cat /tmp/holder_pid.txt)" = "$(cat /tmp/.hp)" ]')])
# 5
b.nt('프로세스를 죽이지 않고 공간 되찾기', '`held.log` 를 열고 있는 프로세스는 계속 실행되어야 합니다. 프로세스를 끝내지 않고 **그 삭제된 파일의 내용만 비워** 공간을 돌려받으세요. 열린 파일은 `/proc/<PID>/fd/5` 로 접근할 수 있습니다.',
     '`/proc/<PID>/fd/번호` 를 일반 파일처럼 열어 크기를 0 으로 만들 수 있습니다. PID 는 앞 문제에서 찾은 값입니다.',
     "P=$(cat /tmp/.hp)\nls -l /proc/$P/fd/5\n: > /proc/$P/fd/5\nstat -L -c %s /proc/$P/fd/5\n\n# 재시작이 어려운 서비스(로그를 계속 쓰는 데몬)에서 쓰는 응급 방법이다. 근본 해결은 로그 로테이션(logrotate)이 서비스에 파일을 다시 열라고 알리게 하는 것이다",
     S77, [chk('프로세스가 살아 있다', 'kill -0 "$(cat /tmp/.hp)" 2>/dev/null'), chk('삭제된 파일의 크기가 0 이다', '[ "$(stat -L -c %s /proc/$(cat /tmp/.hp)/fd/5 2>/dev/null)" = 0 ]')])
# 6
b.nt('예약 블록 줄이기', '`/tmp/small.img` 에는 일반 사용자가 쓸 수 없고 root 용으로 남겨 두는 **예약 블록**이 기본 5% 있습니다. 데이터 전용 파일시스템에서는 이만큼이 낭비일 수 있습니다. 예약 비율을 **1%** 로 낮추세요.',
     'ext 계열 파일시스템 설정을 바꾸는 도구의 옵션 설명에서 예약 블록 비율을 정하는 옵션을 찾으세요.',
     "dumpe2fs -h /tmp/small.img 2>/dev/null | grep -E 'Block count|Reserved block count'\ntune2fs -m 1 /tmp/small.img\ndumpe2fs -h /tmp/small.img 2>/dev/null | grep -E 'Block count|Reserved block count'\n\n# 예약 블록은 가득 찬 상태에서도 root 가 시스템을 복구할 수 있게 하는 안전장치다. 루트(/)나 /var 는 줄이지 말고 대용량 데이터 볼륨에서만 조정한다",
     S77, [chk('예약 블록이 1% 근처다', 'B=$(dumpe2fs -h /tmp/small.img 2>/dev/null | awk \'/^Block count/{print $3}\'); R=$(dumpe2fs -h /tmp/small.img 2>/dev/null | awk \'/^Reserved block count/{print $4}\'); [ "$R" -le $((B * 15 / 1000)) ] && [ "$R" -ge 1 ]')])
# 7
b.choice('df 와 du 가 다르다', '`df` 는 파일시스템이 90% 찼다고 하는데, 마운트 지점에서 `du -s` 로 합친 파일 크기는 훨씬 작습니다. 이 차이를 만드는 원인으로 가장 알맞은 것은?', '마운트 지점 아래에서 보이지 않는 사용량이 무엇일지 생각해 보세요.',
         ['삭제됐지만 프로세스가 열고 있는 파일이 공간을 차지한다', 'du 는 압축된 크기로 계산하기 때문이다', 'df 는 메모리 사용량을 포함해 계산하기 때문이다', 'du 는 숨김 파일만 센다'], 0,
         'du 는 디렉터리에서 보이는 파일의 크기를 더하고, df 는 파일시스템이 실제로 할당한 공간을 봅니다. 이름이 지워졌지만 열려 있는 파일, 마운트 지점 아래 가려진 파일, 파일시스템 메타데이터·저널 같은 것이 그 차이를 만듭니다.')
# 8
b.choice('여유가 있는데 No space left', '`df -h` 로는 용량이 40% 남았는데 새 파일을 만들면 `No space left on device` 가 납니다. 가장 먼저 확인할 것으로 알맞은 것은?', '용량(블록) 외에 파일을 만들 때 필요한 것이 무엇인지 생각해 보세요.',
         ['inode 여유를 확인한다', '메모리 여유를 확인한다', 'CPU 사용률을 확인한다', '네트워크 연결 상태를 확인한다'], 0,
         '파일마다 inode 가 필요해 블록이 남아도 inode 가 바닥나면 파일을 만들 수 없습니다. 이럴 때 오류 메시지는 같아 df -i 로 inode 사용률을 확인해야 합니다. 작은 파일이 많이 쌓인 디렉터리를 찾아 정리합니다.')
# 9
b.fill('inode 사용량을 보는 df 옵션', '파일시스템별 **inode 사용량**을 보려면 `df` 에 어떤 옵션을 줘야 할까요? 빈칸을 채우세요.', '`df --help` 에서 사용량 대신 inode 정보를 보여 주는 옵션을 찾아 보세요.',
       'df -{0} /var', ['i', 'h', 'T', 'a'], [0],
       '`-i` 는 inode 의 총수·사용·남은 수를 보여 줍니다. `-h` 는 읽기 쉬운 단위, `-T` 는 파일시스템 종류, `-a` 는 모든 파일시스템을 보여 주는 옵션입니다.')
# 10
b.order('디스크 가득 참 대응 순서', '서버의 디스크가 가득 찼다는 경보가 왔습니다. 확인하고 정리한 뒤, 공간이 돌아왔는지 따져 보며 원인을 좁히려 합니다. 올바른 순서로 놓으세요.', '각 단계는 앞 단계에서 얻은 결과가 있어야 할 수 있습니다. 정리한 효과가 있었는지는 맨 끝에 가서야 알 수 있습니다.',
        ['큰 파일을 지운다', '지운 뒤에도 `df` 가 줄지 않으면 삭제됐지만 열려 있는 파일을 확인한다', '`du` 로 큰 디렉터리를 따라 내려가며 큰 파일을 찾는다', '`df -h` 로 어느 파일시스템이 가득 찼는지 확인한다'], [3, 2, 0, 1],
        '가득 찬 파일시스템을 확인하고, 그 안에서 큰 디렉터리·파일을 찾아 정리합니다. 지운 뒤에도 사용량이 줄지 않으면 프로세스가 열고 있는 삭제된 파일을 확인해 프로세스를 재시작하거나 비웁니다.')

if __name__ == '__main__':
    preview(b)
