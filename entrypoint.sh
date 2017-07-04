#!/bin/bash

source /etc/profile.d/rbenv.sh
cd ${APP_ROOT}

if [ -n "$MYSQL_USER" ]; then
  echo `date '+%Y/%m/%d %H:%M:%S'` $0 "[INFO] MySQL Connection confriming..."
  while :
  do
    if echo `/usr/bin/mysqladmin ping -h ${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_PASSWORD}` 2> /dev/null | grep 'alive'; then
      break
    fi
    sleep 3;
  done
fi

rake db:migrate
rake assets:precompile
rails server
