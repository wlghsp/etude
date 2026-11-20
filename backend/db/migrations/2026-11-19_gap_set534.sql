-- 세트 534. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set534.sql, 05·06·08. docs/specs/spec_pilot_gap_sets.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 534, '디스크와 파티션 읽기·나누기: 장치 이름, lsblk, blkid, MBR·GPT', '디스크 이름(sda1, nvme0n1p1, vda)의 규칙부터 lsblk 열(NAME·SIZE·TYPE·MOUNTPOINT) 읽기, blkid 로 UUID·파일시스템 형식 확인, 파일로 연습용 디스크 이미지 만들기(truncate)와 포맷(mkfs.ext4), 파티션 테이블 MBR 과 GPT 의 차이와 구분, partx 로 파티션 목록 읽기, fdisk·sfdisk·parted 로 파티션을 나누는 흐름을 계단식으로 익힙니다. 실제 디스크 대신 이미지 파일로 안전하게 연습합니다.', 'linux', '리눅스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 534);
UPDATE quest_set SET display_order = 755, unit_id = (SELECT id FROM unit WHERE id = 4), icon = '💽' WHERE id = 534;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 534, 1, '장치 이름 읽기: nvme0n1p2 는 무엇일까', '서버의 디스크는 `/dev` 아래에 이름으로 나타납니다. SATA·SCSI 디스크는 `sda`, `sdb`, 가상 서버의 가상 디스크는 `vda`, NVMe(빠른 SSD)는 `nvme0n1` 처럼 이름이 붙고, 디스크 안의 **파티션**(디스크를 나눈 조각)은 뒤에 번호가 붙습니다. 예를 들어 `sda1` 은 `sda` 의 첫 번째 파티션입니다.

`/dev/nvme0n1p2` 는 무엇을 가리킬까요?', 'NVMe 이름은 `nvme<컨트롤러>n<네임스페이스>` 로 디스크를 뜻하고, 뒤의 `p<번호>` 가 파티션입니다.', NULL, NULL, '[]', 'choice', '["두 번째 NVMe 디스크의 첫 번째 파티션", "NVMe 디스크 두 개를 묶은 장치", "첫 번째 NVMe 디스크(`nvme0n1`)의 두 번째 파티션", "`nvme0n1` 디스크 전체"]', 2, '`nvme0n1` 이 디스크이고 `p2` 가 그 디스크의 2번 파티션입니다. `sda1` 처럼 번호를 바로 붙이지 않고 `p` 를 끼우는 이유는 디스크 이름이 이미 숫자로 끝나기 때문입니다. 두 번째 NVMe 디스크는 `nvme1n1`, 가상 디스크의 첫 파티션은 `vda1` 입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 534 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 534, 2, 'lsblk 출력에서 파티션 없는 디스크와 마운트 안 된 파티션 찾기', '**상황** — 서버에 디스크를 추가했다는데 어디에 연결됐는지 헷갈립니다. 담당자가 `lsblk` 출력을 `/tmp/report/lsblk.txt` 에 남겼습니다. 열은 `NAME`(장치 이름), `SIZE`(크기), `TYPE`(`disk` 는 디스크 전체, `part` 는 파티션, `loop` 는 파일을 디스크처럼 쓰는 가상 장치), `MOUNTPOINTS`(연결된 경로, 비어 있으면 어디에도 연결되지 않음)입니다. (출력은 `lsblk -l -o NAME,SIZE,TYPE,MOUNTPOINTS` 로 뽑은 목록형입니다. 기본 `lsblk` 는 트리 모양으로 나옵니다)

**문제**
1. **파티션이 하나도 없는 디스크**의 이름을 `/tmp/nopart.txt` 에 저장하세요.
2. **파티션이지만 마운트 지점이 비어 있는** 장치의 이름을 `/tmp/unmounted.txt` 에 저장하세요. (이름만, 한 줄씩)', '`TYPE` 이 `part` 인 줄 중 마운트 지점이 빈 것을 찾으세요. 파티션 없는 디스크는 바로 아래에 `part` 줄이 이어지지 않습니다.', 'cat /tmp/report/lsblk.txt
awk ''$3=="part" && NF==3 {print $1}'' /tmp/report/lsblk.txt > /tmp/unmounted.txt
echo vdb > /tmp/nopart.txt
cat /tmp/nopart.txt /tmp/unmounted.txt

