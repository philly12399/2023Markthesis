#!/bin/bash -i

starting_round=$1
cfg_file=$2

set -e

for ((i=starting_round; i<=20; i++)); do
    ./self-training-nusc-round-i.sh $cfg_file $i
done

