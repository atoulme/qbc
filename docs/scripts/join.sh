#!/bin/bash

QUORUM_IP="${1:-0.0.0.0}"
CONSTELLATION_IP="${2:-0.0.0.0}"
FIRST_CONSTELLATION_NODE="${3:-0.0.0.0}"
WORKDIR="${4:-`pwd`}"
CONSTELLATION_FOLDER="$WORKDIR/${5:c1}"
QUORUM_FOLDER="$WORKDIR/${6:q1}"
INITIAL_PASSWORD_FILE="${7:-`pwd`/initial_account_password.txt}"

mkdir -p $WORKDIR/configs
mkdir -p $CONSTELLATION_FOLDER/logs
docker run -v $CONSTELLATION_FOLDER:/var/cdata -it consensys/crux:latest /opt/crux --generate-keys /var/cdata/tm
mkdir -p $QUORUM_FOLDER

env WORKDIR=$WORKDIR \
  CONSTELLATION_FOLDER=$CONSTELLATION_FOLDER \
  QUORUM_FOLDER=$QUORUM_FOLDER \
  QUORUM_IP=$QUORUM_IP \
  CONSTELLATION_IP=$CONSTELLATION_IP \
  FIRST_CONSTELLATION_NODE=$FIRST_CONSTELLATION_NODE \
  INITIAL_PASSWORD_FILE=$INITIAL_PASSWORD_FILE \
  docker-compose -p quorum-${QUORUM_IP//./-} -f `dirname "${BASH_SOURCE[0]}"`/join.yml up -d
