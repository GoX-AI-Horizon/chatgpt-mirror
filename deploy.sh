#!/bin/bash

set -e

sudo docker compose pull

sudo docker compose up -d

sudo docker images |grep dairoot|grep none |awk '{print $3}' | xargs docker rmi > /dev/null 2>&1