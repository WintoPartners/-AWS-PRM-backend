#!/bin/bash

# SSL 디렉토리 생성
sudo mkdir -p /etc/nginx/ssl

# SSL 설정 추가
sudo tee /etc/nginx/conf.d/ssl.conf > /dev/null << 'EOF'
server {
    listen 443 ssl;
    server_name api.metheus.pro;
    
    ssl_certificate      /etc/letsencrypt/live/api.metheus.pro/fullchain.pem;
    ssl_certificate_key  /etc/letsencrypt/live/api.metheus.pro/privkey.pem;
    
    ssl_session_timeout  5m;
    ssl_protocols  TLSv1.2 TLSv1.3;
    ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
    ssl_prefer_server_ciphers   on;
    
    location / {
        proxy_pass  http://nodejs;
        proxy_set_header Connection "";
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
    }
}
EOF 