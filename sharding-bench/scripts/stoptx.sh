#!/bin/bash -x

servers=("10.1.4.4" "10.1.4.5" "10.1.4.6" "10.1.4.7" "10.1.4.8" "10.1.4.112" "10.1.4.113")

# copy txgen and configs
for s in "${servers[@]}"
do
ssh  $s 'sudo pkill -9 txgen'
done

