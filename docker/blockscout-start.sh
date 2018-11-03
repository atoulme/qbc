#!/bin/bash

if [ "$( psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'" )" = '1' ]
then
  echo "Database already exists" >> /var/blockscout/logs/blockscout.log 2>&1
else
  /opt/blockscout-init.sh >> /var/blockscout/logs/blockscout.log 2>&1
fi

mix do phx.server >> /var/blockscout/logs/blockscout.log 2>&1