#!/bin/bash
echo "Sending private transaction"
PRIVATE_CONFIG=/../var/qdata/tm.ipc /opt/geth --exec "loadScript(\"simpleContract.js\")" attach ipc:/var/qdata/dd/geth.ipc