#!/bin/bash

QUORUM_IP="${1:-0.0.0.0}"
CONSTELLATION_IP="${2:-0.0.0.0}"
WORKDIR="${3:-`pwd`}"
CONSTELLATION_FOLDER="$WORKDIR/${4:c1}"
QUORUM_FOLDER="$WORKDIR/${5:q1}"
INITIAL_PASSWORD_FILE="${6:-`pwd`/initial_account_password.txt}"

mkdir -p $WORKDIR/configs
mkdir -p $CONSTELLATION_FOLDER/logs
docker run -v $CONSTELLATION_FOLDER:/var/cdata -it consensys/crux:latest /opt/crux --generate-keys /var/cdata/tm
mkdir -p $QUORUM_FOLDER
touch $QUORUM_FOLDER/passwords.txt
env WORKDIR=$WORKDIR \
  CONSTELLATION_FOLDER=$CONSTELLATION_FOLDER \
  QUORUM_FOLDER=$QUORUM_FOLDER \
  QUORUM_IP=$QUORUM_IP \
  CONSTELLATION_IP=$CONSTELLATION_IP \
  INITIAL_PASSWORD_FILE=$INITIAL_PASSWORD_FILE \
  docker-compose -p quorum-${QUORUM_IP//./-} -f `dirname "${BASH_SOURCE[0]}"`/init.yml up  -d