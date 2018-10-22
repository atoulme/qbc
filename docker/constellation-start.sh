#!/bin/bash
TMCONF=/var/qdata/tm.conf
exec env LD_LIBRARY_PATH=/opt/libs /opt/constellation-node $TMCONF --verbosity=4 >> /var/cdata/logs/constellation.log 2>&1
