#!/bin/bash

ACTION=$1
WORKDIR=$2
IP=$3
OUTPUT=$4
ZIP_CONFIG=$5

if [ ! -d $WORKDIR/dd ]; then
  if [ "$ACTION" = "init" ]; then
    echo "init"
    /opt/create-datadir.sh $WORKDIR $IP $OUTPUT
  fi

  if [ "$ACTION" = "join" ]; then
    echo "join"
    /opt/join.sh $WORKDIR $IP $ZIP_CONFIG $OUTPUT
  fi
else
  echo "Datadir is already initialized."
fi

exec /opt/quorum-start.sh