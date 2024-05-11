#!/usr/bin/env bash

source ./env.sh
export RUST_LOG=info

ln -sf ./dataflow-learning-based-detection-from-cache.json5 ./config/modules/dataflow.json5
# SEQ=(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20) #KITTI SEQ
SEQ=(0 1)
for s in "${SEQ[@]}"; do
    echo "Processing seq $s"
    ##config file of this seq
    python3 kitti-seq-json5.py $s
    # run pcd-detect
    start sh -c "cd '${repo_dir}/py-bin/pcd-detect' && poetry run main --config '${module_config}/pcd-detect-kitti-seq.json5'" 
    wait
done


# start sh -c "./bin/tracker --config ${module_config}/tracker-from-pcd-detect.json5"


