-- 도커 세트 77. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set77.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 5, '도커', 'Docker 기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 5);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 77, '컨테이너의 정체: 격리된 프로세스, 네임스페이스와 cgroup, 이미지 레이어', '컨테이너는 가상 컴퓨터가 아니라 **격리된 프로세스**입니다. 네임스페이스(무엇을 보는가)와 cgroup(얼마나 쓰는가), 이미지 레이어와 쓰기 시 복사(CoW), OCI·CRI·containerd, 레지스트리와 태그를 개념으로 잡고, 샌드박스 안에서 네임스페이스·PID 1·cgroup 을 직접 읽어 확인합니다.', 'linux', '도커'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 77);
UPDATE quest_set SET display_order = 177, unit_id = (SELECT id FROM unit WHERE id = 5), icon = '📦' WHERE id = 77;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 77, 1, '컨테이너의 정체 알기', '컨테이너를 가장 정확하게 설명한 것은 무엇일까요?', '가상 컴퓨터(VM)와 무엇이 다른지 생각해 보세요.', NULL, NULL, '[]', 'choice', '["자신만의 커널을 가진 작은 가상 컴퓨터이다", "이미지 파일 그 자체이다", "리눅스 커널의 기능(네임스페이스와 cgroup)으로 **격리된 일반 프로세스**이다", "하드웨어를 에뮬레이션하는 프로그램이다"]', 2, '컨테이너는 호스트와 **커널을 공유**하는 프로세스에 격리(네임스페이스)와 자원 제한(cgroup)을 건 것입니다. 그래서 VM 보다 가볍고 빠르게 시작되며, 호스트에서 `ps` 로 보면 컨테이너 안의 프로세스도 (다른 PID 로) 보입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 77 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 77, 2, '네임스페이스와 cgroup 구분하기', '컨테이너 격리의 두 축 중 **"프로세스가 얼마나 쓸 수 있는가(CPU, 메모리 한도)"** 를 제어하는 것은 무엇일까요?', '다른 하나는 "무엇을 볼 수 있는가"를 제어합니다.', NULL, NULL, '[]', 'choice', '["cgroup", "네임스페이스", "OCI", "Dockerfile"]', 0, '**네임스페이스**는 보이는 범위(파일시스템, 프로세스, 네트워크, 호스트명 등)를 나누고, **cgroup** 은 사용량을 제한하고 측정합니다. `docker run --memory --cpus` 옵션은 내부적으로 cgroup 설정입니다. 네임스페이스만으로는 한 컨테이너가 CPU 를 독점하는 것을 막지 못합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 77 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 77, 3, '네임스페이스 종류 알기', '컨테이너가 **자기만의 호스트명**을 가질 수 있게 하는 네임스페이스는 무엇일까요?', 'UTS, PID, NET, MNT, IPC, USER 가운데 호스트명을 다루는 것입니다.', NULL, NULL, '[]', 'choice', '["PID 네임스페이스", "NET 네임스페이스", "MNT 네임스페이스", "UTS 네임스페이스"]', 3, '**UTS** 는 호스트명·도메인명, **PID** 는 프로세스 번호, **NET** 은 네트워크 인터페이스·포트·라우팅, **MNT** 는 마운트 지점, **IPC** 는 프로세스 간 통신, **USER** 는 사용자·그룹 ID 를 격리합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 77 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 77, 4, '컨테이너의 PID 1', '컨테이너 안에서 PID 1 인 프로세스를 **호스트**에서 `ps` 로 보면 어떻게 보일까요?', '컨테이너는 자신만의 PID 네임스페이스를 가집니다.', NULL, NULL, '[]', 'choice', '["컨테이너 안에서는 PID 1 이지만, 호스트에서는 **다른 PID 로** 보인다", "호스트에서는 보이지 않는다", "호스트에서도 반드시 PID 1 이다", "호스트의 init 프로세스를 대체한다"]', 1, 'PID 네임스페이스 안에서 번호가 새로 매겨져서 컨테이너 안의 첫 프로세스가 PID 1 이 됩니다. 호스트는 같은 프로세스를 자신의 번호 체계로 봅니다. PID 1 이 종료되면 그 컨테이너도 종료됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 77 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 77, 5, '레이어와 이미지 크기', 'Dockerfile 의 한 `RUN` 에서 큰 파일을 만들고, **다음 `RUN` 에서 그 파일을 삭제**했습니다. 이미지 크기는 어떻게 될까요?', '레이어는 쌓이기만 하고 아래 레이어는 그대로입니다.', NULL, NULL, '[]', 'choice', '["줄어들지 않는다. 삭제는 새 레이어에 \\"삭제됨\\"으로만 기록되고 원래 레이어에 파일이 남아 있다", "파일이 지워진 만큼 줄어든다", "삭제하면 이미지가 빌드되지 않는다", "삭제한 레이어만 자동 병합되어 줄어든다"]', 2, '임시 파일은 **같은 `RUN` 명령 안에서** 만들고 지워야 레이어에 남지 않습니다(예: 패키지 설치 후 캐시 삭제를 한 줄에). Dockerfile 의 각 지시어가 레이어 하나를 만듭니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 77 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 77, 6, '쓰기 시 복사(CoW)', '같은 이미지에서 컨테이너 여러 개를 띄워도 서로 간섭하지 않는 이유는 무엇일까요?', '이미지 레이어는 읽기 전용입니다.', NULL, NULL, '[]', 'choice', '["이미지 레이어는 읽기 전용으로 공유하고, 컨테이너마다 **자기만의 읽기/쓰기 레이어**를 하나 더 가지며 수정하는 파일은 그곳으로 복사해 고치기(CoW) 때문이다", "컨테이너마다 이미지를 통째로 복사해 두기 때문이다", "컨테이너는 파일을 수정할 수 없기 때문이다", "이미지가 매번 새로 빌드되기 때문이다"]', 0, '그래서 이미지 레이어는 여러 이미지와 컨테이너가 공유해 디스크를 아끼고, 컨테이너가 삭제되면 그 쓰기 레이어도 사라집니다. 데이터를 남겨야 하면 볼륨을 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 77 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 77, 7, 'OCI, CRI, containerd', '쿠버네티스(kubelet)가 컨테이너 런타임에게 컨테이너 실행을 지시할 때 쓰는 **표준 인터페이스**는 무엇일까요?', '이름이 "Container Runtime Interface" 입니다.', NULL, NULL, '[]', 'choice', '["OCI Image Format", "Dockerfile", "OCI Runtime Bundle", "CRI"]', 3, '**OCI** 는 이미지 포맷과 런타임의 표준을 정하고, **CRI** 는 쿠버네티스가 다양한 런타임을 쓰기 위한 인터페이스입니다. CRI 를 구현한 containerd, CRI-O 가 대표적이고, Docker 가 만든 이미지도 OCI 표준을 따릅니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 77 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 77, 8, '레지스트리와 태그', '`docker run redis` 처럼 **태그를 생략**하면 어떤 이미지를 받을까요?', '기본 태그 이름이 있습니다.', NULL, NULL, '[]', 'choice', '["항상 가장 최신의 안정 버전이 보장된다", "`latest` 태그를 받는다. 이 태그는 \\"최신\\"을 보장하는 이름이 아니라 그냥 기본 태그일 뿐이다", "오류가 난다", "가장 오래된 버전을 받는다"]', 1, '로컬에 이미지가 없을 때만 레지스트리에서 pull 하고, 한 번 받으면 로컬 캐시를 씁니다(레이어 단위라 이미 가진 레이어는 다시 받지 않음). 운영에서는 버전 태그를 명시하는 것이 안전합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 77 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 77, 9, '컨테이너 이식성의 한계', '"컨테이너는 어디서나 똑같이 실행된다"는 말에 **예외**가 되는 경우는 무엇일까요?', '컨테이너는 커널을 공유하고, CPU 에 맞게 컴파일됩니다.', NULL, NULL, '[]', 'choice', '["x86 용으로 만든 이미지를 ARM 서버에서 실행하거나, 특정 커널 버전·모듈이 필요한 앱을 그것이 없는 호스트에서 실행하는 경우", "컨테이너 이름이 길 때", "이미지 태그가 숫자일 때", "로그가 많을 때"]', 0, '컨테이너에는 자체 커널이 없어서 호스트 커널에 의존하고, 이미지의 바이너리는 특정 CPU 아키텍처용입니다. 그래서 Mac(ARM)에서 만든 이미지를 x86 서버에서 쓰려면 플랫폼을 맞춰 빌드해야 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 77 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 77, 10, '내가 속한 네임스페이스 확인하기', '이 샌드박스는 컨테이너입니다. 내 프로세스가 속한 **네임스페이스 종류 목록**을 `/tmp/ns.txt` 에 저장하세요. (파일 이름만 한 줄에 하나씩)', '네임스페이스는 `/proc/프로세스번호/ns/` 아래 링크로 보입니다. 내 프로세스는 `self` 입니다.
확인: `ls -l /proc/self/ns`', 'ls /proc/self/ns > /tmp/ns.txt
cat /tmp/ns.txt

