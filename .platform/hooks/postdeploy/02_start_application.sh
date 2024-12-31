#!/bin/bash

cd /var/app/current

# 로그 디렉토리 생성
mkdir -p /var/log
touch /var/log/nodejs.log
chown webapp:webapp /var/log/nodejs.log

if ! pgrep node > /dev/null; then
    echo "Starting Node.js application..."
    pkill node || true
    
    npm install --production
    # 로그 파일 권한 및 경로 확인
    npm start >> /var/log/nodejs.log 2>&1 &
    echo "Node.js application started"
else
    echo "Node.js process is already running"
fi 