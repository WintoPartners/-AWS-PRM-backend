#!/bin/bash
set -e

# EPEL 저장소 추가
sudo dnf install -y epel-release

# certbot 설치
sudo dnf install -y certbot python3-certbot-nginx

# 디렉토리 생성
sudo mkdir -p /etc/letsencrypt/live/api.metheus.pro

# Nginx 중지 (certbot이 80포트 사용을 위해)
sudo systemctl stop nginx || true

# SSL 인증서 발급 시도
sudo certbot certonly --standalone \
    --non-interactive \
    --agree-tos \
    --email admin@metheus.pro \
    --domains api.metheus.pro \
    --keep-until-expiring

# 권한 설정
sudo chown -R nginx:nginx /etc/letsencrypt 