# nvme0n1 에는 nvme0n1p1 이 딸려 있고, vdb 는 파티션 없이 디스크 그대로다. nvme0n1p1 은 마운트 지점이 비어 있다', '["sh", "-c", "rm -f /tmp/*.txt /tmp/*.sh /tmp/*.sql /tmp/*.cnf; rm -rf /tmp/lab /tmp/report; mkdir -p /tmp/lab /tmp/report\\ncat > /tmp/report/lsblk.txt <<''EOF''\\nNAME        SIZE TYPE MOUNTPOINTS\\nloop0      63.9M loop /snap/core/1000\\nsda         100G disk\\nsda1          1G part /boot\\nsda2         99G part /\\nnvme0n1     500G disk\\nnvme0n1p1   500G part\\nvdb          20G disk\\nEOF\\n"]', '["sh", "-c", "( [ \\"$(cat /tmp/nopart.txt)\\" = vdb ] ) && ( [ \\"$(cat /tmp/unmounted.txt)\\" = nvme0n1p1 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "파티션 없는 디스크를 적었다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/nopart.txt)\\" = vdb ]"]}, {"label": "마운트 안 된 파티션을 적었다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/unmounted.txt)\\" = nvme0n1p1 ]"]}]', '[{"title": "lsblk(8) 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/lsblk.8.html"}, {"title": "fdisk(8) 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/fdisk.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 534 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 534, 3, '장치 이름 채우기', '디스크 이름 규칙을 확인합니다. 설명에 맞게 빈칸을 채우세요.', '`sd`·`vd` 계열은 디스크 이름 뒤에 번호만, NVMe 는 `p` 를 끼운 뒤 번호입니다. 디스크 이름의 알파벳은 순서대로(a, b, c…) 올라갑니다.', NULL, NULL, '[]', 'fill', '["vdb", "vdb2", "sdb3", "sdc3", "nvme0n1p3", "nvme0n13"]', NULL, '`vd` 는 가상 디스크, 두 번째는 알파벳 `b` 라서 `vdb` 입니다. 두 번째 SATA 디스크는 `sdb`, 세 번째 파티션은 `sdb3` 입니다(`sdc` 는 세 번째 디스크). NVMe 는 이름이 숫자 `1` 로 끝나므로 구분을 위해 `p` 를 끼워 `nvme0n1p3` 이 됩니다.', '[0, 2, 4]', '가상 서버의 두 번째 가상 디스크 전체       : /dev/{0}
두 번째 SATA 디스크의 세 번째 파티션   : /dev/{1}
첫 NVMe 디스크의 세 번째 파티션        : /dev/{2}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 534 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 534, 4, '연습용 디스크 이미지 파일 만들기', '실제 디스크를 건드리면 위험하므로, **파일 하나를 디스크처럼** 써서 연습합니다. `truncate -s 크기 파일` 은 지정한 크기의 파일을 순식간에 만듭니다(내용은 0 으로 채워진 것으로 보이며, 실제 디스크 공간은 쓰는 만큼만 차지하는 "희소 파일"입니다). 크기 단위 `M` 은 1024×1024 바이트입니다.

**문제** — `/tmp/lab/disk.img` 를 **정확히 64MiB**(67108864 바이트) 크기의 파일로 만드세요.', '`truncate` 의 `-s` 옵션에 크기를 주세요. 만든 뒤 `ls -l` 로 바이트 수를 확인하면 됩니다.', 'truncate -s 64M /tmp/lab/disk.img
ls -l /tmp/lab/disk.img
du -h /tmp/lab/disk.img

