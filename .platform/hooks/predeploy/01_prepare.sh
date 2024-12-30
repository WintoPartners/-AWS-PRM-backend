#!/bin/bash
mkdir -p /var/app/current
mkdir -p /var/app/staging
chown -R webapp:webapp /var/app/current
chown -R webapp:webapp /var/app/staging 