#!/usr/bin/env bash

source ./env.sh

ln -sf ./dataflow-pcd-process-write-cache.json5 ./config/modules/dataflow.json5

function_modules=(
    "message-matcher"
    "pcd-process"
)


for module in ${function_modules[@]}; do
    launch_rust_module $module
done


sleep 3

source_modules=(
    # "video-capture"
    "lidar-scan"
)

for module in ${source_modules[@]}; do
    launch_rust_module $module
done

# wait for timeout
if [ -n "$1" ] ; then
    sleep "$1"
else
    wait
fi
