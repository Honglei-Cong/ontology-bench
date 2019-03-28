#!/bin/bash

echo '1' | ./ontology --enable-shard-rpc --config solo-config.json --enable-consensus
echo $! > pid

