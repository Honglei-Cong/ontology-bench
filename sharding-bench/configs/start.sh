#!/bin/bash

echo '1' | ./ontology --enable-shard-rpc --config solo-config.json --disable-broadcast-net-tx --disable-tx-pool-pre-exec --reserved-only --max-tx-in-block=4100 2>&1 > ontology.log
echo $! > pid

