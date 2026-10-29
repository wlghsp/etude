# DB 변경 자동 적용 (마이그레이션)

배포(`deploy.yml`)가 `git pull` 뒤에 아래 두 가지를 순서대로 자동 실행한다. 서버에서 손으로 할 일은 없다.

1. `etude-linux` 이미지 빌드 (`Dockerfile.linux`가 안 바뀌었으면 캐시라 몇 초)
2. `scripts/migrate.sh` — `backend/db/migrations/*.sql` 중 아직 안 한 파일을 이름순으로 실행

적용 기록은 DB의 `schema_migrations` 테이블(파일명, 적용 시각)에 남고, 같은 파일은 다시 실행하지 않는다.

## 새 DB 변경을 추가하는 법

- `backend/db/migrations/YYYY-MM-DD_설명.sql` 파일을 만든다. 이름순으로 실행되므로 날짜를 앞에 둔다.
- **여러 번 실행해도 안전하게** 쓴다. 새 데이터 삽입은 `INSERT ... SELECT ... FROM DUAL WHERE NOT EXISTS (...)` 가드를 쓴다 (예: `2026-10-29_linux_text_set.sql`). 새 DB는 `02/03_*.sql`로 이미 최신 내용이 들어가므로, 가드가 없으면 중복 삽입된다.
- 퀘스트 내용은 원본(`02_quest_set.sql`, `03_quest_set*.sql`)도 함께 고친다 (단일 진실 공급원).
- `backend/db/update_*.sql`은 이 방식 이전의 기록이다. 건드리지 않는다. 이미 서버에 적용돼 있다고 가정하며 러너는 읽지 않는다 (`migrations/` 하위만 읽는다. MariaDB 초기화 스크립트도 하위 폴더는 실행하지 않는다).

## 의존하는 마이그레이션의 순서 (중요)

마이그레이션은 **파일 이름순**으로 실행된다. 어떤 파일이 다른 파일이 만든 것(컬럼, 샌드박스 타입 등)을 쓰면, 그 파일이 이름순으로 **뒤에** 오도록 이름을 정한다. 앞서야 하는 스키마 변경은 `2026-10-29_00_...` 처럼 숫자를 넣어 맨 앞에 오게 한다 (실수 사례: 퀴즈 세트 추가가 샌드박스 타입 추가보다 이름순으로 먼저 와서 외래 키 오류로 배포가 멈춤).

**배포 전에 `scripts/check-migrations.sh` 를 돌린다.** 마지막으로 성공한 배포의 DB 상태를 로컬 임시 DB에 재현하고, 이번에 새로 들어가는 마이그레이션을 이름순으로 적용해 본다. 로컬 DB는 이미 일부가 적용된 상태라 순서 문제를 가리기 때문에, 로컬에서 `migrate.sh` 가 통과해도 서버에서는 실패할 수 있다.

## 확인과 문제 대응

- 적용 현황: `docker exec etude-db sh -c 'mariadb -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE" -e "SELECT * FROM schema_migrations"'`
- 로컬 실행: `scripts/migrate.sh` (로컬 DB 컨테이너도 `etude-db`)
- 어떤 파일이 실패하면 배포가 그 지점에서 멈춘다(`set -e`). 파일을 고쳐 다시 배포하면 된다. 기록은 성공한 뒤에만 남는다.
- 이미 적용한 파일의 내용을 고쳐도 다시 실행되지 않는다. 고치려면 새 마이그레이션 파일을 추가한다.
