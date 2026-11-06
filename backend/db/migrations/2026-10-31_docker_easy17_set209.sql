-- 도커 세트 209. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set209.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 5, '도커', 'Docker 기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 5);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 209, '포트·네트워크·실행 옵션: -p 형식, -P 와 EXPOSE, 포트 충돌, network connect, ENTRYPOINT, USER, -e, volume rm', '컨테이너의 포트와 네트워크, 실행 옵션의 동작을 한 개념씩 반복합니다. -p 의 호스트:컨테이너 순서와 docker port 확인, 호스트 주소를 붙인 -p, 호스트 포트를 생략했을 때의 임의 배정, /udp 프로토콜, 같은 호스트 포트를 쓸 때의 port is already allocated 와 Created 상태, EXPOSE 가 호스트에 공개하지 않는 것, -P 가 EXPOSE 한 포트를 모두 공개하는 것, --expose 가 안내일 뿐인 것, --network none 의 lo 만 있는 모습, network connect·disconnect 와 active endpoints 오류, ENTRYPOINT 와 CMD 에 run 인자가 적용되는 방식, USER 와 -u 의 우선순위, -e 값 생략과 빈 값, 사용 중인 볼륨의 rm 오류와 자동 생성을 짧은 객관식·빈칸·순서 문제로 익히고, 포트 공개하고 확인, 실행 중 네트워크 추가·분리, ENTRYPOINT 동작 확인, 사용 중인 볼륨 정리의 순서를 연습합니다.', 'quiz', '도커'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 209);
UPDATE quest_set SET display_order = 178, unit_id = (SELECT id FROM unit WHERE id = 5), icon = '🌉' WHERE id = 209;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 209, 1, '-p 의 호스트:컨테이너 순서', '`docker run -d --name web -p 18217:80 alpine sleep 600` 으로 실행했습니다. `docker port web` 은 무엇을 알려 줄까요?', '앞이 호스트, 뒤가 컨테이너예요.', NULL, NULL, '[]', 'choice', '["호스트의 80 번 포트가 컨테이너의 18217 번 포트로 연결돼 있다", "컨테이너 안에서 열려 있는 모든 포트의 목록을 보여 준다", "컨테이너의 `80/tcp` 가 호스트의 18217 번 포트로 연결돼 있다고 알려 준다. 앞의 숫자가 호스트 포트, 뒤의 숫자가 컨테이너 포트다", "18217 개의 연결이 허용된다는 뜻이다"]', 2, '`docker ps` 의 `PORTS` 열에서도 같은 연결을 볼 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 209 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 209, 2, '호스트 주소를 붙인 -p', '`-p 호스트주소:18218:80` 처럼 맨 앞에 호스트 주소(예: 자기 자신만 가리키는 루프백 주소)를 붙이면 `-p 18218:80` 과 무엇이 다를까요?', '어느 주소로 열지 정해요.', NULL, NULL, '[]', 'choice', '["주소를 붙이면 그 주소의 컨테이너로만 연결된다", "붙인 주소(여기서는 호스트 자신만 가리키는 루프백 주소)로 들어오는 연결만 받는다. 주소를 생략하면 호스트의 모든 주소에서 받는다", "주소를 붙이면 포트가 UDP 로 바뀐다", "둘은 완전히 같다"]', 1, '외부에 열지 않고 내 컴퓨터에서만 접속하게 할 때 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 209 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 209, 3, '호스트 포트를 생략하면', '`docker run -d -p 80 alpine sleep 60` 처럼 호스트 포트를 생략하면 어떻게 될까요?', '호스트 포트는 알아서 정해져요.', NULL, NULL, '[]', 'choice', '["호스트의 사용 가능한 임의 포트가 배정된다. 어느 포트인지는 `docker port` 로 확인한다", "호스트의 80 번 포트가 배정된다", "오류가 나서 컨테이너가 시작되지 않는다", "포트가 공개되지 않는다"]', 0, '실행할 때마다 배정되는 포트가 다를 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 209 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 209, 4, '-p 에 프로토콜 붙이기', '`-p 18219:80/udp` 는 무엇을 뜻할까요? `/udp` 를 생략하면요?', '기본 프로토콜이 있어요.', NULL, NULL, '[]', 'choice', '["`/udp` 를 생략하면 UDP 가 기본이다", "`/udp` 는 컨테이너 이름을 뜻한다", "UDP 는 `-p` 로 공개할 수 없다", "UDP 80 번 포트를 호스트 18219 번에 연결한다. 프로토콜을 생략하면 TCP 이다. `docker port` 에서는 `80/udp` 로 표시된다"]', 3, 'TCP 와 UDP 를 둘 다 열려면 `-p` 를 두 번 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 209 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 209, 5, '호스트 포트 충돌', '이미 `-p 18217:80` 으로 실행 중인 컨테이너가 있을 때 다른 컨테이너를 같은 `-p 18217:80` 으로 실행하면 어떻게 될까요?', '호스트 포트는 하나뿐이에요.', NULL, NULL, '[]', 'choice', '["두 컨테이너가 같은 포트를 나눠 쓴다", "먼저 실행 중이던 컨테이너가 자동으로 멈춘다", "`port is already allocated` 오류로 시작에 실패한다. 이때 컨테이너는 만들어지기만 한 `Created` 상태로 남으므로 `docker rm` 으로 지운다", "다른 포트가 자동으로 배정되어 정상 실행된다"]', 2, '호스트 포트를 바꾸거나 호스트 포트를 생략해 임의 포트를 쓰면 피할 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 209 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 209, 6, 'EXPOSE 만으로는', 'Dockerfile 에 `EXPOSE 80 8080` 이 있는 이미지를 `-p` 나 `-P` 없이 실행하면 호스트에서 접속할 수 있을까요?', 'EXPOSE 는 안내에 가까워요.', NULL, NULL, '[]', 'choice', '["`EXPOSE` 한 포트는 자동으로 같은 번호로 호스트에 공개된다", "접속할 수 없다. `EXPOSE` 는 이 이미지가 쓰는 포트를 이미지 정보(`ExposedPorts`)로 알릴 뿐이고 호스트에 공개하지 않는다. `docker port` 도 비어 있다", "`EXPOSE` 한 포트는 임의의 호스트 포트로 공개된다", "`EXPOSE` 가 있으면 컨테이너가 시작되지 않는다"]', 1, '공개하려면 `-p` 또는 `-P` 가 필요합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 209 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 209, 7, '-P 의 동작', '`docker run -d -P img` 는 어떻게 동작할까요? `EXPOSE` 가 없는 이미지에 쓰면요?', '대문자 P 는 EXPOSE 한 포트를 한꺼번에 공개해요.', NULL, NULL, '[]', 'choice', '["이미지에 `EXPOSE` 된 모든 포트를 호스트의 임의 포트로 공개한다. `EXPOSE` 가 없는 이미지에는 공개할 포트가 없어 아무것도 열리지 않는다", "컨테이너 안에서 열려 있는 모든 포트를 자동으로 찾아 공개한다", "`EXPOSE` 가 없어도 80 번 포트를 공개한다", "`-P` 는 `-p` 와 같고 소문자와 대문자의 차이가 없다"]', 0, '어떤 포트가 어디에 연결됐는지는 `docker port` 로 봅니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 209 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 209, 8, '--expose 옵션', '`docker run -d --expose 9000 alpine sleep 60` 을 하면 호스트에서 9000 번으로 접속할 수 있을까요?', '알리기만 해요.', NULL, NULL, '[]', 'choice', '["`--expose 9000` 은 `-p 9000:9000` 과 같다", "호스트의 임의 포트로 자동 공개된다", "`--expose` 는 오류가 난다", "접속할 수 없다. `--expose` 는 컨테이너의 `ExposedPorts` 에 9000 번을 추가할 뿐 호스트에 공개하지 않는다(`docker port` 가 비어 있다)"]', 3, '`EXPOSE` 와 마찬가지로 안내용 정보입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 209 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 209, 9, '--network none', '`docker run --network none alpine` 의 컨테이너 안 네트워크 인터페이스는 기본 실행과 어떻게 다를까요?', '외부와 연결되지 않아요.', NULL, NULL, '[]', 'choice', '["`none` 이면 `eth0` 만 있고 `lo` 는 없다", "둘 다 똑같이 `eth0` 와 `lo` 가 있다", "`none` 이면 루프백 `lo` 만 있고, 기본(bridge)으로 실행하면 `eth0` 와 `lo` 가 있다. `none` 은 외부와 통신할 수 없다", "`none` 은 호스트의 네트워크를 그대로 쓴다"]', 2, '`/sys/class/net` 을 보면 인터페이스 이름 목록을 확인할 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 209 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 209, 10, 'network connect 와 disconnect', '네트워크 `n1` 에 연결해 실행 중인 컨테이너 `c1` 에 `docker network connect n2 c1` 을 하면 어떻게 될까요? 그 상태에서 `docker network rm n2` 는요?', '실행 중에도 네트워크를 붙일 수 있어요.', NULL, NULL, '[]', 'choice', '["`n2` 가 `n1` 을 대체해 `n1` 연결이 끊어진다", "`c1` 이 `n1` 과 `n2` 두 네트워크에 연결되어 `eth0`, `eth1` 인터페이스를 갖는다. `n2` 에 연결된 컨테이너가 있으면 `active endpoints` 오류로 `rm` 이 거부되므로 `disconnect` 로 먼저 분리한다", "실행 중에는 네트워크를 추가할 수 없다", "연결돼 있어도 `docker network rm n2` 는 바로 성공한다"]', 1, '분리 후에는 컨테이너가 남아 있어도 네트워크를 지울 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 209 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 209, 11, 'ENTRYPOINT 와 CMD', '`ENTRYPOINT ["echo","hi"]` 와 `CMD ["default"]` 가 있는 이미지를 `docker run img`, `docker run img other args` 로 실행하면 각각 무엇이 출력될까요?', 'run 뒤의 인자는 CMD 를 바꿔요.', NULL, NULL, '[]', 'choice', '["앞은 `hi default`, 뒤는 `hi other args` 가 출력된다. `run` 뒤에 적은 인자는 `CMD` 만 대체하고 `ENTRYPOINT` 는 그대로다. `ENTRYPOINT` 를 바꾸려면 `--entrypoint` 를 쓴다", "두 번째는 `other args` 만 출력된다", "두 번 모두 `hi default` 가 출력된다", "두 번째는 `ENTRYPOINT` 와 `CMD` 가 모두 사라져 아무것도 출력되지 않는다"]', 0, '`--entrypoint` 로 바꾸면 이미지의 `CMD` 는 사용되지 않고 뒤에 적은 인자가 쓰입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 209 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 209, 12, 'USER 와 -u', 'Dockerfile 에 `USER nobody` 가 있는 이미지를 `docker run --entrypoint whoami img` 와 `docker run -u root --entrypoint whoami img` 로 실행하면 각각 무엇이 출력될까요?', '-u 는 USER 를 덮어써요.', NULL, NULL, '[]', 'choice', '["두 번 모두 `nobody` 가 출력된다", "두 번 모두 `root` 가 출력된다", "`-u` 는 `docker exec` 에서만 쓸 수 있다", "앞은 `nobody`, 뒤는 `root` 가 출력된다. `docker run -u` 가 이미지의 `USER` 지정보다 우선한다"]', 3, '`docker inspect` 의 `Config.User` 에서 이미지의 `USER` 를 볼 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 209 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 209, 13, '-e 의 형태', '호스트에 `FOO=fromhost` 가 있을 때 `docker run -e FOO img` 와 `docker run -e FOO= img` 의 컨테이너 안 `FOO` 는 각각 무엇일까요?', '값을 쓰느냐 생략하느냐 차이예요.', NULL, NULL, '[]', 'choice', '["`-e FOO` 는 빈 문자열이고 `-e FOO=` 는 `fromhost` 이다", "둘 다 `fromhost` 이다", "`-e FOO`(값 생략)는 호스트의 `FOO` 값 `fromhost` 를 전달하고, `-e FOO=`(등호 뒤 비움)는 빈 문자열로 정의된다. 같은 변수를 `-e` 로 여러 번 주면 마지막 값이 쓰인다", "`-e FOO` 는 오류가 난다"]', 2, '값이 정해진 변수는 `-e FOO=bar` 처럼 직접 줍니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 209 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 209, 14, '사용 중인 볼륨 지우기', '컨테이너가 쓰고 있는 이름 있는 볼륨 `v1` 을 `docker volume rm v1` 으로 지우려 하면 어떻게 될까요? `-v nosuch:/d` 로 실행하면요?', '컨테이너를 먼저 지워야 해요.', NULL, NULL, '[]', 'choice', '["사용 중이어도 바로 지워진다", "`volume is in use` 오류로 지워지지 않으므로 컨테이너를 먼저 지운 뒤 볼륨을 지운다. 없는 이름을 `-v nosuch:/d` 로 쓰면 그 이름의 볼륨이 자동으로 만들어진다", "없는 이름은 오류가 나서 컨테이너가 시작되지 않는다", "볼륨은 컨테이너를 지우면 자동으로 함께 지워진다"]', 1, '`docker volume inspect` 의 `Mountpoint` 로 데이터가 저장된 위치를 확인합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 209 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 209, 15, '포트 공개 옵션', '컨테이너 포트를 **호스트 포트에 연결하는** `docker run` 옵션을 채우세요.', '"publish"의 머리글자이고 소문자예요.', NULL, NULL, '[]', 'fill', '["-p", "-P", "-e", "-v"]', NULL, '긴 이름은 `--publish` 입니다.', '[0]', 'docker run -d {0} 18217:80 alpine', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 209 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 209, 16, 'EXPOSE 포트 모두 공개', '이미지에 `EXPOSE` 된 **모든 포트를 임의의 호스트 포트로 공개하는** 옵션을 채우세요.', '"publish all"의 머리글자이고 대문자예요.', NULL, NULL, '[]', 'fill', '["-P", "-p", "-A", "--all"]', NULL, '`EXPOSE` 가 없으면 공개되는 포트가 없습니다.', '[0]', 'docker run -d {0} alpine', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 209 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 209, 17, '포트 연결 확인', '컨테이너의 **포트가 호스트 어디에 연결됐는지** 보여 주는 하위 명령을 채우세요.', '"포트"를 영어로 쓰세요.', NULL, NULL, '[]', 'fill', '["port", "ports", "map", "expose"]', NULL, '포트 번호를 생략하면 연결된 포트를 모두 보여 줍니다.', '[0]', 'docker {0} web 80', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 209 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 209, 18, 'UDP 로 공개', '`-p` 로 **UDP 포트를 공개할 때** 포트 번호 뒤에 붙이는 프로토콜 이름을 채우세요.', 'TCP 와 짝을 이루는 프로토콜이에요.', NULL, NULL, '[]', 'fill', '["udp", "dgram", "upd", "ip"]', NULL, '생략하면 `tcp` 입니다.', '[0]', 'docker run -d -p 18219:80/{0} alpine', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 209 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 209, 19, 'Dockerfile 포트 안내', 'Dockerfile 에서 **이미지가 쓰는 포트를 알리는** 지시어를 채우세요.', '"드러내다"를 뜻하는 영어예요.', NULL, NULL, '[]', 'fill', '["EXPOSE", "PORT", "OPEN", "PUBLISH"]', NULL, '이 지시어만으로는 호스트에 공개되지 않습니다.', '[0]', '{0} 80', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 209 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 209, 20, '네트워크 없이 실행', '컨테이너를 **루프백만 있는 상태로** 실행하는 `--network` 값을 채우세요.', '"없음"을 뜻하는 영어예요.', NULL, NULL, '[]', 'fill', '["none", "off", "null", "lo"]', NULL, '외부와 통신하지 않는 작업에 씁니다.', '[0]', 'docker run --network {0} alpine', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 209 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 209, 21, '네트워크에 추가', '실행 중인 컨테이너를 **다른 네트워크에도 연결하는** `docker network` 하위 명령을 채우세요.', '"연결하다"를 뜻하는 영어예요.', NULL, NULL, '[]', 'fill', '["connect", "attach", "join", "add"]', NULL, '분리하는 명령은 `disconnect` 입니다.', '[0]', 'docker network {0} n2 c1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 209 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 209, 22, '네트워크에서 분리', '컨테이너를 **네트워크에서 분리하는** `docker network` 하위 명령을 채우세요.', '"연결을 끊다"를 뜻하는 영어예요.', NULL, NULL, '[]', 'fill', '["disconnect", "detach", "leave", "remove"]', NULL, '분리해도 컨테이너는 계속 실행됩니다.', '[0]', 'docker network {0} n1 c1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 209 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 209, 23, '고정 실행 명령', 'Dockerfile 에서 **컨테이너가 항상 실행할 명령을 정하는** 지시어를 채우세요.', '"진입점"을 뜻하는 영어예요.', NULL, NULL, '[]', 'fill', '["ENTRYPOINT", "ENTRY", "STARTUP", "BOOT"]', NULL, '`run` 뒤에 적는 인자는 `CMD` 를 대체합니다.', '[0]', '{0} ["echo","hi"]', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 209 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 209, 24, '진입점 바꾸기', '`docker run` 으로 **이미지의 ENTRYPOINT 를 바꾸는** 옵션의 이름을 채우세요.', 'Dockerfile 의 지시어와 같은 이름이에요.', NULL, NULL, '[]', 'fill', '["entrypoint", "entry", "command", "exec"]', NULL, '이때 `run` 뒤에 적은 인자는 새 진입점의 인자가 됩니다.', '[0]', 'docker run --{0} whoami img', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 209 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 209, 25, '실행 사용자 바꾸기', '`docker run` 으로 **실행할 사용자를 정하는** 옵션을 채우세요.', '"user"의 머리글자예요.', NULL, NULL, '[]', 'fill', '["-u", "-U", "-r", "-s"]', NULL, '이미지의 `USER` 보다 우선합니다.', '[0]', 'docker run {0} root img whoami', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 209 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 209, 26, '포트 공개하고 확인', '컨테이너 포트를 호스트에 공개하고 확인한 뒤 정리하는 순서입니다. 순서에 맞게 놓아 보세요.', '실행 → 연결 확인 → 목록 확인 → 정리 순서예요.', NULL, NULL, '[]', 'order', '["`docker run -d --name web -p 18217:80 alpine sleep 600` 으로 포트를 공개해 실행한다", "`docker port web` 에서 `80/tcp` 가 호스트 18217 번에 연결됐는지 확인한다", "`docker ps` 의 `PORTS` 열에도 같은 연결이 보이는지 확인한다", "`docker rm -f web` 으로 컨테이너를 지운다"]', NULL, '같은 호스트 포트로 다른 컨테이너를 실행하면 충돌합니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 209 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 209, 27, '실행 중 네트워크 추가·분리', '실행 중인 컨테이너에 네트워크를 추가하고 분리하는 순서입니다. 순서에 맞게 놓아 보세요.', '네트워크 만들기 → 실행 → 추가 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`docker network create n1` 과 `docker network create n2` 로 네트워크 두 개를 만든다", "`docker run -d --name c1 --network n1 alpine sleep 600` 으로 `n1` 에 연결해 실행한다", "`docker network connect n2 c1` 로 `n2` 도 추가한다", "`docker exec c1 ls /sys/class/net` 에 `eth0` 와 `eth1` 이 보이는지 확인한다"]', NULL, '분리하려면 `docker network disconnect n1 c1` 을 씁니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 209 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 209, 28, 'ENTRYPOINT 동작 확인', 'ENTRYPOINT 와 CMD 가 있는 이미지의 동작을 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '빌드 → 기본 실행 → 인자 주기 → 진입점 바꾸기 순서예요.', NULL, NULL, '[]', 'order', '["`ENTRYPOINT [\\"echo\\",\\"hi\\"]` 와 `CMD [\\"default\\"]` 로 Dockerfile 을 만들어 빌드한다", "`docker run img` 로 `hi default` 가 나오는지 확인한다", "`docker run img other args` 로 `hi other args` 가 나오는지 확인한다", "`docker run --entrypoint whoami img` 로 진입점을 바꿔 실행한다"]', NULL, '`USER` 가 있는 이미지라면 `whoami` 가 그 사용자를 출력합니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 209 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 209, 29, '사용 중인 볼륨 정리', '컨테이너가 쓰는 볼륨을 지우는 순서입니다. 순서에 맞게 놓아 보세요.', '만들기 → 사용 → 막힘 확인 → 컨테이너 정리 → 볼륨 삭제 순서예요.', NULL, NULL, '[]', 'order', '["`docker volume create v1` 으로 볼륨을 만들고 `docker run -d --name c1 -v v1:/data alpine sleep 600` 으로 컨테이너가 쓰게 한다", "`docker volume rm v1` 이 `volume is in use` 로 막히는지 확인한다", "`docker rm -f c1` 로 컨테이너를 지운다", "`docker volume rm v1` 이 성공하는지 확인한다"]', NULL, '`-v` 로 없는 이름을 쓰면 볼륨이 자동으로 만들어집니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 209 AND order_index = 29);
