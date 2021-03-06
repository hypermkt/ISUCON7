#!/bin/bash
set -e

now=`date +%Y%m%d-%H%M%S`
NOTIFY=/home/isucon/deploy/scripts/notify.sh

echo 'restart mysql...' | $NOTIFY

sudo sh <<SCRIPT
  mv /var/log/mysql/slow.log /var/log/mysql/slow.log.$now
  systemctl restart mysql
SCRIPT

echo 'service is running' | $NOTIFY
