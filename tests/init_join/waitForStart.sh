#!/bin/bash

port1=$1
port2=$2
port3=$3

# Wait for the blockNo to start incrementing
json=`curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":74}' 0.0.0.0:$port1`
result=`node -e "obj = JSON.parse(JSON.stringify($json)); console.log(obj.result);"`
counter=0
end=$((counter+600))
while [ "$result" == "0x0" ]; do

    if [ $counter -gt $end ]; then
        break
    else
        echo "waiting for nodes to initialize"
        sleep 1
        json=`curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":74}' 0.0.0.0:$port1`
        result=`node -e "obj = JSON.parse(JSON.stringify($json)); console.log(obj.result);"`
        echo "blockNumber: $result"
    fi
    let counter=$counter+1
done;