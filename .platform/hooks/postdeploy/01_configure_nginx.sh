#!/bin/bash

# nginx 기본 설정
cat > /etc/nginx/nginx.conf << 'EOF'
user                    nginx;
error_log               /var/log/nginx/error.log warn;
pid                     /var/run/nginx.pid;
worker_processes        auto;
worker_rlimit_nofile    32153;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    include       conf.d/*.conf;

    map $http_upgrade $connection_upgrade {
        default     "upgrade";
    }
}
EOF

# proxy 설정
cat > /etc/nginx/conf.d/proxy.conf << 'EOF'
upstream nodejs {
    server 127.0.0.1:8080;
    keepalive 256;
}

# HTTPS server
server {
    listen       443 ssl;
    server_name  api.metheus.pro;
    
    # SSL 설정
    ssl_certificate      /etc/letsencrypt/live/api.metheus.pro/fullchain.pem;
    ssl_certificate_key  /etc/letsencrypt/live/api.metheus.pro/privkey.pem;
    
    ssl_session_timeout  5m;
    ssl_protocols  TLSv1.2 TLSv1.3;
    ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
    ssl_prefer_server_ciphers   on;
    
    # 파일 업로드 크기 제한 설정
    client_max_body_size 10M;

    # CORS 설정
    add_header 'Access-Control-Allow-Origin' 'https://app.metheus.pro http://localhost:3000' always;
    add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
    add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization, X-Requested-With' always;
    add_header 'Access-Control-Allow-Credentials' 'true' always;

    location / {
        if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' 'https://app.metheus.pro' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
            add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization, X-Requested-With' always;
            add_header 'Access-Control-Allow-Credentials' 'true' always;
            add_header 'Content-Type' 'text/plain charset=UTF-8';
            add_header 'Content-Length' 0;
            return 204;
        }

        proxy_pass  http://nodejs;
        proxy_set_header Connection "";
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        
        # 타임아웃 설정
        proxy_read_timeout 300;
        proxy_connect_timeout 300;
    }
}

# HTTP to HTTPS redirect
server {
    listen 80;
    server_name api.metheus.pro;
    return 301 https://$server_name$request_uri;
}
EOF

# nginx 설정 테스트
nginx -t

# nginx 재시작
service nginx restart 