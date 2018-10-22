#!/bin/bash

# Wait for the socket to Constellation to be available
while [ ! -S "/var/qdata/tm.ipc" ]; do
   sleep 0.1
done

GETH_ARGS="--syncmode full --mine --port 21000 --rpc --rpcport 22000 --rpcaddr 0.0.0.0 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,istanbul --nodiscover --datadir /var/qdata/dd --nodekey /var/qdata/nodekey --unlock 0 --password /var/qdata/passwords.txt"
if [ ! -f /var/qdata/tm.conf ]; then
    exec env LD_LIBRARY_PATH=/opt/libs PRIVATE_CONFIG=../var/qdata/tm.ipc /opt/geth $GETH_ARGS --verbosity=6 >> /var/qdata/logs/node.log 2>&1
else
    exec env LD_LIBRARY_PATH=/opt/libs PRIVATE_CONFIG=/var/qdata/tm.conf /opt/geth $GETH_ARGS --verbosity=6 >> /var/qdata/logs/node.log 2>&1
fi
