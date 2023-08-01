#!/usr/bin/env bash

source ./env.sh

ln -sf ./dataflow-pcd-cluster-write-cache.json5 ./config/modules/dataflow.json5


function_modules=(
    "pcd-tracking"
    # "data-writer"
)

for module in ${function_modules[@]}; do
    launch_rust_module $module
done

# wait for timeout
if [ -n "$1" ] ; then
    sleep "$1"
else
    wait
fi
