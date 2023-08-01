#!/usr/bin/env bash

source ./env.sh

ln -sf ./dataflow-pcd-process-write-cache.json5 ./config/modules/dataflow.json5

function_modules=(
    "pcd-cluster"
    "pcd-tracking"
    # "image-groundtruth"
    # "data-writer"
)


for module in ${function_modules[@]}; do
    launch_rust_module $module
done

# launch_rust_module "pcd-cluster" "./config/modules/pcd-cluster-read-cache.json5"

# wait for timeout
if [ -n "$1" ] ; then
    sleep "$1"
else
    wait
fi
