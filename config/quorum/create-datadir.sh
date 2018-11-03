#!/bin/bash

WORKDIR=$1
IP=$2
OUTPUT=$3
GENESIS_BLOCK_FILE=$4

mkdir -p $WORKDIR/dd/keystore
mkdir -p $WORKDIR/logs
touch $WORKDIR/logs/node.log


nodekey=`/opt/bootnode -genkey /tmp/nodekey -writeaddress;cat /tmp/nodekey`
enode=`/opt/bootnode -nodekeyhex $nodekey -writeaddress`

echo $nodekey > $WORKDIR/nodekey

accountaddress=`/opt/geth --datadir=$WORKDIR/dd --password /var/password/initial_account_password.txt account new`

if [ -f "$GENESIS_BLOCK_FILE" ]
then
  /opt/geth --datadir /var/qdata/dd init $GENESIS_BLOCK_FILE
else
  accountaddress=${accountaddress##*\{}
  accountaddress=${accountaddress%\}}
  initialbalance="0x446c3b15f9926687d2c40534fdb564000000000000"

  cat /opt/istanbul-genesis.json.template | jq -r \
    --arg accountaddress "$accountaddress" \
    --arg initialbalance "$initialbalance" \
    ".alloc[\"$accountaddress\"] = .alloc.INITIAL_ACCOUNT | del(.alloc.INITIAL_ACCOUNT) | .alloc[\"$accountaddress\"].balance = \"$initialbalance\"" \
      > /tmp/genesis.json

  /opt/geth --datadir /var/qdata/dd init /tmp/genesis.json
fi

mkdir -p $WORKDIR/logs;
mkdir -p $WORKDIR/dd/{keystore,geth};
nodekey=`/opt/bootnode -genkey /tmp/nodekey -writeaddress; cat /tmp/nodekey`;
echo $nodekey > $WORKDIR/nodekey
enode=`/opt/bootnode -nodekeyhex $nodekey -writeaddress`;
echo "[\"enode://$enode@$IP:21000?discport=0\"]" | jq '.' > $WORKDIR/dd/static-nodes.json;
cp $WORKDIR/dd/static-nodes.json $WORKDIR/dd/permissioned-nodes.json;
cp /var/password/initial_account_password.txt $WORKDIR/passwords.txt;

zip -j -q $OUTPUT /tmp/genesis.json $WORKDIR/dd/static-nodes.json $WORKDIR/dd/permissioned-nodes.json
