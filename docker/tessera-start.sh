#!/bin/bash
cd /opt

peers=$(echo -n $OTHER_NODES | sed 's/,/ --peer.url /g')

java $JAVA_OPTS -jar tessera-app.jar -configfile /var/cdata/tessera-config.json \
  --jdbc.url jdbc:h2:/var/cdata/data \
  --peer.url $peers \
  --unixSocketFile /var/qdata/tm.ipc \
  --server.port 9000 \
  --server.hostName http://$HOSTNAME \
  --server.bindingAddress http://0.0.0.0:9000 \
    >> /var/cdata/logs/tessera.log 2>&1
