# 커스텀 이미지 기반 퀘스트 아이디어

무거운 환경(설치에 시간이 걸리는 패키지)은 커스텀 Docker 이미지에 미리 구워서 sandbox 테이블에 등록한다.
퀘스트 전제조건(파일 생성 등 가벼운 세팅)은 기존대로 `setup_cmd`로 처리한다.

---

## 설계 원칙

- 새 퀘스트 세트 추가 시 건드는 파일은 `init.sql` 하나여야 한다.
- 커스텀 이미지는 `sandbox` 테이블에 등록하면 코드 수정 없이 바로 사용 가능하다.
- 이미지 빌드는 `backend/docker/` 경로에 Dockerfile로 관리한다.

```sql
-- 예시: sandbox 테이블에 커스텀 이미지 등록
INSERT INTO sandbox (type, image, binds, description) VALUES
  ('jenkins', 'etude-jenkins', NULL, 'Jenkins가 설치된 환경. 파이프라인 실습용.'),
  ('mysql',   'etude-mysql',   NULL, 'MySQL이 설치된 환경. DB 덤프/복원 실습용.');
```

---

## 퀘스트 아이디어

### Jenkins 설치 및 파이프라인

**이미지**: `etude-jenkins` (Jenkins + Java 미리 설치)

| 퀘스트 | 설명 | grade_cmd 방향 |
|--------|------|----------------|
| Jenkins 시작하기 | `systemctl start jenkins` 또는 `java -jar jenkins.war` 로 Jenkins 기동 | 포트 8080 listen 확인 (`ss -tlnp \| grep 8080`) |
| 플러그인 설치 | Jenkins CLI로 플러그인 설치 | 플러그인 디렉토리 파일 존재 확인 |
| 파이프라인 생성 | Jenkinsfile 작성 후 job 등록 | Jenkinsfile 내용 확인 |

---

### MySQL DB 덤프 및 복원

**이미지**: `etude-mysql` (MySQL 설치 + 샘플 DB 포함)

| 퀘스트 | 설명 | grade_cmd 방향 |
|--------|------|----------------|
| DB 목록 확인 | `mysql -e "SHOW DATABASES"` 결과 저장 | 결과 파일에 샘플 DB명 포함 여부 |
| 테이블 덤프 | `mysqldump`로 특정 테이블 덤프 | 덤프 파일 존재 + `CREATE TABLE` 포함 여부 |
| DB 복원 | 덤프 파일로 새 DB에 복원 | 복원된 DB에서 레코드 조회 결과 확인 |
| 특정 레코드 백업 | 조건 쿼리 결과를 CSV로 저장 | CSV 파일 내용 확인 |

---

### Nginx 설정 실습

**이미지**: `etude-nginx` (Nginx 설치)

| 퀘스트 | 설명 | grade_cmd 방향 |
|--------|------|----------------|
| Nginx 시작하기 | `nginx` 명령으로 기동 | 포트 80 listen 확인 |
| 설정 파일 수정 | `server_name` 또는 `root` 경로 변경 | 설정 파일 내용 grep |
| 가상 호스트 추가 | `/etc/nginx/conf.d/` 에 새 설정 추가 | 파일 존재 + 내용 확인 |
| 리버스 프록시 설정 | `proxy_pass` 설정 작성 | 설정 파일에 `proxy_pass` 포함 여부 |

---

### 커스텀 이미지 vs setup_cmd 역할 구분

| 구분 | 용도 | 예시 |
|------|------|------|
| 커스텀 이미지 | 설치에 시간이 걸리는 패키지 | Jenkins, MySQL, Nginx |
| `setup_cmd` | 퀘스트 전제조건 파일/데이터 세팅 | 파일 생성, DB 샘플 데이터 삽입 |

둘은 함께 쓸 수 있다. 예: `etude-mysql` 이미지 위에 `setup_cmd`로 특정 테이블에 샘플 데이터를 미리 삽입.

---

## 구현 시 고려사항

- **이미지 크기**: Jenkins는 500MB+. 첫 `docker pull` 시간을 줄이려면 로컬 레지스트리 또는 사전 pull이 필요하다.
- **프로세스 기동 대기**: Nginx/MySQL 시작 후 바로 채점하면 아직 준비 안 된 경우가 있다. `setup_cmd`에 `sleep` 또는 health check 루프를 넣는다.
- **포트 충돌**: DinD 환경에서는 컨테이너 내부 포트라 충돌 없음. 호스트 마운트 방식이면 포트 관리 필요.
