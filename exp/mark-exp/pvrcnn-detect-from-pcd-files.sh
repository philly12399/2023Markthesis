#!/usr/bin/env bash

source ./env.sh
export RUST_LOG=info

ln -sf ./dataflow-learning-based-detection-from-cache.json5 ./config/modules/dataflow.json5


# run pcd-detect
start sh -c "cd '${repo_dir}/py-bin/pcd-detect' && poetry run main --config '${module_config}/pcd-detect-lidar1.json5'"

sleep 5

start sh -c "./bin/tracker --config ${module_config}/tracker-from-pcd-detect.json5"

wait
