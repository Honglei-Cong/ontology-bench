#!/bin/bash

cd scripts
./init.sh && ./startChains.sh 
cd ../ 
./scripts/shardInit.sh && ./scripts/shardCreate.sh
