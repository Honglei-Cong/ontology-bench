#!/bin/bash

WALLET="./wallets/wallet0.dat"
PASSWD="1"
ONTOLOGY="./bin/ontology"
ROOTSERVER="10.1.4.9"
WALLETCNT=95

# withdraw ong
ssh $ROOTSERVER "cd /mnt/shard && echo $PASSWD | ./ontology asset transfer  --from 1 --to 1 --amount 1"
sleep 5
ssh $ROOTSERVER "cd /mnt/shard && echo $PASSWD | ./ontology asset withdrawong 1 "
sleep 5
ssh $ROOTSERVER "cd /mnt/shard && echo $PASSWD | ./ontology asset balance 1 "

# transfer ont / ong
counter=1
while [ $counter -le $WALLETCNT ]
do
ADDR=`./bin/ontology account list -v -w wallets/wallet$counter.dat | head -1 | awk '{print $2}'`
ssh $ROOTSERVER "cd /mnt/shard && echo $PASSWD | ./ontology asset transfer --from 1 --to $ADDR --amount 200000"
ssh $ROOTSERVER "cd /mnt/shard && echo $PASSWD | ./ontology asset transfer --asset ong --from 1 --to $ADDR --amount 200000"
((counter++))
done

sleep 10

counter=0
while [ $counter -le $WALLETCNT ]
do
ADDR=`./bin/ontology account list -v -w wallets/wallet$counter.dat | head -1 | awk '{print $2}'`
ssh $ROOTSERVER "cd /mnt/shard && echo $PASSWD | ./ontology asset balance $ADDR"
((counter++))
done

shardPerNode=1
servers=("10.1.4.10" "10.1.4.11")
# servers=("10.1.4.11" "10.1.4.10" "10.1.4.12" "10.1.4.13" "10.1.4.14" "10.1.4.15" "10.1.4.16" "10.1.4.17" "10.1.4.18" "10.1.4.19" "10.1.4.21" "10.1.4.20" "10.1.4.22" "10.1.4.23" "10.1.4.25" "10.1.4.26" "10.1.4.27" "10.1.4.24" "10.1.4.28" "10.1.4.29" "10.1.4.30" "10.1.4.31" "10.1.4.33" "10.1.4.32" "10.1.4.34" "10.1.4.35" "10.1.4.36" "10.1.4.37" "10.1.4.38" "10.1.4.40" "10.1.4.39" "10.1.4.41" "10.1.4.42" "10.1.4.43" "10.1.4.44" "10.1.4.45" "10.1.4.48" "10.1.4.49" "10.1.4.51" "10.1.4.50" "10.1.4.53" "10.1.4.52" "10.1.4.54" "10.1.4.55" "10.1.4.56" "10.1.4.57" "10.1.4.58" "10.1.4.59" "10.1.4.60" "10.1.4.61" "10.1.4.62" "10.1.4.63" "10.1.4.64" "10.1.4.65" "10.1.4.66" "10.1.4.67" "10.1.4.68" "10.1.4.69" "10.1.4.70" "10.1.4.71" "10.1.4.72" "10.1.4.74" "10.1.4.73" "10.1.4.77" "10.1.4.75" "10.1.4.76" "10.1.4.79" "10.1.4.78" "10.1.4.80" "10.1.4.81" "10.1.4.82" "10.1.4.83" "10.1.4.84" "10.1.4.85" "10.1.4.87" "10.1.4.86" "10.1.4.88" "10.1.4.89" "10.1.4.90" "10.1.4.91" "10.1.4.92" "10.1.4.93" "10.1.4.94" "10.1.4.95" "10.1.4.96" "10.1.4.97" "10.1.4.98" "10.1.4.99" "10.1.4.101" "10.1.4.100" "10.1.4.102" "10.1.4.103")

# create chains
id=1
counter=1
for s in "${servers[@]}"
do
	sed -i -e "s/wallet[0-9]*.dat/wallet$counter.dat/g" params/ShardCreate.json

	i=0
	while [ $i -lt $shardPerNode ]
	do
        echo "create shard " $id
		cat params/ShardCreate.json
		./bin/shardmgmt create config.json params/ShardCreate.json
        sleep 10
		((i++))
		((id++))
	done

	((counter++))
