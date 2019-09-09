#!/bin/bash -x

pk=`../bin/ontology account list -v -w ../wallets/wallet0.dat | grep 'Public key' | awk '{print $3}'`
echo $pk
sed -i -e "s/\"bookkeepers\":.*/\"bookkeepers\": [\"$pk\"]/g" ../configs/solo-config.json

rootServer="10.1.4.9"
ssh  $rootServer 'sudo pkill -9 ontology'
ssh  $rootServer 'sudo rm -rf /mnt/shard && sudo mkdir /mnt/shard && sudo chown ubuntu:ubuntu /mnt/shard && ls -l /mnt/'
scp ../bin/ontology ../configs/solo-config.json ../configs/start-root.sh ../configs/clean.sh ../wallets/wallet0.dat ubuntu@$rootServer:/mnt/shard
scp ../wallets/wallet0.dat ubuntu@$rootServer:/mnt/shard/wallet.dat
scp -r ../Chain ubuntu@$rootServer:/mnt/shard/


counter=1

# servers=("10.1.4.11" "10.1.4.10")
# servers=("10.1.4.11" "10.1.4.10" "10.1.4.12" "10.1.4.13" "10.1.4.14" "10.1.4.15" "10.1.4.16" "10.1.4.17" "10.1.4.18" "10.1.4.19")
servers=("10.1.4.11" "10.1.4.10" "10.1.4.12" "10.1.4.13" "10.1.4.14" "10.1.4.15" "10.1.4.16" "10.1.4.17" "10.1.4.18" "10.1.4.19" "10.1.4.21" "10.1.4.20" "10.1.4.22" "10.1.4.23" "10.1.4.25" "10.1.4.26" "10.1.4.27" "10.1.4.24" "10.1.4.28" "10.1.4.29" "10.1.4.30" "10.1.4.31" "10.1.4.33" "10.1.4.32" "10.1.4.34" "10.1.4.35" "10.1.4.36" "10.1.4.37" "10.1.4.38" "10.1.4.40" "10.1.4.39" "10.1.4.41" "10.1.4.42" "10.1.4.43" "10.1.4.47" "10.1.4.46" "10.1.4.44" "10.1.4.45" "10.1.4.48" "10.1.4.49" "10.1.4.51" "10.1.4.50" "10.1.4.53" "10.1.4.52" "10.1.4.54" "10.1.4.55" "10.1.4.56" "10.1.4.57" "10.1.4.58" "10.1.4.59" "10.1.4.60" "10.1.4.61" "10.1.4.62" "10.1.4.63" "10.1.4.64" "10.1.4.65" "10.1.4.66" "10.1.4.67" "10.1.4.68" "10.1.4.69" "10.1.4.70" "10.1.4.71" "10.1.4.72" "10.1.4.74" "10.1.4.73" "10.1.4.77" "10.1.4.75" "10.1.4.76" "10.1.4.79" "10.1.4.78" "10.1.4.80" "10.1.4.81" "10.1.4.82" "10.1.4.83" "10.1.4.84" "10.1.4.85" "10.1.4.87" "10.1.4.86" "10.1.4.88" "10.1.4.89" "10.1.4.90" "10.1.4.91" "10.1.4.92" "10.1.4.93" "10.1.4.94" "10.1.4.95" "10.1.4.96" "10.1.4.97" "10.1.4.98" "10.1.4.99" "10.1.4.101" "10.1.4.100" "10.1.4.102" "10.1.4.103" "10.1.4.104" "10.1.4.105" "10.1.4.107" "10.1.4.106" "10.1.4.108" "10.1.4.111" "10.1.4.110" "10.1.4.109")

for s in "${servers[@]}"
do
ssh  $s 'sudo pkill -9 ontology'
ssh  $s 'sudo rm -rf /mnt/shard && sudo mkdir /mnt/shard && sudo chown ubuntu:ubuntu /mnt/shard && ls -l /mnt/'
scp ../bin/ontology ../configs/solo-config.json ../configs/start.sh ../configs/clean.sh ../configs/peers.rsv ../wallets/wallet$counter.dat ubuntu@$s:/mnt/shard
scp ../wallets/wallet$counter.dat ubuntu@$s:/mnt/shard/wallet.dat
scp -r ../Chain ubuntu@$s:/mnt/shard/
((counter++))
done

