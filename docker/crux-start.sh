#!/bin/bash

/opt/crux --url=http://$HOSTNAME:9000/ --networkinterface=0.0.0.0 --port=9000 --grpcport=9001 --workdir=/var/cdata/ --socket=../qdata/tm.ipc --publickeys=tm.pub --privatekeys=tm.key --othernodes=$OTHER_NODES --verbosity 4 >> /var/cdata/logs/crux.log 2>&1