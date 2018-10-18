#!/bin/bash

# Wait for each node to have 3 peers
json=`curl -s -X POST --data '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":74}' 0.0.0.0:22001`
result=`node -e "obj = JSON.parse(JSON.stringify($json)); console.log(obj.result);"`
counter=0
end=$((counter+600))
nodeNum=0;
while [ $nodeNum -lt 4 ]; do
    if [ $counter -gt $end ]; then
        break
    else
        echo "waiting for nodes to connect"
        sleep 1
        json=`curl -s -X POST --data '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":74}' 0.0.0.0:$((22001+nodeNum))`
        result=`node -e "obj = JSON.parse(JSON.stringify($json)); console.log(obj.result);"`
        if [ "$result" == "0x3" ]; then
          let nodeNum=$nodeNum+1
        fi
        echo "node: $nodeNum numPeers: $result"
    fi
    let counter=$counter+1

done;

# Wait for the blockNo to start incrementing
json=`curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":74}' 0.0.0.0:22001`
result=`node -e "obj = JSON.parse(JSON.stringify($json)); console.log(obj.result);"`
counter=0
end=$((counter+600))
while [ "$result" == "0x0" ]; do

    if [ $counter -gt $end ]; then
        break
    else
        echo "waiting for nodes to initialize"
        sleep 1
        json=`curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":74}' 0.0.0.0:22001`
        result=`node -e "obj = JSON.parse(JSON.stringify($json)); console.log(obj.result);"`
        echo "blockNumber: $result"
    fi
    let counter=$counter+1
done;