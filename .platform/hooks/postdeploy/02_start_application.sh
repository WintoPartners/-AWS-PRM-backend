#!/bin/bash

cd /var/app/current
export NODE_ENV=production
export PORT=8081

# Node.js 프로세스 확인 및 시작
if ! pgrep node > /dev/null; then
    echo "Starting Node.js application..."
    # 이전 프로세스 종료
    pkill node || true
    
    # npm 설치 및 시작
    npm install --production
    npm start > /var/log/nodejs.log 2>&1 &
    echo "Node.js application started"
else
    echo "Node.js process is already running"
fi 