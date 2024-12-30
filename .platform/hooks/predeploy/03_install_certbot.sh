#!/bin/bash

# certbot 설치
if ! command -v certbot &> /dev/null; then
    sudo dnf install -y certbot python3-certbot-nginx
fi

# SSL 인증서 발급 (이미 있다면 갱신)
sudo certbot certonly --nginx \
    --non-interactive \
    --agree-tos \
    --email admin@metheus.pro \
    --domains api.metheus.pro \
    --keep-until-expiring

# 인증서 자동 갱신 크론잡 설정
echo "0 0,12 * * * root python -c 'import random; import time; time.sleep(random.random() * 3600)' && certbot renew -q" | sudo tee -a /etc/crontab > /dev/null 