# ls 는 64MiB 로 보이지만 du 는 거의 0 이다. 내용을 쓰기 전에는 공간을 차지하지 않는 희소 파일이다', '["sh", "-c", "rm -f /tmp/*.txt /tmp/*.sh /tmp/*.sql /tmp/*.cnf; rm -rf /tmp/lab /tmp/report; mkdir -p /tmp/lab /tmp/report"]', '["sh", "-c", "( [ \\"$(stat -c %s /tmp/lab/disk.img)\\" = 67108864 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "64MiB 파일이 있다", "cmd": ["sh", "-c", "[ \\"$(stat -c %s /tmp/lab/disk.img)\\" = 67108864 ]"]}]', '[{"title": "lsblk(8) 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/lsblk.8.html"}, {"title": "fdisk(8) 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/fdisk.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 534 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 534, 5, '이미지 파일에 ext4 파일시스템 만들기', '디스크(또는 파티션)는 **파일시스템**을 만들어야 파일을 저장할 수 있습니다. `mkfs.ext4 장치` 로 ext4 를 만들고, `-L 이름` 으로 사람이 읽기 쉬운 **라벨**을 붙일 수 있습니다. 일반 파일에 만들 때는 "블록 장치가 아니다"라는 확인 질문이 나올 수 있어 `-F` 로 넘깁니다. (실제 디스크에서는 이 명령이 기존 데이터를 지우므로 장치 이름을 꼭 다시 확인합니다)

**문제** — `/tmp/lab/disk.img`(64MiB, 이미 만들어져 있음)에 **ext4** 파일시스템을 만들고 라벨을 `backup` 으로 지정하세요.', '`mkfs.ext4` 에 라벨 옵션과 이미지 경로를 주세요. 질문이 나오면 강제 옵션을 떠올리세요. 결과는 `blkid 파일` 로 확인합니다.', 'mkfs.ext4 -F -L backup /tmp/lab/disk.img
blkid /tmp/lab/disk.img

# blkid 에 LABEL="backup" TYPE="ext4" 와 새 UUID 가 나온다. 포맷 전에는 blkid 가 아무것도 출력하지 않는다', '["sh", "-c", "rm -f /tmp/*.txt /tmp/*.sh /tmp/*.sql /tmp/*.cnf; rm -rf /tmp/lab /tmp/report; mkdir -p /tmp/lab /tmp/report; truncate -s 64M /tmp/lab/disk.img"]', '["sh", "-c", "( [ \\"$(blkid -s TYPE -o value /tmp/lab/disk.img)\\" = ext4 ] ) && ( [ \\"$(blkid -s LABEL -o value /tmp/lab/disk.img)\\" = backup ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "형식이 ext4 다", "cmd": ["sh", "-c", "[ \\"$(blkid -s TYPE -o value /tmp/lab/disk.img)\\" = ext4 ]"]}, {"label": "라벨이 backup 이다", "cmd": ["sh", "-c", "[ \\"$(blkid -s LABEL -o value /tmp/lab/disk.img)\\" = backup ]"]}]', '[{"title": "lsblk(8) 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/lsblk.8.html"}, {"title": "fdisk(8) 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/fdisk.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 534 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 534, 6, 'blkid 로 UUID 와 파일시스템 형식 읽기', '`blkid 장치` 는 장치에 있는 파일시스템의 **UUID**(장치 이름이 바뀌어도 변하지 않는 고유 번호)와 **TYPE**(파일시스템 형식)을 보여 줍니다. 설정 파일 `/etc/fstab` 에 `/dev/sdb1` 대신 `UUID=...` 를 적는 이유는, 디스크를 꽂는 순서에 따라 `sdb` 가 `sdc` 로 바뀔 수 있기 때문입니다.

