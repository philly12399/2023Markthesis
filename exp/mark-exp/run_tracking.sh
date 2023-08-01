#!/usr/bin/env bash

source ./env.sh

function_modules=(
    # "video-capture"
    # "lidar-scan"
    # "message-matcher"
    # "pcd-process"

    "pcd-tracking"
    # "wayside-filter"
    # "wayside-logger"
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