# 링크가 가리키는 [번호]가 같으면 같은 네임스페이스에 속한 것이다', '["sh", "-c", "true"]', '["sh", "-c", "( [ -s /tmp/ns.txt ] ) && ( grep -qx pid /tmp/ns.txt && grep -qx net /tmp/ns.txt && grep -qx uts /tmp/ns.txt && grep -qx mnt /tmp/ns.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "목록 파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/ns.txt ]"]}, {"label": "pid, net, uts, mnt 네임스페이스가 들어 있다", "cmd": ["sh", "-c", "grep -qx pid /tmp/ns.txt && grep -qx net /tmp/ns.txt && grep -qx uts /tmp/ns.txt && grep -qx mnt /tmp/ns.txt"]}]', '[{"title": "HAProxy 공식 문서", "url": "https://docs.haproxy.org/2.4/configuration.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 77 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 77, 11, '컨테이너의 PID 1 확인하기', '이 컨테이너 안에서 **PID 1 인 프로세스의 이름**을 `/tmp/pid1.txt` 에 저장하세요.', '`ps` 로 특정 PID 의 명령 이름만 출력하는 옵션을 찾아보세요 (`ps --help all` 또는 `man ps`). `-p` 로 PID 를, `-o comm=` 로 명령 이름만 출력할 수 있습니다.
확인: `cat /tmp/pid1.txt`', 'ps -o comm= -p 1 > /tmp/pid1.txt
cat /tmp/pid1.txt

