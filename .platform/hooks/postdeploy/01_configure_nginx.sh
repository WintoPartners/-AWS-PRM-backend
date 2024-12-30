#!/bin/bash

# 디렉토리 생성 확인
sudo mkdir -p /var/log/nginx
sudo mkdir -p /etc/nginx/conf.d

# Nginx 설정 파일 생성
sudo tee /etc/nginx/conf.d/proxy.conf > /dev/null << 'EOF'
upstream nodejs {
    server 127.0.0.1:8001;
    keepalive 256;
}

# types_hash 설정
types_hash_max_size 2048;
types_hash_bucket_size 128;

server {
    listen 80;
    server_name api.metheus.pro;

    location / {
        proxy_pass http://nodejs;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # CORS 설정
        if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' 'https://app.metheus.pro' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE' always;
            add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
            add_header 'Access-Control-Allow-Credentials' 'true' always;
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Type' 'text/plain charset=UTF-8';
            add_header 'Content-Length' 0;
            return 204;
        }

        add_header 'Access-Control-Allow-Origin' 'https://app.metheus.pro' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE' always;
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
        add_header 'Access-Control-Allow-Credentials' 'true' always;
    }
}
EOF

# Nginx 설정 테스트
if sudo nginx -t; then
    sudo systemctl restart nginx
    echo "Nginx configuration is valid and service restarted"
else
    echo "Nginx configuration test failed"
    exit 1
fi

# Node.js 프로세스 확인 및 시작
cd /var/app/current
if ! pgrep node > /dev/null; then
    echo "Starting Node.js application..."
    # 이전 프로세스 종료
    pkill node || true
    # 환경 변수 설정 확인
    export NODE_ENV=production
    export PORT=8001
    # npm start 실행
    npm install --production
    npm start > /var/log/nodejs.log 2>&1 &
    echo "Node.js application started"
else
    echo "Node.js process is already running"
fi 