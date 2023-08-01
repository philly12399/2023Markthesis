#!/usr/bin/env bash

source ./env.sh

ln -sf ./dataflow-learning-based-detection-from-cache.json5 ./config/modules/dataflow.json5


function_modules=(
    "data-writer"
)

# run pcd-detect
start sh -c "cd '${repo_dir}/py-bin/pcd-detect' && \
poetry run main --config '${module_config}/pcd-detect-read-cache.json5' --pcd_files_dir /mnt/nfs/wayside_team/mark_thesis_data/self-training-data/pointcloud"
sleep 5

for module in ${function_modules[@]}; do
    launch_rust_module $module
done

start sh -c "./bin/pcd-tracking --config ${module_config}/pcd-tracking-from-pcd-detect.json5"




# wait for timeout
if [ -n "$1" ] ; then
    sleep "$1"
else
    wait
fi
