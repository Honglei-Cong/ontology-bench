#!/bin/bash -x

servers=("10.1.4.4" "10.1.4.5" "10.1.4.6" "10.1.4.7" "10.1.4.8" "10.1.4.112" "10.1.4.113")

counter=1
# copy txgen and configs
for s in "${servers[@]}"
do
ssh  $s 'sudo pkill -9 txgen'
ssh  $s 'sudo rm -rf /mnt/txgen && sudo mkdir /mnt/txgen && sudo chown ubuntu:ubuntu /mnt/txgen && ls -l /mnt/'
scp ./bin/txgen ./config.json ubuntu@$s:/mnt/txgen
scp ./wallets/wallet$counter.dat ubuntu@$s:/mnt/txgen/wallet.dat
((counter++))
done

