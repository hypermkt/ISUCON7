#!/bin/bash
set -ex

IPADDR=$1
USERNAME=$USER
DEPLOY_DIR=/home/isucon/deploy
APP_DIR=/home/isucon/isubata/webapp/php

echo $USERNAME 'deploying...' | ./scripts/notify.sh

rsync -av ./ rev:$DEPLOY_DIR
ssh -A rev rm -rf $APP_DIR
sleep 3s
ssh -A rev ln -fs $DEPLOY_DIR/webapp/php $APP_DIR

rsync -av ./ app:$DEPLOY_DIR
ssh -A app rm -rf $APP_DIR
sleep 3s
ssh -A app ln -fs $DEPLOY_DIR/webapp/php $APP_DIR

rsync -av ./ db:$DEPLOY_DIR

echo $USERNAME 'deploy done' | ./scripts/notify.sh
