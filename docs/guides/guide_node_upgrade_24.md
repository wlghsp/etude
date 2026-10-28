# Node 20 → 24 (LTS) 업그레이드

> 이 문서의 6단계를 보고 로컬, 운영 이미지, 서버 호스트의 Node를 20에서 24로 올립니다.

## 왜, 그리고 왜 24인가

- **Node 20은 2026년 4월 말에 EOL**이라 보안 패치가 끊겼다. 운영 이미지(`backend/Dockerfile`)가 아직 이 버전이다.
- 24는 현재 **활성 LTS**(Krypton)이고 지원이 2028년 4월까지다. 22는 2027년 4월에 끝나서 또 올려야 한다.
- 26은 최신(Current)이지만 아직 LTS가 아니다. LTS가 되고 의존성이 따라온 뒤에 검토한다.
- Node 20에 묶인 도구가 있다: vitest 최신(5)은 Node 22.12 이상이 필요해서 지금은 3에 머물러 있다.
- `backend/package.json`의 `@types/node`는 이미 `^26`이라 타입과 런타임이 어긋나 있다.

> 날짜와 LTS 일정은 올리기 전에 https://nodejs.org/en/about/previous-releases 에서 한 번 확인한다.

## 완료 기준

- [ ] 로컬 `node -v`가 `v24.x`
- [ ] `npm run build`, `npm test`가 Node 24에서 통과 (backend)
- [ ] `frontend`의 `npm run build`가 Node 24에서 통과
- [ ] 새 운영 이미지가 빌드되고 컨테이너 안에서 `bcrypt`가 동작
- [ ] 서버에 배포한 뒤 로그인과 터미널 접속이 정상
- [ ] 서버 호스트의 Node도 24, 저장소 안의 버전 표기가 모두 24

## Node 버전이 적힌 곳 (모두 바꾼다)

| 위치 | 용도 | 현재 |
|---|---|---|
| 내 컴퓨터 (nvm) | 로컬 개발 | 20.19.6 |
| `.nvmrc` (새로 추가) | 로컬 버전의 기준 | 없음 |
| `backend/package.json` `@types/node` | 타입 | `^26` (어긋남) |
| `backend/Dockerfile` | **운영 백엔드 런타임** | `node:20-alpine` |
| `infra/scripts/setup.sh` | 새 서버 구성 시 호스트 Node (프론트 빌드용) | `setup_20.x` |
| `docs/guides/completed/guide_phase8_deploy.md` | 위 스크립트를 설명하는 문서 | `setup_20.x` |
| 실행 중인 서버 호스트 | `deploy.yml`이 `frontend`를 빌드할 때 사용 | 20 |

> 단일 진실 공급원 원칙: 로컬 기준은 `.nvmrc` 한 곳으로 둔다. Dockerfile과 `setup.sh`는 도구 특성상 따로 적어야 하지만,
> 바꿀 때 이 표의 모든 줄을 같이 본다.

## 확인된 사실 (위험 평가)

- `bcrypt`(네이티브 모듈)는 `linux-arm64`와 `linux-x64`에 `glibc`/`musl` 미리 빌드 바이너리를 모두 포함한다.
  운영 서버(ARM, Alpine 이미지)에서 컴파일 없이 쓸 수 있을 가능성이 높다. 그래도 Step 4에서 실제로 불러 본다.
- 주요 의존성의 엔진 요구는 느슨하다 (`bcrypt >=18`, `dockerode >=14.17`, `mysql2 >=8`).
- `frontend`의 `vite 8`은 Node 20.19 이상 또는 22.12 이상이면 되므로 24에서 문제없다.
- 로컬 Mac(Apple Silicon)과 운영 서버가 둘 다 **arm64**라서, 로컬에서 이미지를 빌드해 보면 운영과 같은 조건이다.

---

## Step 1. 로컬을 24로

```bash
nvm install 24
nvm use 24
node -v        # v24.x
```

저장소 루트에 `.nvmrc`를 만든다 (내용은 한 줄).

```
24
```

이후 이 저장소에서는 `nvm use`만 치면 맞는 버전으로 바뀐다.

의존성을 새 Node로 다시 설치한다. 네이티브 모듈(`bcrypt`)은 Node 버전마다 바이너리를 다시 고르기 때문이다.

```bash
cd backend && rm -rf node_modules && npm ci
cd ../frontend && rm -rf node_modules && npm ci
```

## Step 2. 타입 정리와 빌드 확인

`backend/package.json`의 `@types/node`를 24로 맞춘다 (프론트는 이미 `^24`).

```bash
cd backend
npm install --save-dev @types/node@^24
npm run build
npm test
```

