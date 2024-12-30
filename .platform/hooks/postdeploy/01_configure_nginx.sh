#!/bin/bash

# 디렉토리 생성 확인
sudo mkdir -p /var/log/nginx
sudo mkdir -p /etc/nginx/conf.d

# Nginx 설정 파일 생성
sudo tee /etc/nginx/conf.d/proxy.conf > /dev/null << 'EOF'
upstream nodejs {
    server 127.0.0.1:8081;
    keepalive 256;
}

# HTTP -> HTTPS 리다이렉션
server {
    listen 80;
    server_name api.metheus.pro;
    return 301 https://$server_name$request_uri;
}

# HTTPS 설정
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

        # CORS 설정
        add_header 'Access-Control-Allow-Origin' 'https://app.metheus.pro' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE' always;
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
        add_header 'Access-Control-Allow-Credentials' 'true' always;
    }
}
EOF

# Nginx 설정 테스트 및 재시작
if sudo nginx -t; then
    sudo systemctl restart nginx
    echo "Nginx configuration is valid and service restarted"
else
    echo "Nginx configuration test failed"
    exit 1
fi 