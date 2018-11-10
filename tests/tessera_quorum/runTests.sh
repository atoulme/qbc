#!/bin/bash

INDEX=-1
PASSED=()

echo "test private tx: is readable by recipient?"
INDEX=$INDEX+1
PASSED+=(false)
message="0xca843569e3427144cead5e4d5999a3d0ccf92b8eed9d02e382b34818e88b88a309c7fe71e65f419d"
echo "  sending message from node1 to node2"
json=`curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_sendTransaction","params":[{"from": "0xed9d02e382b34818e88b88a309c7fe71e65f419d", "to": "0xca843569e3427144cead5e4d5999a3d0ccf92b8e", "gas": "0x76c0", "data": "'$message'", "privateFor": ["QfeDAys9MPDs2XHExtc84jKGHxZg/aj52DTh0vtA3Xc="]}],"id":1}' 0.0.0.0:22001`
result=`node -e "obj = JSON.parse(JSON.stringify($json)); console.log(obj.result);"`
json=`curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_getTransactionByHash","params":["'$result'"],"id":1}' 0.0.0.0:22001`
echo $json
result=`node -e "obj = JSON.parse(JSON.stringify($json)); console.log(obj.result.input);"`
echo "  transaction input: $result"
json=`curl -s -X POST --data '{"jsonrpc":"2.0", "method":"eth_getQuorumPayload", "params":["'$result'"], "id":1}' 0.0.0.0:22002`
result=`node -e "obj = JSON.parse(JSON.stringify($json)); console.log(obj.result);"`
echo "  message(from node2's POV): $result"
if [ "$result" == "$message" ]; then
    echo "PASSED"
    PASSED[$INDEX]=true
else
    echo "FAILED"
fi

echo "test private tx: is not readable by others?"
INDEX=$INDEX+1
PASSED+=(false)
message="0xca843569e3427144cead5e4d5999a3d0ccf92b8eed9d02e382b34818e88b88a309c7fe71e65f419d"
echo "  sending message from node1 to node2"
json=`curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_sendTransaction","params":[{"from": "0xed9d02e382b34818e88b88a309c7fe71e65f419d", "to": "0xca843569e3427144cead5e4d5999a3d0ccf92b8e", "gas": "0x76c0", "data": "'$message'", "privateFor": ["QfeDAys9MPDs2XHExtc84jKGHxZg/aj52DTh0vtA3Xc="]}],"id":1}' 0.0.0.0:22001`
result=`node -e "obj = JSON.parse(JSON.stringify($json)); console.log(obj.result);"`
echo "  transaction hash: $result"
json=`curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_getTransactionByHash","params":["'$result'"],"id":1}' 0.0.0.0:22001`
result=`node -e "obj = JSON.parse(JSON.stringify($json)); console.log(obj.result.input);"`
echo "  transaction input: $result"
json=`curl -s -X POST --data '{"jsonrpc":"2.0", "method":"eth_getQuorumPayload", "params":["'$result'"], "id":1}' 0.0.0.0:22003`
result=`node -e "obj = JSON.parse(JSON.stringify($json)); console.log(obj.result);"`
echo "  message(from node3's POV): $result"
if [ "$result" == "0x" ]; then
    echo "PASSED"
    PASSED[$INDEX]=true
else
    echo "FAILED"
fi

echo "test public tx: is readable by recipient?"
INDEX=$INDEX+1
PASSED+=(false)
message="0xca843569e3427144cead5e4d5999a3d0ccf92b8eed9d02e382b34818e88b88a309c7fe71e65f419d"
echo "  sending message from node1 to node3"
json=`curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_sendTransaction","params":[{"from": "0xed9d02e382b34818e88b88a309c7fe71e65f419d", "to": "0x0fbdc686b912d7722dc86510934589e0aaf3b55a", "gas": "0x76c0", "data": "'$message'"}],"id":1}' 0.0.0.0:22001`
result=`node -e "obj = JSON.parse(JSON.stringify($json)); console.log(obj.result);"`
echo "  transaction hash: $result"
json=`curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_getTransactionByHash","params":["'$result'"],"id":1}' 0.0.0.0:22002`
result=`node -e "obj = JSON.parse(JSON.stringify($json)); console.log(obj.result.input);"`
echo "  message(from node2's POV): $result"

if [ "$result" == "$message" ]; then
    echo "PASSED"
    PASSED[$INDEX]=true
else
    echo "FAILED"
fi

echo "test public tx: is readable by others?"
INDEX=$INDEX+1
PASSED+=(false)
message="0xca843569e3427144cead5e4d5999a3d0ccf92b8eed9d02e382b34818e88b88a309c7fe71e65f419d"
echo "  sending message from node1 to node3"
json=`curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_sendTransaction","params":[{"from": "0xed9d02e382b34818e88b88a309c7fe71e65f419d", "to": "0x0fbdc686b912d7722dc86510934589e0aaf3b55a", "gas": "0x76c0", "data": "'$message'"}],"id":1}' 0.0.0.0:22001`
result=`node -e "obj = JSON.parse(JSON.stringify($json)); console.log(obj.result);"`
echo "  transaction hash: $result"
json=`curl -s -X POST --data '{"jsonrpc":"2.0","method":"eth_getTransactionByHash","params":["'$result'"],"id":1}' 0.0.0.0:22003`
result=`node -e "obj = JSON.parse(JSON.stringify($json)); console.log(obj.result.input);"`
echo "  message(from node3's POV): $result"

if [ "$result" == "$message" ]; then
    echo "PASSED"
    PASSED[$INDEX]=true
else
    echo "FAILED"
fi

for PASSED in ${PASSED[@]}; do
  if "$PASSED" = true; then exit 0; else exit 1; fi
done