**문제** — 이미지 `/tmp/lab/data.img` 의 **UUID** 를 `/tmp/uuid.txt` 에, **파일시스템 형식**을 `/tmp/fstype.txt` 에 저장하세요. (값만, 따옴표 없이)', '`blkid` 출력에서 UUID 값만 골라야 합니다. 필요한 부분만 출력하는 옵션이 있는지 `blkid --help` 를 보거나, 출력을 `grep`·`sed` 로 가공해도 됩니다. 이 이미지는 ext4 가 아닐 수 있으니 직접 확인하세요.', 'blkid /tmp/lab/data.img
blkid -s UUID -o value /tmp/lab/data.img > /tmp/uuid.txt
blkid -s TYPE -o value /tmp/lab/data.img > /tmp/fstype.txt
cat /tmp/uuid.txt /tmp/fstype.txt

# 이름 대신 UUID 로 적으면 디스크 순서가 바뀌어도 같은 디스크를 가리킨다', '["sh", "-c", "rm -f /tmp/*.txt /tmp/*.sh /tmp/*.sql /tmp/*.cnf; rm -rf /tmp/lab /tmp/report; mkdir -p /tmp/lab /tmp/report; truncate -s 32M /tmp/lab/data.img; mkfs.ext3 -q -F /tmp/lab/data.img"]', '["sh", "-c", "( [ -n \\"$(cat /tmp/uuid.txt)\\" ] && [ \\"$(cat /tmp/uuid.txt)\\" = \\"$(blkid -s UUID -o value /tmp/lab/data.img)\\" ] ) && ( [ \\"$(cat /tmp/fstype.txt)\\" = ext3 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "UUID 가 맞다", "cmd": ["sh", "-c", "[ -n \\"$(cat /tmp/uuid.txt)\\" ] && [ \\"$(cat /tmp/uuid.txt)\\" = \\"$(blkid -s UUID -o value /tmp/lab/data.img)\\" ]"]}, {"label": "형식이 맞다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/fstype.txt)\\" = ext3 ]"]}]', '[{"title": "lsblk(8) 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/lsblk.8.html"}, {"title": "fdisk(8) 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/fdisk.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 534 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 534, 7, 'MBR 과 GPT, 어느 쪽을 고를까', '파티션 테이블은 디스크의 맨 앞에 "어디서 어디까지가 몇 번 파티션"을 적어 두는 표입니다. 방식은 크게 **MBR**(옛 방식, `dos` 라고도 부름)과 **GPT**(새 방식) 두 가지입니다. MBR 은 디스크 하나에 주(primary) 파티션을 **최대 4개**까지 만들 수 있고 **약 2TB**까지만 인식합니다. 새로 4TB 디스크를 서버에 넣어 전부 쓰려고 합니다. 어떻게 해야 할까요?', '2TB 를 넘는 용량을 쓰려면 한계가 없는 쪽의 테이블이 필요합니다.', NULL, NULL, '[]', 'choice', '["GPT 파티션 테이블로 만든다", "MBR 로 만든다(4TB 도 문제없다)", "디스크를 둘로 쪼개 각각 MBR 로 만든다", "파티션 없이는 사용할 수 없으므로 포기한다"]', 0, 'MBR 은 파티션 위치를 32비트 섹터 번호로 적어 약 2TB(512바이트 섹터 기준) 이상은 표현하지 못하고, 주 파티션은 4개까지입니다. GPT 는 64비트로 적어 사실상 제한이 없고(기본 파티션 128개), 표의 사본을 디스크 끝에도 두어 더 안전합니다. 4TB 디스크 전체를 쓰려면 GPT 가 맞습니다. 참고로 파티션 없이 디스크 전체에 파일시스템을 만드는 것도 가능하지만 이 문제의 선택지는 아닙니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 534 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 534, 8, '이미지의 파티션 테이블 종류 알아보기', '`blkid -p 파일` 은 파일시스템이 아니라 **파티션 테이블**의 종류를 `PTTYPE` 으로 보여 줍니다. MBR 은 `dos`, GPT 는 `gpt` 로 나옵니다. (`-p` 는 캐시를 쓰지 않고 장치를 직접 읽는 옵션입니다)

