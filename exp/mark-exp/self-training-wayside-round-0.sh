#!/bin/bash -i

cfg_file=$1
round=$2
openpcdet_repo_path=$(realpath ../../repos/OpenPCDet-Mark-thesis)
tracking_data_dir=$(realpath ../../output/tracking-info)

echo "cfg_file: $cfg_file"
set -e
cfg_name=$(basename $cfg_file .yaml)

if [ -d "$openpcdet_repo_path/data/ST-r0" ]; then
    (
    cd "$openpcdet_repo_path/tools/"
    poetry run python train.py --cfg_file "cfgs/kitti_models/$cfg_name.yaml" --extra_tag ST-r0 \
    --set DATA_CONFIG.DATA_PATH "../data/ST-r0"
    )
else
    # Run pcd-cluster + pcd-tracking
    ./dbscan-from-pcd-files.sh

    # Get latest directory name
    tracking_data_path="$tracking_data_dir/$(ls -t $tracking_data_dir| head -n1)"

    # Run module refine-by-track to filter BBoxes by tracking data
    (
    python "$openpcdet_repo_path/tools/scripts/revise_json.py" revise_json config/modules/refine-by-track/dbscan-refiner-lidar1.json5 input_dir "$tracking_data_path"
    ./bin/refine-by-track -c config/modules/refine-by-track/dbscan-refiner-lidar1.json5
    )

    refined_data_path="$tracking_data_path/refined-output/kitti-format"

    # Prepare KITTI training data
    (
    mkdir -p "$openpcdet_repo_path/data/ST-r0"
    cd "$openpcdet_repo_path/data/ST-r0" 
    ln -Tfs "$refined_data_path" training 
    mkdir -p ImageSets 
    echo Writing train.txt ... 
    python "$openpcdet_repo_path/tools/scripts/write_index_file.py" write_index_file ImageSets training/label_2 2
    cd "$openpcdet_repo_path"
    poetry run python -m pcdet.datasets.kitti.kitti_dataset create_kitti_infos tools/cfgs/dataset_configs/kitti_dataset.yaml "data/ST-r0"
    )

    # PV-RCNN Training
    (
    cd "$openpcdet_repo_path/tools/"
    poetry run python train.py --cfg_file "cfgs/kitti_models/$cfg_name.yaml" --extra_tag ST-r0 \
    --set DATA_CONFIG.DATA_PATH "../data/ST-r0"
    rm ../data/ST-r0/training/velodyne -r
    )

    # Remove pcd files 

fi




