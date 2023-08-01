#!/usr/bin/env bash

source ./env.sh
export RUST_LOG=info

ln -sf ./dataflow-learning-based-detection-from-cache.json5 ./config/modules/dataflow.json5


function_modules=(
#    "data-writer"
)



# run pcd-detect
if [ -n "$1" ] ; then
    start sh -c "cd '${repo_dir}/py-bin/pcd-detect' && \
    poetry run main --config '${module_config}/pcd-detect-pointrcnn-lidar1.json5' \
    --pcd_files_dir /home/yahoo55025502/self-training-data/pointcloud-lidar1 \
    --num_frames $1"
else
    start sh -c "cd '${repo_dir}/py-bin/pcd-detect' && \
    poetry run main --config '${module_config}/pcd-detect-pointrcnn-lidar1.json5' \
    --pcd_files_dir /home/yahoo55025502/self-training-data/pointcloud-lidar1 \
    --gt_index_dir /mnt/nfs/wayside_team/mark_thesis_data/PingTung-annotated-datasets/lidar1/kitti-format-split/label_2/"
fi


sleep 5

for module in ${function_modules[@]}; do
    launch_rust_module $module
done

start sh -c "./bin/pcd-tracking --config ${module_config}/pcd-tracking-from-pcd-detect.json5"

# start sh -c "./bin/data-writer --config ${module_config}/data-writer.json5 2>&1 | tee $LOG_FILE" 

wait