**문제** — `/tmp/lab/a.img` 와 `/tmp/lab/b.img` 는 서로 다른 방식의 파티션 테이블이 들어 있는 연습용 디스크입니다. **GPT 인 이미지의 파일 이름**(`a.img` 또는 `b.img`)을 `/tmp/gpt_image.txt` 에 저장하세요.', '`blkid -p` 에 두 파일을 각각 주고 `PTTYPE` 값을 비교하세요.', 'blkid -p /tmp/lab/a.img
blkid -p /tmp/lab/b.img
echo b.img > /tmp/gpt_image.txt

# PTTYPE="dos" 는 MBR, PTTYPE="gpt" 는 GPT 다. GPT 는 두 번째 섹터(오프셋 512)에 EFI PART 라는 글자가 있다 (xxd -s 512 -l 8 b.img)', '["sh", "-c", "rm -f /tmp/*.txt /tmp/*.sh /tmp/*.sql /tmp/*.cnf; rm -rf /tmp/lab /tmp/report; mkdir -p /tmp/lab /tmp/report; cat > /tmp/.mkpt.pl <<''EOF''\\nuse Compress::Zlib;\\nmy ($kind, $f, @parts) = @ARGV;\\nopen(my $o, ''+<'', $f) or die; binmode $o;\\nmy $total = (-s $f) / 512;\\nmy @p = map { [split /:/] } @parts;\\nif ($kind eq ''mbr'') {\\n  seek($o, 440, 0); print $o pack(''V'', 0x12345678);\\n  my $i = 0;\\n  for my $e (@p) {\\n    seek($o, 446 + 16 * $i++, 0);\\n    print $o pack(''C a3 C a3 V V'', 0, \\"\\\\0\\\\0\\\\0\\", hex($e->[2]), \\"\\\\0\\\\0\\\\0\\", $e->[0], $e->[1]);\\n  }\\n} else {\\n  my ($ent, $i) = ('''', 0);\\n  for my $e (@p) { $i++;\\n    $ent .= pack(''a16 a16 Q< Q< Q< a72'', \\"\\\\xaf\\\\x3d\\\\xc6\\\\x0f\\\\x83\\\\x84\\\\x72\\\\x47\\\\x8e\\\\x79\\\\x3d\\\\x69\\\\xd8\\\\x47\\\\x7d\\\\xe4\\", pack(''C16'', $i, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16), $e->[0], $e->[0] + $e->[1] - 1, 0, '''');\\n  }\\n  $ent .= \\"\\\\0\\" x (128 * 128 - length $ent);\\n  my $h = pack(''a8 V V V V Q< Q< Q< Q< a16 Q< V V V'', ''EFI PART'', 0x10000, 92, 0, 0, 1, $total - 1, 34, $total - 34, pack(''C16'', 9, 8, 7, 6, 5, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1, 1), 2, 128, 128, crc32($ent));\\n  substr($h, 16, 4) = pack(''V'', crc32($h));\\n  seek($o, 512, 0); print $o $h;\\n  seek($o, 1024, 0); print $o $ent;\\n  seek($o, 446, 0); print $o pack(''C a3 C a3 V V'', 0, \\"\\\\0\\\\2\\\\0\\", 0xee, \\"\\\\xff\\\\xff\\\\xff\\", 1, $total - 1);\\n}\\nseek($o, 510, 0); print $o \\"\\\\x55\\\\xaa\\";\\nclose $o;\\nEOF\\ntruncate -s 64M /tmp/lab/a.img /tmp/lab/b.img; perl /tmp/.mkpt.pl mbr /tmp/lab/a.img 2048:32768:83 34816:16384:82; perl /tmp/.mkpt.pl gpt /tmp/lab/b.img 2048:32768:0 34816:65185:0; rm -f /tmp/.mkpt.pl"]', '["sh", "-c", "( [ \\"$(cat /tmp/gpt_image.txt)\\" = b.img ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "GPT 인 이미지를 적었다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/gpt_image.txt)\\" = b.img ]"]}]', '[{"title": "lsblk(8) 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/lsblk.8.html"}, {"title": "fdisk(8) 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/fdisk.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 534 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 534, 9, 'partx 로 파티션 목록 읽고 가장 큰 파티션 찾기', '`partx -s 파일` 은 디스크의 파티션 표를 읽어 번호(`NR`), 시작 섹터(`START`), 끝 섹터(`END`), 섹터 수(`SECTORS`), 크기(`SIZE`)를 한 줄씩 보여 줍니다. (섹터는 디스크를 나누는 최소 단위로 보통 512바이트입니다. 실제로는 `fdisk -l` 이나 `lsblk` 로 보는 정보와 같은 내용입니다)

