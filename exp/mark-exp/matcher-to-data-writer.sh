#!/usr/bin/env bash

source ./env.sh

ln -sf ./dataflow-matcher-to-data-writer.json5 ./config/modules/dataflow.json5


function_modules=(
    # "video-capture"
    "lidar-scan"
    "message-matcher"
    "pcd-process"
    "data-writer"
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
