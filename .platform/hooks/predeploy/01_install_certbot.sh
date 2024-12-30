#!/bin/bash
set -e

# Amazon Linux 2023용 certbot 설치
dnf install -y certbot python3-certbot-nginx

# 디렉토리 생성
mkdir -p /etc/letsencrypt/live/api.metheus.pro

# Nginx 중지
systemctl stop nginx || true

# SSL 인증서 발급 시도
certbot certonly --standalone \
    --non-interactive \
    --agree-tos \
    --email admin@metheus.pro \
    --domains api.metheus.pro

# 권한 설정
chown -R nginx:nginx /etc/letsencrypt 