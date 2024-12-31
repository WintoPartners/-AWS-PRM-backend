#!/bin/bash

# 기존 Node.js 제거
yum remove -y nodejs nodejs-full-i18n

# Node.js 18.x 설치
curl -sL https://rpm.nodesource.com/setup_18.x | bash -
yum clean all && yum makecache
yum install -y nodejs

# 디렉토리 생성
mkdir -p /var/app/current
mkdir -p /var/app/staging

# 권한 설정
chown -R webapp:webapp /var/app/current
chown -R webapp:webapp /var/app/staging

# 환경 변수 설정
export NODE_ENV=production
export PORT=8080