# 컨테이너에서는 PID 1 이 init 이 아니라 컨테이너를 시작한 첫 프로세스다', '["sh", "-c", "true"]', '["sh", "-c", "( [ -s /tmp/pid1.txt ] ) && ( [ \\"$(cat /tmp/pid1.txt)\\" = \\"$(ps -o comm= -p 1)\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/pid1.txt ]"]}, {"label": "PID 1 의 이름이 맞다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/pid1.txt)\\" = \\"$(ps -o comm= -p 1)\\" ]"]}]', '[{"title": "HAProxy 공식 문서", "url": "https://docs.haproxy.org/2.4/configuration.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 77 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 77, 12, '컨테이너만의 호스트명 확인하기', '컨테이너는 UTS 네임스페이스 덕분에 **자기만의 호스트명**을 가집니다. 이 컨테이너의 호스트명을 `/tmp/host.txt` 에 저장하세요.', '호스트명을 보여 주는 가장 간단한 명령입니다.
확인: `cat /tmp/host.txt`', 'hostname > /tmp/host.txt
cat /tmp/host.txt

# 보통 컨테이너 ID 의 앞부분이다. 호스트의 이름과 다르다', '["sh", "-c", "true"]', '["sh", "-c", "( [ -s /tmp/host.txt ] ) && ( [ \\"$(cat /tmp/host.txt)\\" = \\"$(hostname)\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/host.txt ]"]}, {"label": "이 컨테이너의 호스트명이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/host.txt)\\" = \\"$(hostname)\\" ]"]}]', '[{"title": "HAProxy 공식 문서", "url": "https://docs.haproxy.org/2.4/configuration.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 77 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 77, 13, 'cgroup 의 메모리 제한 읽기', '컨테이너의 자원 제한은 cgroup 이 파일로 보여 줍니다. 이 컨테이너의 **메모리 최대치 값**을 `/tmp/mem.txt` 에 저장하세요. (파일 `/sys/fs/cgroup/memory.max` 의 내용 그대로)', '`max` 는 "제한 없음"을 뜻합니다. 제한을 걸고 띄운 컨테이너라면 바이트 숫자가 나옵니다.
확인: `cat /sys/fs/cgroup/memory.max`', 'cat /sys/fs/cgroup/memory.max > /tmp/mem.txt
cat /tmp/mem.txt

# docker run --memory=256m 으로 띄우면 268435456 같은 숫자가 보인다', '["sh", "-c", "true"]', '["sh", "-c", "( [ -s /tmp/mem.txt ] ) && ( [ \\"$(cat /tmp/mem.txt)\\" = \\"$(cat /sys/fs/cgroup/memory.max)\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/mem.txt ]"]}, {"label": "cgroup 의 값과 같다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/mem.txt)\\" = \\"$(cat /sys/fs/cgroup/memory.max)\\" ]"]}]', '[{"title": "HAProxy 공식 문서", "url": "https://docs.haproxy.org/2.4/configuration.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 77 AND order_index = 13);
