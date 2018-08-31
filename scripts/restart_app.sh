#!/bin/bash
set -e

now=`date +%Y%m%d-%H%M%S`
NOTIFY=/home/isucon/deploy/scripts/notify.sh

echo 'restart nginx...' | $NOTIFY

sudo sh <<SCRIPT
  mv /var/log/nginx/access_log.tsv /var/log/nginx/access_log.tsv.$now
  systemctl restart nginx

  systemctl restart isubata.php
  rm -f /tmp/xdebug
SCRIPT

echo 'service is running' | $NOTIFY