**문제** — `/tmp/lab/m3.img` 의 파티션 표를 읽고, **가장 큰 파티션의 번호**를 `/tmp/big_nr.txt` 에, **그 파티션의 섹터 수**를 `/tmp/big_sectors.txt` 에 저장하세요. (숫자만)', '`partx -s` 출력에서 `SECTORS` 열이 가장 큰 줄을 찾으세요. 정렬(`sort`)이나 눈으로 비교 둘 다 됩니다.', 'partx -s /tmp/lab/m3.img
partx -s /tmp/lab/m3.img | tail -n +2 | sort -k4 -n | tail -1
echo 3 > /tmp/big_nr.txt
echo 79872 > /tmp/big_sectors.txt

# 시작 섹터 2048 은 1MiB 위치로, 최신 도구가 맨 앞 1MiB 를 비워 두는 관례다', '["sh", "-c", "rm -f /tmp/*.txt /tmp/*.sh /tmp/*.sql /tmp/*.cnf; rm -rf /tmp/lab /tmp/report; mkdir -p /tmp/lab /tmp/report; cat > /tmp/.mkpt.pl <<''EOF''\\nuse Compress::Zlib;\\nmy ($kind, $f, @parts) = @ARGV;\\nopen(my $o, ''+<'', $f) or die; binmode $o;\\nmy $total = (-s $f) / 512;\\nmy @p = map { [split /:/] } @parts;\\nif ($kind eq ''mbr'') {\\n  seek($o, 440, 0); print $o pack(''V'', 0x12345678);\\n  my $i = 0;\\n  for my $e (@p) {\\n    seek($o, 446 + 16 * $i++, 0);\\n    print $o pack(''C a3 C a3 V V'', 0, \\"\\\\0\\\\0\\\\0\\", hex($e->[2]), \\"\\\\0\\\\0\\\\0\\", $e->[0], $e->[1]);\\n  }\\n} else {\\n  my ($ent, $i) = ('''', 0);\\n  for my $e (@p) { $i++;\\n    $ent .= pack(''a16 a16 Q< Q< Q< a72'', \\"\\\\xaf\\\\x3d\\\\xc6\\\\x0f\\\\x83\\\\x84\\\\x72\\\\x47\\\\x8e\\\\x79\\\\x3d\\\\x69\\\\xd8\\\\x47\\\\x7d\\\\xe4\\", pack(''C16'', $i, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16), $e->[0], $e->[0] + $e->[1] - 1, 0, '''');\\n  }\\n  $ent .= \\"\\\\0\\" x (128 * 128 - length $ent);\\n  my $h = pack(''a8 V V V V Q< Q< Q< Q< a16 Q< V V V'', ''EFI PART'', 0x10000, 92, 0, 0, 1, $total - 1, 34, $total - 34, pack(''C16'', 9, 8, 7, 6, 5, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1, 1), 2, 128, 128, crc32($ent));\\n  substr($h, 16, 4) = pack(''V'', crc32($h));\\n  seek($o, 512, 0); print $o $h;\\n  seek($o, 1024, 0); print $o $ent;\\n  seek($o, 446, 0); print $o pack(''C a3 C a3 V V'', 0, \\"\\\\0\\\\2\\\\0\\", 0xee, \\"\\\\xff\\\\xff\\\\xff\\", 1, $total - 1);\\n}\\nseek($o, 510, 0); print $o \\"\\\\x55\\\\xaa\\";\\nclose $o;\\nEOF\\ntruncate -s 64M /tmp/lab/m3.img; perl /tmp/.mkpt.pl mbr /tmp/lab/m3.img 2048:32768:83 34816:16384:82 51200:79872:83; rm -f /tmp/.mkpt.pl"]', '["sh", "-c", "( [ \\"$(cat /tmp/big_nr.txt)\\" = 3 ] ) && ( [ \\"$(cat /tmp/big_sectors.txt)\\" = 79872 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "가장 큰 파티션 번호가 맞다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/big_nr.txt)\\" = 3 ]"]}, {"label": "섹터 수가 맞다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/big_sectors.txt)\\" = 79872 ]"]}]', '[{"title": "lsblk(8) 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/lsblk.8.html"}, {"title": "fdisk(8) 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/fdisk.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 534 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 534, 10, 'fdisk 로 이미지에 GPT 파티션 하나 만드는 순서', '`fdisk 장치` 는 대화형으로 파티션을 나누는 도구입니다. 메모리에서만 바뀌다가 `w` 를 입력하면 그제야 디스크에 기록됩니다. 연습 이미지 `disk.img` 를 **GPT 로 시작해 파티션 1개를 만들고, 만든 결과를 확인한 뒤 저장**하는 흐름을 앞에서 뒤로 놓으세요. (확인은 저장 **전에** 합니다)', '도구를 켜는 것이 먼저이고, 디스크에 실제로 기록되는 단계가 무엇인지 생각해 보세요. 표 종류는 파티션을 만들기 전에 정합니다.', NULL, NULL, '[]', 'order', '["`p` 를 입력해 만든 파티션 목록을 확인한다", "`n` 을 입력해 새 파티션을 만든다(번호·시작·끝 입력)", "`w` 를 입력해 디스크에 기록하고 나간다", "`g` 를 입력해 새 GPT 파티션 테이블을 만든다", "`fdisk disk.img` 로 대화 모드를 시작한다"]', NULL, '`fdisk disk.img` 로 시작해 `g`(새 GPT 테이블; MBR 은 `o`), `n`(새 파티션), `p`(현재 상태 출력) 로 확인한 뒤 `w` 로 기록합니다. `q` 로 나가면 아무것도 저장되지 않습니다. 같은 일을 한 줄로 하려면 `sfdisk` 에 `label: gpt` 와 `size=...` 를 입력으로 주거나, `parted -s disk.img mklabel gpt mkpart primary ext4 1MiB 100%` 를 씁니다. 이 샌드박스에는 해당 도구가 없어서 실습 대신 읽기로 확인했습니다.', '[4, 3, 1, 0, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 534 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 534, 11, '파티션을 만들었는데 lsblk 에 안 보인다', '운영 중인 서버에서 새 디스크 `/dev/sdb` 에 `parted` 로 파티션을 만들고 저장했습니다. 그런데 `lsblk` 에는 `sdb1` 이 보이지 않습니다. 디스크를 뽑았다 꽂거나 재부팅하고 싶지는 않습니다. 가장 알맞은 조치는 무엇일까요?', '커널이 파티션 표를 다시 읽게 하는 명령입니다. 이름에 "probe(탐색)" 가 들어갑니다.', NULL, NULL, '[]', 'choice', '["`partprobe /dev/sdb` 로 커널에 파티션 표를 다시 읽게 한다", "`mkfs.ext4 /dev/sdb` 를 실행해 다시 만든다", "`rm /dev/sdb1` 로 장치 파일을 지운다", "`chmod 777 /dev/sdb` 로 권한을 연다"]', 0, '파티션 표를 디스크에 쓰고 나서도 이미 사용 중인 디스크는 커널이 옛 표를 쥐고 있을 수 있습니다. `partprobe /dev/sdb`(또는 `partx -u`)로 다시 읽게 하면 재부팅 없이 `sdb1` 이 나타납니다. `mkfs` 는 파티션이 있는 뒤에 하는 단계이고, 디스크 전체에 하면 만든 표를 지웁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 534 AND order_index = 11);
