#!/bin/bash -x

pk=`../bin/ontology account list -v -w ../wallets/wallet0.dat | grep 'Public key' | awk '{print $3}'`
echo $pk
sed -i -e "s/\"bookkeepers\":.*/\"bookkeepers\": [\"$pk\"]/g" ../configs/solo-config.json

rootServer="10.1.4.27"
ssh  $rootServer 'sudo pkill -9 ontology'
ssh  $rootServer 'sudo rm -rf /mnt/shard && sudo mkdir /mnt/shard && sudo chown ubuntu:ubuntu /mnt/shard && ls -l /mnt/'
scp ../bin/ontology ../configs/solo-config.json ../configs/start-root.sh ../configs/clean.sh ../wallets/wallet0.dat ubuntu@$rootServer:/mnt/shard
scp ../wallets/wallet0.dat ubuntu@$rootServer:/mnt/shard/wallet.dat
scp -r ../Chain ubuntu@$rootServer:/mnt/shard/


counter=1

servers=("10.1.4.4" "10.1.4.5" "10.1.4.6" "10.1.4.7" "10.1.4.8" "10.1.4.9" "10.1.4.10" "10.1.4.11" "10.1.4.12" "10.1.4.13" "10.1.4.14" "10.1.4.15" "10.1.4.16" "10.1.4.17" "10.1.4.18" "10.1.4.19" "10.1.4.20" "10.1.4.21" "10.1.4.22" "10.1.4.23" "10.1.4.24" "10.1.4.26")

for s in "${servers[@]}"
do
ssh  $s 'sudo pkill -9 ontology'
ssh  $s 'sudo rm -rf /mnt/shard && sudo mkdir /mnt/shard && sudo chown ubuntu:ubuntu /mnt/shard && ls -l /mnt/'
scp ../bin/ontology ../configs/solo-config.json ../configs/start.sh ../configs/clean.sh ../wallets/wallet$counter.dat ubuntu@$s:/mnt/shard
scp ../wallets/wallet$counter.dat ubuntu@$s:/mnt/shard/wallet.dat
scp -r ../Chain ubuntu@$s:/mnt/shard/
((counter++))
done

