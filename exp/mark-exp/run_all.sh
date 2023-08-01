#!/usr/bin/env bash

source ./env.sh

ln -sf ./dataflow-run-all-dbscan.json5 ./config/modules/dataflow.json5

function_modules=(
    "lidar-scan"
    "message-matcher"

    "pcd-process"
    "pcd-cluster"
    "tracker"
#    "data-writer"
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
