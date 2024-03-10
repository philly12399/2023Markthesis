#!/usr/bin/env bash
source ./env.sh

ln -sf ./dataflow-nuscenes.json5 ./config/modules/dataflow.json5


# run nuscenes-data-loader
start sh -c "cd '${repo_dir}/py-bin/nuscenes-data-loader' && poetry run main --config '${module_config}/pcd-files-data-loader.json5'"

start sh -c "./bin/pcd-cluster --config ${module_config}/pcd-cluster.json5"

start sh -c "./bin/tracker --config ${module_config}/tracker.json5"


# wait for timeout
if [ -n "$1" ] ; then
    sleep "$1"
else
    wait
fi
