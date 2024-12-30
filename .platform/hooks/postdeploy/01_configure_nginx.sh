#!/bin/bash
set -e

# Nginx 기본 설정
cat > /etc/nginx/conf.d/proxy.conf << 'EOF'
upstream nodejs {
    server 127.0.0.1:8081;
    keepalive 256;
}

# HTTP 서버
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

# types_hash 관련 경고 해결을 위한 설정 추가
cat > /etc/nginx/conf.d/types_hash.conf << 'EOF'
types_hash_max_size 4096;
types_hash_bucket_size 128;
EOF

# Nginx 설정 테스트
nginx -t

# Nginx 재시작
systemctl restart nginx 