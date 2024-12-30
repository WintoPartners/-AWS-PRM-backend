#!/bin/bash
set -e

# 디렉토리 생성 확인
sudo mkdir -p /var/log/nginx
sudo mkdir -p /etc/nginx/conf.d

# SSL 인증서 존재 여부 확인
SSL_CERT="/etc/letsencrypt/live/api.metheus.pro/fullchain.pem"
SSL_KEY="/etc/letsencrypt/live/api.metheus.pro/privkey.pem"

if [ -f "$SSL_CERT" ] && [ -f "$SSL_KEY" ]; then
    # SSL 설정이 있는 경우
    sudo tee /etc/nginx/conf.d/proxy.conf > /dev/null << 'EOF'
upstream nodejs {
    server 127.0.0.1:8081;
    keepalive 256;
}

server {
    listen 80;
    server_name api.metheus.pro;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name api.metheus.pro;

    ssl_certificate /etc/letsencrypt/live/api.metheus.pro/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.metheus.pro/privkey.pem;
    
    ssl_session_timeout 5m;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
    ssl_prefer_server_ciphers on;

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
    }
}
EOF
else
    # SSL 설정이 없는 경우 HTTP만 설정
    sudo tee /etc/nginx/conf.d/proxy.conf > /dev/null << 'EOF'
upstream nodejs {
    server 127.0.0.1:8081;
    keepalive 256;
}

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
    }
}
EOF
fi

# Nginx 설정 테스트 및 재시작
if sudo nginx -t; then
    sudo systemctl restart nginx
    echo "Nginx configuration is valid and service restarted"
else
    echo "Nginx configuration test failed"
    exit 1
fi 