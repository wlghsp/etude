FROM node:20-alpine
WORKDIR /app

# vcluster-pool.ts가 컨테이너 내부에서 직접 kubectl/vcluster 명령을 실행하므로 설치 필요
RUN apk add --no-cache curl bash && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl" && \
    chmod +x kubectl && mv kubectl /usr/local/bin/kubectl && \
    curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-arm64" && \
    chmod +x vcluster && mv vcluster /usr/local/bin/vcluster

COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
EXPOSE 3001
CMD ["node", "dist/index.js"]