- 타입이 26이면 Node 26에만 있는 API를 써도 컴파일이 통과하는 문제가 있다. 24로 맞추면 24 기준으로 검사된다.
- `npm run build`에서 새 타입 오류가 나면 **원인을 먼저 확인**한다. 오류가 나는 코드가 24에 없는 API를 쓰고 있었다는 뜻일 수 있다.

프론트도 확인한다.

```bash
cd ../frontend
npm run build
```

## Step 3. vitest를 최신으로

Node 22.12 이상이 되었으므로 vitest 5를 설치할 수 있다.

```bash
cd backend
npm install --save-dev vitest@^5
npm test
```

> 이전에 Node 20에서 `npm install vitest`가 `Cannot read properties of null (reading 'edgesOut')`로 죽은 것은
> vitest 5의 엔진 요구(Node 22.12 이상) 때문이었다. 24에서는 이 오류가 나지 않아야 한다.
> 만약 같은 오류가 나면 `node -v`와 `npm -v`부터 확인한다 (`nvm use 24`를 빼먹은 경우가 많다).

## Step 4. 운영 이미지를 24로

`backend/Dockerfile` 첫 줄만 바꾼다.

```dockerfile
FROM node:24-alpine
```

로컬에서 이미지를 빌드하고 `bcrypt`가 동작하는지 확인한다.

```bash
cd backend
docker build -t etude-backend:node24 .
docker run --rm etude-backend:node24 node -v
docker run --rm etude-backend:node24 node -e "import('bcrypt').then(m => console.log('bcrypt ok', m.default.hashSync('x', 4).length))"
```

- 첫 번째는 `v24.x`, 두 번째는 `bcrypt ok 60`이 나와야 한다.
- 빌드 중 `npm ci`가 `package-lock.json` 불일치로 실패하면 Step 2, 3에서 바꾼 lock 파일을 커밋하지 않은 것이다.
- `kubectl`, `vcluster` 다운로드(`arm64`)는 Node와 무관하므로 영향이 없다.

## Step 5. 서버 구성 스크립트와 문서

새 서버를 만들 때도 24가 설치되게 한다.

- `infra/scripts/setup.sh`: `setup_20.x` → `setup_24.x`
- `docs/guides/completed/guide_phase8_deploy.md`: 같은 줄(`setup_20.x`)을 `setup_24.x`로

## Step 6. 서버에 반영

순서가 중요하다. 백엔드(컨테이너)와 호스트의 Node는 서로 독립이다.

1. 변경을 커밋·푸시하고 `deploy.yml`(Actions → Deploy → Run workflow)을 실행한다.
   Dockerfile이 `node:24-alpine`이므로 **백엔드 컨테이너는 이 배포로 24가 된다.**
2. 로그인과 터미널(linux, docker, k8s)을 직접 확인한다.
3. 서버 호스트의 Node(프론트 빌드용)를 올린다. 서버에 접속해서:

   ```bash
   node -v    # v20.x 확인
   curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash -
   sudo apt-get install -y nodejs
   node -v    # v24.x
   ```

4. `deploy.yml`을 한 번 더 실행해서 프론트 빌드가 24에서도 통과하는지 본다.

> 호스트 Node는 프론트 `npm run build`에만 쓰이므로 1번(백엔드 이미지)과 3번을 따로 해도 서로 영향이 없다.
> 문제가 생기면 어느 쪽이 원인인지 가를 수 있도록 나눠서 한다.

## 되돌리기

- 백엔드 이미지 문제: `Dockerfile`을 `node:20-alpine`으로 되돌리고 `deploy.yml`을 다시 실행한다.
- 호스트 Node 문제: `setup_20.x`로 다시 설치한다.
- 두 되돌림은 서로 독립이다.

## 자주 막히는 곳

| 증상 | 원인 |
|---|---|
| `bcrypt` import 오류 (로컬) | Step 1의 `rm -rf node_modules && npm ci`를 안 함 |
| 이미지에서 `bcrypt` 오류 | prebuild 불일치. `docker run ... node -v`로 Node 버전과 아키텍처(`uname -m`)부터 확인 |
| `npm ci`가 lock 불일치로 실패 | `package.json`을 바꿨는데 `package-lock.json`을 커밋하지 않음 |
| `nvm use`가 버전을 못 찾음 | `nvm install 24`를 안 함 |
| 빌드에서 타입 오류가 늘어남 | `@types/node` 26 → 24 변경으로 드러난 오류. 24에 없는 API를 쓰던 코드인지 확인 |

## 이 Step에서 다루지 않는 것

- `npm audit`의 운영 의존성 취약점(`fastify`, `mysql2` 등) — 별도 작업으로 다룬다.
- Node 26 LTS 전환 — 지원이 안정된 뒤에 검토한다.
