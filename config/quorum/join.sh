#!/bin/bash

WORKDIR=$1
IP=$2
CONFIG_ZIP=$3
OUTPUT=$4

tmpfolder=$(mktemp -d)
unzip $CONFIG_ZIP -d $tmpfolder

/opt/create-datadir.sh $WORKDIR $IP $OUTPUT $tmpfolder/genesis.json

jq -s add $tmpfolder/static-nodes.json $WORKDIR/dd/static-nodes.json > $tmpfolder/static-out.json
jq -s add $tmpfolder/permissioned-nodes.json $WORKDIR/dd/permissioned-nodes.json > $tmpfolder/permisioned-out.json
cp $tmpfolder/static-out.json $WORKDIR/dd/static-nodes.json
cp $tmpfolder/permisioned-out.json $WORKDIR/dd/permissioned-nodes.json

zip -j -q $OUTPUT $tmpfolder/genesis.json $WORKDIR/dd/static-nodes.json $WORKDIR/dd/permissioned-nodes.json
