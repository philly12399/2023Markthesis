#!/bin/bash -i

starting_round=$1
cfg_file=$2

set -e

for ((i=starting_round; i<=10; i++)); do
    if [ $i -eq 0 ]
    then
        ./self-training-wayside-round-0.sh $cfg_file
    else
        ./self-training-wayside-round-i.sh $cfg_file $i
    fi
done