done

# config chains
id=1
counter=1
for s in "${servers[@]}"
do
	sed -i -e "s/wallet[0-9]*.dat/wallet$counter.dat/g" params/ShardConfig.json

	i=0
	while [ $i -lt $shardPerNode ]
	do
		sed -i -e "s/\"shard_id\":.*/\"shard_id\": $id,/g" params/ShardConfig.json
        echo "config shard " $id
		head -8 params/ShardConfig.json
		./bin/shardmgmt config config.json params/ShardConfig.json
        sleep 10
		((i++))
		((id++))
	done

	((counter++))
done

# peer apply for shard
id=1
counter=1
for s in "${servers[@]}"
do
	pk=`./bin/ontology account list -v -w wallets/wallet$counter.dat | grep 'Public key' | awk '{print $3}'`
	sed -i -e "s/wallet[0-9]*.dat/wallet$counter.dat/g" params/ShardPeerApply.json
    sed -i -e "s/\"peer_pub_key\":.*/\"peer_pub_key\": \"$pk\"/g" params/ShardPeerApply.json

	i=0
	while [ $i -lt $shardPerNode ]
	do
		sed -i -e "s/\"shard_id\":.*/\"shard_id\": $id,/g" params/ShardPeerApply.json
        echo "peer apply for shard " $id
		head -5 params/ShardPeerApply.json
		./bin/shardmgmt peerapply config.json params/ShardPeerApply.json
        sleep 10
		((i++))
		((id++))
	done

	((counter++))
done

# peer approved for shard
id=1
counter=1
for s in "${servers[@]}"
do
	pk=`./bin/ontology account list -v -w wallets/wallet$counter.dat | grep 'Public key' | awk '{print $3}'`
	sed -i -e "s/wallet[0-9]*.dat/wallet$counter.dat/g" params/ShardPeerApprove.json
    sed -i -e "s/\"peer_pub_key\":.*/\"peer_pub_key\": \"$pk\"/g" params/ShardPeerApprove.json

	i=0
	while [ $i -lt $shardPerNode ]
	do
		sed -i -e "s/\"shard_id\":.*/\"shard_id\": $id,/g" params/ShardPeerApprove.json
        echo "peer approve for shard " $id
		head -5 params/ShardPeerApprove.json
		./bin/shardmgmt peerapprove config.json params/ShardPeerApprove.json
        sleep 10
		((i++))
		((id++))
	done

	((counter++))
done

# peer join chain
id=1
counter=1
for s in "${servers[@]}"
do
	pk=`./bin/ontology account list -v -w wallets/wallet$counter.dat | grep 'Public key' | awk '{print $3}'`
	sed -i -e "s/wallet[0-9]*.dat/wallet$counter.dat/g" params/ShardPeerJoin.json
    sed -i -e "s/\"peer_pub_key\":.*/\"peer_pub_key\": \"$pk\",/g" params/ShardPeerJoin.json
    sed -i -e "s/\"ip_address\":.*/\"ip_address\": \"$s\",/g" params/ShardPeerJoin.json

	i=0
	while [ $i -lt $shardPerNode ]
	do
		sed -i -e "s/\"shard_id\":.*/\"shard_id\": $id,/g" params/ShardPeerJoin.json
        echo "peer join shard " $id
		head -5 params/ShardPeerJoin.json
		./bin/shardmgmt peerjoin config.json params/ShardPeerJoin.json
        sleep 10
		((i++))
		((id++))
	done

	((counter++))
done

# peer activate
id=1
counter=1
for s in "${servers[@]}"
do
	sed -i -e "s/wallet[0-9]*.dat/wallet$counter.dat/g" params/ShardActivate.json

	i=0
	while [ $i -lt $shardPerNode ]
	do
		sed -i -e "s/\"shard_id\":.*/\"shard_id\": $id/g" params/ShardActivate.json
        echo "peer activate " $id
		head -3 params/ShardActivate.json
		./bin/shardmgmt activate config.json params/ShardActivate.json
        sleep 10
		((i++))
		((id++))
	done

	((counter++))
done

