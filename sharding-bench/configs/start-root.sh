#!/bin/bash

echo '1' | ./ontology --enable-shard-rpc --config solo-config.json --enable-consensus --disable-broadcast-net-tx --disable-tx-pool-pre-exec
echo $! > pid

