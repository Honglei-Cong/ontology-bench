#!/bin/bash -x

#servers=("10.1.4.4" "10.1.4.5" "10.1.4.6" "10.1.4.7")
#servers=("10.1.4.4" "10.1.4.5" "10.1.4.6" "10.1.4.7" "10.1.4.8" "10.1.4.104")
#servers=("10.1.4.4" "10.1.4.5" "10.1.4.6" "10.1.4.7" "10.1.4.8" "10.1.4.104" "10.1.4.105" "10.1.4.107" "10.1.4.106" "10.1.4.108" "10.1.4.111" "10.1.4.110" )
servers=("10.1.4.4" "10.1.4.5" "10.1.4.6" "10.1.4.7" "10.1.4.8" "10.1.4.112" "10.1.4.113")

# start txgen
for s in "${servers[@]}"
do
ssh  -f $s 'cd /mnt/txgen && nohup ./txgen config.json wallet.dat' 2>&1 >> TxLog/txlog_$s.log &
done

