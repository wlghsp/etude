-- 세트 27: 리눅스 성능과 스토리지(NFS) 점검 (order 1~14)
-- 메모리·CPU·로드 점검과 df 계열 출력 읽기, NFS 설정(fstab, exports)과 출력 해석. 컨테이너에서는 실제 NFS 마운트를 할 수 없어 설정 파일 작성과 샘플 출력 읽기로 다룬다.
INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd) VALUES
  (27,  1, '메모리를 가장 많이 쓰는 프로세스 찾기',
   '서버의 메모리가 계속 부족해집니다. 원인은 보통 메모리를 크게 점유한 프로세스 하나입니다. 메모리는 `RSS`(실제로 물리 메모리에 올라가 있는 크기) 열로 비교합니다.

지금 메모리를 **가장 많이 쓰는 프로세스의 PID** 를 `/tmp/mem_pid.txt` 에 저장하세요.',
   '`ps -eo pid,rss,args --sort=-rss` 는 `RSS` 가 큰 순서로 프로세스를 보여 줍니다.
- `-e` : 모든 프로세스, `-o pid,rss,args` : 보여 줄 열 지정
- `--sort=-rss` : RSS 내림차순 (`-` 가 내림차순)
1번째 줄은 제목이고 2번째 줄이 1등이라, `sed -n 2p` 와 `awk ''{print $1}''` 로 PID(첫 칸)만 뽑을 수 있습니다.',
   'ps -eo pid,rss --sort=-rss | sed -n 2p | awk ''{print $1}'' > /tmp/mem_pid.txt

# --sort=-rss : 실제 메모리 사용량(RSS) 내림차순
# sed -n 2p : 2번째 줄(1등)만, awk ''{print $1}'' : 첫 칸(PID)만',
   '["sh", "-c", "nohup perl -e ''$x = \\\"a\\\" x (80*1024*1024); sleep 3600'' memhog >/dev/null 2>&1 & sleep 2"]',
   '["sh", "-c", "[ -n \\\"$(cat /tmp/mem_pid.txt)\\\" ] && [ \\\"$(tr -d ''[:space:]'' < /tmp/mem_pid.txt)\\\" = \\\"$(pgrep -x perl | head -n 1)\\\" ]"]'),

  (27,  2, 'free 출력에서 실제 쓸 수 있는 메모리(available) 읽기',
   '`free` 에는 `free`, `buff/cache`, `available` 열이 있습니다. 리눅스는 남는 메모리를 디스크 캐시로 쓰기 때문에 `free` 가 작아 보여도 문제가 아닌 경우가 많고, **실제로 새 프로그램이 쓸 수 있는 양은 `available`** 입니다. 메모리가 부족한지는 이 열로 판단합니다.

`free -m`(MB 단위)의 Mem 줄에서 **`available` 값(숫자만)** 을 뽑아 `/tmp/avail.txt` 에 저장하세요. (값은 실시간이라 약간의 차이는 허용됩니다)',
   '`free -m` 출력의 `Mem:` 줄은 `total used free shared buff/cache available` 순서의 열입니다. `available` 은 **7번째 칸**입니다.
`awk ''/^Mem:/ {print $7}''` 로 `Mem:` 으로 시작하는 줄의 7번째 칸을 뽑으세요. (`-m` 은 MB 단위, `-h` 는 읽기 쉬운 단위)',
   'free -m | awk ''/^Mem:/ {print $7}'' > /tmp/avail.txt

# free -m : MB 단위로 출력
# /^Mem:/ : Mem: 으로 시작하는 줄, $7 : available 열',
   NULL,
   '["sh", "-c", "a=$(tr -d ''[:space:]'' < /tmp/avail.txt); b=$(free -m | awk ''/^Mem:/ {print $7}''); [ -n \\\"$a\\\" ] && d=$((a-b)) && [ ${d#-} -le 100 ]"]'),

  (27,  3, '총 메모리 용량을 /proc/meminfo 에서 읽기',
   '`/proc` 는 커널이 현재 상태를 파일처럼 보여 주는 곳입니다. `free` 같은 명령도 결국 `/proc/meminfo` 를 읽습니다. 도구가 없거나 스크립트에서 값을 직접 뽑을 때 알아 두면 유용합니다.

`/proc/meminfo` 의 `MemTotal`(전체 메모리, 단위 kB)을 **MB 단위 정수**로 바꿔서 `/tmp/mem_total.txt` 에 저장하세요. (소수점 아래는 버립니다)',
   '`grep MemTotal /proc/meminfo` 로 줄을 확인하면 `MemTotal: 16000000 kB` 처럼 나옵니다. 숫자는 2번째 칸입니다. kB 를 MB 로 바꾸려면 1024 로 나눕니다.
`awk ''/MemTotal/ {printf "%d", $2/1024}''` 에서 `%d` 는 정수로 출력(소수점 버림)입니다.',
   'awk ''/MemTotal/ {printf "%d", $2/1024}'' /proc/meminfo > /tmp/mem_total.txt

# $2 : 2번째 칸(kB 숫자), /1024 : MB 로 변환
# printf "%d" : 정수로 출력',
   NULL,
   '["sh", "-c", "a=$(tr -d ''[:space:]'' < /tmp/mem_total.txt); b=$(awk ''/MemTotal/ {printf \\\"%d\\\", $2/1024}'' /proc/meminfo); [ -n \\\"$a\\\" ] && d=$((a-b)) && [ ${d#-} -le 1 ]"]'),

  (27,  4, 'CPU 코어 수 확인하기',
   '서버가 느릴 때는 **CPU 코어 수**와 부하를 함께 봅니다. 같은 부하라도 2코어 서버와 32코어 서버의 의미가 다릅니다. (로드 평균 해석에 꼭 필요한 값입니다)

이 서버의 CPU 코어(처리 단위) 개수를 숫자만 `/tmp/cores.txt` 에 저장하세요.',
   '`nproc` 은 사용 가능한 CPU 처리 단위 수를 출력합니다. `lscpu` 는 CPU 정보를 자세히 보여 줍니다. 결과를 `>` 로 저장하세요.',
   'nproc > /tmp/cores.txt

# nproc : 사용 가능한 CPU 처리 단위 수',
   NULL,
   '["sh", "-c", "[ -s /tmp/cores.txt ] && [ \\\"$(tr -d ''[:space:]'' < /tmp/cores.txt)\\\" = \\\"$(nproc)\\\" ]"]'),

  (27,  5, 'top 을 한 번만 실행해 결과 저장하기',
   '`top` 은 CPU·메모리·로드를 실시간으로 보는 대표 도구인데, 화면이 계속 갱신되는 대화형 프로그램이라 **스크립트나 기록에는 그대로 쓸 수 없습니다.** 배치 모드로 한 번만 출력하면 문서화와 자동 수집에 쓸 수 있습니다.

`top` 을 **한 번만** 실행한 결과를 `/tmp/top.txt` 에 저장하세요.',
   '`top -b -n 1` 에서 `-b` 는 배치 모드(화면 제어 없이 텍스트만 출력), `-n 1` 은 1번만 갱신하고 종료입니다. 결과를 `>` 로 저장하세요. 저장한 파일에서 `Tasks:`(프로세스 수), `load average`, `%Cpu(s)`, `MiB Mem` 줄을 찾아 읽어 보세요.',
   'top -b -n 1 > /tmp/top.txt

# -b : 배치 모드(화면 없이 텍스트), -n 1 : 한 번만 출력',
   NULL,
   '["sh", "-c", "grep -q ''load average'' /tmp/top.txt && grep -q ''Tasks:'' /tmp/top.txt"]'),

  (27,  6, 'uptime 출력에서 15분 로드 평균 읽기',
   '**로드 평균**은 "실행되거나 실행을 기다리는 프로세스의 평균 개수"로, 서버가 얼마나 바쁜지를 보여 줍니다. `uptime` 은 1분, 5분, 15분 평균을 차례로 보여 주고, 숫자가 **CPU 코어 수보다 계속 크면 과부하**입니다. 1분 값이 15분 값보다 크면 부하가 늘고 있다는 뜻입니다.

`/tmp/uptime.txt` 에 `uptime` 출력이 저장되어 있습니다. 이 줄에서 **15분 로드 평균 값**(마지막 숫자)만 `/tmp/load15.txt` 에 저장하세요.
 10:20:01 up 12 days,  3:05,  2 users,  load average: 8.20, 6.10, 3.05',
   '`load average:` 뒤에 쉼표로 구분된 세 숫자가 1분, 5분, 15분 평균입니다. `awk -F''load average: '' ''{print $2}''` 로 그 뒤 부분만 잘라내고, `cut -d, -f3` 로 쉼표 기준 3번째 값을 뽑은 뒤 `tr -d '' ''` 로 공백을 지웁니다.
- `-F''구분자''` : awk 가 줄을 나눌 기준 문자열
- `cut -d, -f3` : 구분자 `,` 로 나눠 3번째 칸',
   'awk -F''load average: '' ''{print $2}'' /tmp/uptime.txt | cut -d, -f3 | tr -d '' '' > /tmp/load15.txt

# -F''load average: '' : 이 문자열 기준으로 나눔 → $2 = ''8.20, 6.10, 3.05''
# cut -d, -f3 : 쉼표로 나눈 3번째 값(15분), tr -d '' '' : 공백 제거',
   '["sh", "-c", "{ echo '' 10:20:01 up 12 days,  3:05,  2 users,  load average: 8.20, 6.10, 3.05''; } > /tmp/uptime.txt"]',
   '["sh", "-c", "[ \\\"$(tr -d ''[:space:]'' < /tmp/load15.txt)\\\" = 3.05 ]"]'),

  (27,  7, 'vmstat 으로 시스템 상태를 몇 번 측정해 저장하기',
   '`vmstat` 은 프로세스 대기, 메모리, 스왑, 디스크 I/O, CPU 사용을 한 줄에 보여 줍니다. 일정 간격으로 여러 번 측정하면 **변화 추이**를 볼 수 있어 성능 장애 분석의 기본 도구입니다.

`vmstat` 을 1초 간격으로 3번 측정한 결과를 `/tmp/vmstat.txt` 에 저장하세요.',
   '`vmstat <간격(초)> <횟수>` 형식입니다. `vmstat 1 3` 은 1초마다 3번 출력합니다(제목 2줄 + 측정 3줄). 결과를 `>` 로 저장하세요. 열의 의미: `r` 실행 대기 프로세스, `swpd` 스왑 사용, `si/so` 스왑 입출력, `us/sy/id` 사용자/시스템/유휴 CPU 비율입니다.',
   'vmstat 1 3 > /tmp/vmstat.txt

# 1 : 1초 간격, 3 : 3번 측정',
   NULL,
   '["sh", "-c", "[ \\\"$(wc -l < /tmp/vmstat.txt)\\\" -eq 5 ] && grep -q swpd /tmp/vmstat.txt"]'),

  (27,  8, 'df -h 출력에서 사용률이 높은 마운트 지점 찾기',
   '디스크가 가득 차면 서비스가 멈춥니다. `df -h` 출력에서 **`Use%`(사용률)가 높은 곳**을 빨리 찾아내는 것이 점검의 기본입니다. 보통 80% 이상이면 정리나 증설을 검토합니다.

`/tmp/df.txt` 에 서버의 `df -h` 출력이 저장되어 있습니다. 사용률(`Use%`)이 **80% 이상**인 마운트 지점(`Mounted on` 열)만 정렬해서 한 줄씩 `/tmp/full.txt` 에 저장하세요.',
   '`awk ''NR>1 && $5+0>=80 {print $6}'' /tmp/df.txt | sort` 형태입니다.
- `NR>1` : 1번째 줄(제목) 제외
- `$5+0` : 5번째 칸 `90%` 에 0 을 더해 숫자 90 으로 변환
- `$6` : 6번째 칸(마운트 지점)
- `sort` : 정렬',
   'awk ''NR>1 && $5+0>=80 {print $6}'' /tmp/df.txt | sort > /tmp/full.txt

# NR>1 : 제목 줄 제외, $5+0 : ''90%'' → 숫자 90, $6 : Mounted on 열',
   '["sh", "-c", "{ echo ''Filesystem            Size  Used Avail Use% Mounted on''; echo ''/dev/sda1              50G   45G  5.0G  90% /''; echo ''tmpfs                 2.0G     0  2.0G   0% /dev/shm''; echo ''/dev/sdb1             200G   60G  140G  30% /data''; echo ''10.0.0.5:/export/data 500G  450G   50G  90% /mnt/nfs''; echo ''/dev/sdc1             100G   82G   18G  82% /var/log''; } > /tmp/df.txt"]',
   '["sh", "-c", "[ \\\"$(sort /tmp/full.txt | paste -sd, -)\\\" = \\\"/,/mnt/nfs,/var/log\\\" ]"]'),

  (27,  9, 'df -i 출력에서 inode 가 가득 찬 곳 찾기',
   '디스크 용량이 남았는데도 "No space left on device" 오류가 나면 **inode(파일 개수 한도)** 가 찬 것일 수 있습니다. 작은 파일이 수없이 쌓이는 로그·캐시 디렉토리에서 흔히 생깁니다. `df -i` 로 확인합니다.

`/tmp/dfi.txt` 에 `df -i` 출력이 저장되어 있습니다. inode 사용률(`IUse%`)이 **100%** 인 마운트 지점을 `/tmp/inode_full.txt` 에 저장하세요.',
   '`df -i` 의 5번째 칸이 `IUse%`, 6번째 칸이 마운트 지점입니다. `awk ''NR>1 && $5=="100%" {print $6}''` 처럼 5번째 칸이 `100%` 인 줄의 6번째 칸을 출력하세요. (`==` 는 문자열 비교)',
   'awk ''NR>1 && $5=="100%" {print $6}'' /tmp/dfi.txt > /tmp/inode_full.txt

# df -i : inode 사용량 (df -h 는 용량)
# $5=="100%" : IUse% 가 100% 인 줄',
   '["sh", "-c", "{ echo ''Filesystem      Inodes   IUsed   IFree IUse% Mounted on''; echo ''/dev/sda1      3276800  210000 3066800    7% /''; echo ''/dev/sdb1       655360  655360       0  100% /data''; echo ''tmpfs           500000       5  499995    1% /dev/shm''; echo ''/dev/sdc1       655360  300000  355360   46% /var/log''; } > /tmp/dfi.txt"]',
   '["sh", "-c", "[ \\\"$(tr -d ''[:space:]'' < /tmp/inode_full.txt)\\\" = /data ]"]'),

  (27, 10, 'df -hT 출력에서 NFS 마운트만 골라내기',
   'NFS 는 다른 서버의 디렉토리를 내 서버에 붙여 쓰는 네트워크 파일시스템이라, 공유 저장소가 있는 환경에서는 피할 수 없습니다. `df -hT` 의 **`Type` 열**로 로컬 디스크(`ext4`, `xfs`)와 NFS(`nfs`, `nfs4`)를 구분하고, NFS 는 `서버:/경로` 형태로 표시됩니다.

`/tmp/dft.txt` 에 `df -hT` 출력이 저장되어 있습니다. 파일시스템 유형이 **NFS 계열(`nfs`, `nfs4`)** 인 마운트 지점을 정렬해서 `/tmp/nfs_mounts.txt` 에 저장하세요.',
   '`df -hT` 는 `df -h` 에 `Type` 열이 추가된 것이라 마운트 지점이 **7번째 칸**입니다. `awk ''NR>1 && $2 ~ /^nfs/ {print $7}''` 에서 `$2 ~ /^nfs/` 는 ''2번째 칸이 nfs 로 시작''이라는 조건입니다. 결과는 `sort` 로 정렬하세요.',
   'awk ''NR>1 && $2 ~ /^nfs/ {print $7}'' /tmp/dft.txt | sort > /tmp/nfs_mounts.txt

# -T : 파일시스템 유형(Type) 열 추가
# $2 ~ /^nfs/ : 유형이 nfs 로 시작 (nfs, nfs4 모두)',
   '["sh", "-c", "{ echo ''Filesystem            Type   Size  Used Avail Use% Mounted on''; echo ''/dev/sda1             ext4    50G   20G   28G  42% /''; echo ''10.0.0.5:/export/data nfs4   500G  450G   50G  90% /mnt/nfs-data''; echo ''10.0.0.6:/backup      nfs    1.0T  300G  700G  30% /mnt/backup''; echo ''tmpfs                 tmpfs  2.0G     0  2.0G   0% /dev/shm''; echo ''/dev/sdb1             xfs    200G   60G  140G  30% /data''; } > /tmp/dft.txt"]',
   '["sh", "-c", "[ \\\"$(sort /tmp/nfs_mounts.txt | paste -sd, -)\\\" = \\\"/mnt/backup,/mnt/nfs-data\\\" ]"]'),

  (27, 11, 'NFS 마운트가 hard 인지 soft 인지 확인하기',
   'NFS 마운트 옵션 중 `hard` 와 `soft` 는 **NFS 서버가 응답하지 않을 때**의 동작을 가릅니다. `hard` 는 서버가 돌아올 때까지 계속 기다려서 그 경로를 쓰는 프로세스와 `df`, `ls` 가 멈춰 버릴 수 있고, `soft` 는 일정 시간 뒤 에러를 돌려줍니다. 서버 장애 때 "`df` 가 안 끝나요"의 흔한 원인입니다.

`/tmp/mounts.txt` 에 `/proc/mounts` 내용이 저장되어 있습니다. NFS 마운트 줄에서 **`hard` 인지 `soft` 인지** 단어 하나를 `/tmp/nfs_mode.txt` 에 저장하세요.',
   '`/proc/mounts` 는 현재 마운트와 옵션을 보여 주는 파일이고 NFS 줄은 `nfs`/`nfs4` 를 포함합니다. `grep nfs <파일>` 로 줄을 고르고, `grep -o -E ''hard|soft''` 로 두 단어 중 하나만 뽑습니다.
- `-o` : 일치한 부분만 출력
- `-E` : 확장 정규식(`|` 는 ''또는'')',
   'grep nfs /tmp/mounts.txt | grep -o -E ''hard|soft'' > /tmp/nfs_mode.txt

# 옵션 해석: vers=4.2 NFS 버전, hard 서버 응답 없으면 계속 대기, proto=tcp 전송 방식',
   '["sh", "-c", "{ echo ''/dev/sda1 / ext4 rw,relatime 0 0''; echo ''tmpfs /dev/shm tmpfs rw,nosuid,nodev 0 0''; echo ''10.0.0.5:/export/data /mnt/data nfs4 rw,relatime,vers=4.2,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=10.0.1.20,local_lock=none,addr=10.0.0.5 0 0''; } > /tmp/mounts.txt"]',
   '["sh", "-c", "[ \\\"$(tr -d ''[:space:]'' < /tmp/nfs_mode.txt)\\\" = hard ]"]'),

  (27, 12, '/etc/fstab 에 NFS 마운트 등록하기',
   '서버를 재부팅해도 NFS 가 자동으로 붙게 하려면 `/etc/fstab` 에 등록합니다. 한 줄이 6개의 열(`장치 마운트지점 유형 옵션 dump fsck`)입니다. NFS 는 **네트워크가 올라온 뒤에** 마운트해야 해서 `_netdev` 옵션을 씁니다. (이 터미널에서는 마운트 권한이 없어 실제로 붙이지는 않고, 설정 파일만 작성합니다)

`/etc/fstab` 에 아래 NFS 마운트를 **추가**하세요. 기존 줄은 지우면 안 됩니다.
- NFS 서버 `10.0.0.5` 의 `/export/data`
- 내 서버의 `/mnt/data` 에 마운트
- 파일시스템 유형 `nfs4`, 옵션에 `_netdev` 포함',
   '형식: `<서버:/경로> <마운트지점> <유형> <옵션> 0 0`
- 옵션 `defaults` : 기본값(rw, suid, exec 등), `_netdev` : 네트워크 준비 후 마운트(부팅 순서 문제 방지)
- 마지막 `0 0` : dump 백업 여부, 부팅 시 fsck 검사 순서(NFS 는 보통 0 0)
기존 내용을 지우지 않게 덮어쓰기 `>` 가 아니라 **이어쓰기 `>>`** 를 쓰세요.',
   'echo ''10.0.0.5:/export/data /mnt/data nfs4 defaults,_netdev 0 0'' >> /etc/fstab

# 서버:/경로  마운트지점  유형  옵션  dump  fsck
# _netdev : 네트워크가 올라온 뒤에 마운트 (없으면 부팅 때 마운트 실패/지연 가능)
# >> : 기존 줄을 지우지 않고 이어쓰기
# 실제 마운트(수동): mount -a  (이 환경에서는 권한이 없음)',
   '["sh", "-c", "{ echo ''# /etc/fstab''; echo ''UUID=1111-2222 / ext4 defaults 0 1''; } > /etc/fstab"]',
   '["sh", "-c", "grep -Eq ''^10[.]0[.]0[.]5:/export/data[[:space:]]+/mnt/data[[:space:]]+nfs4?[[:space:]]+[^[:space:]]*_netdev'' /etc/fstab && grep -q ''UUID=1111-2222'' /etc/fstab"]'),

  (27, 13, '/etc/exports 로 NFS 공유 설정하기',
   'NFS **서버** 쪽에서는 `/etc/exports` 에 "어느 디렉토리를, 누구에게, 어떤 권한으로" 공유할지 적습니다. 잘못 열면 보안 문제가 되므로 대역과 옵션을 정확히 지정해야 합니다. (이 환경에는 NFS 서버가 없어 설정 파일만 작성합니다)

`/etc/exports` 에 아래 공유를 **한 줄**로 추가하세요.
- 공유 디렉토리: `/export/data`
- 접근 허용 대역: `10.0.0.0/24`
- 옵션: 읽기/쓰기(`rw`), 동기 쓰기(`sync`), `no_root_squash`',
   '형식: `<디렉토리> <대상>(<옵션,옵션>)` 한 줄입니다. 옵션은 쉼표로 이어 쓰고 대상과 괄호 사이에는 **공백이 없어야** 합니다.
- `rw` : 읽기/쓰기 (`ro` 는 읽기 전용)
- `sync` : 쓰기가 디스크에 반영된 뒤 응답 (안전, `async` 는 빠르지만 장애 시 데이터 유실 위험)
- `no_root_squash` : 클라이언트의 root 를 서버에서도 root 로 취급 (기본 `root_squash` 는 nobody 로 낮춤 — 보안상 꼭 필요할 때만)',
   'echo ''/export/data 10.0.0.0/24(rw,sync,no_root_squash)'' >> /etc/exports

# 디렉토리  대상대역(옵션)
# rw 읽기/쓰기, sync 동기 쓰기, no_root_squash 클라이언트 root 를 그대로 root 로
# 적용(서버에서): exportfs -ra   (이 환경에는 NFS 서버가 없음)',
   '["sh", "-c", ": > /etc/exports"]',
   '["sh", "-c", "l=$(grep ''^/export/data[[:space:]]'' /etc/exports); echo \\\"$l\\\" | grep -q ''10[.]0[.]0[.]0/24'' && echo \\\"$l\\\" | grep -q ''rw'' && echo \\\"$l\\\" | grep -q ''sync'' && echo \\\"$l\\\" | grep -q ''no_root_squash''"]'),

  (27, 14, 'showmount 출력에서 내 서버가 접근할 수 있는 공유 찾기',
   'NFS 서버가 내보내는 공유 목록은 `showmount -e <서버>` 로 확인합니다. 각 공유 옆의 **허용 대상**(IP 대역, `*` 는 모두)이 내 서버를 포함해야 마운트할 수 있고, 아니면 `access denied` 가 납니다. `10.0.1.0/24` 는 `10.0.1.0` ~ `10.0.1.255` 를 뜻합니다.

`/tmp/showmount.txt` 에 `showmount -e` 출력이 저장되어 있습니다. 내 서버 IP `10.0.1.20` 이 접근할 수 있는 공유 경로를 정렬해서 한 줄씩 `/tmp/my_exports.txt` 에 저장하세요.',
   '출력을 보고 어느 공유가 `10.0.1.20` 을 포함하는지 **직접 판단**하세요. 대역 `10.0.1.0/24` 는 10.0.1.x 전체이고 `*` 는 모든 호스트입니다. 해당하는 경로를 `printf ''%s\\n'' 경로1 경로2 | sort > 파일` 처럼 한 줄씩 저장하면 됩니다. (직접 읽는 연습 문제라 자동 추출보다 눈으로 확인하세요)',
   'printf ''%s\\n'' /export/data /export/public | sort > /tmp/my_exports.txt

# 10.0.1.0/24 → 10.0.1.20 포함(/export/data), 10.0.2.0/24 → 미포함(/export/backup), * → 모두(/export/public)',
   '["sh", "-c", "{ echo ''Export list for 10.0.0.5:''; echo ''/export/data    10.0.1.0/24''; echo ''/export/backup  10.0.2.0/24''; echo ''/export/public  *''; } > /tmp/showmount.txt"]',
   '["sh", "-c", "[ \\\"$(sort /tmp/my_exports.txt | paste -sd, -)\\\" = \\\"/export/data,/export/public\\\" ]"]');
