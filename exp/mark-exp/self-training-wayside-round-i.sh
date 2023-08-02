#!/bin/bash -i

cfg_file=$1
round=$2
openpcdet_repo_path=$(realpath ../../repos/OpenPCDet-Mark-thesis)
tracking_data_dir=$(realpath ../../output/tracking-info)

echo "cfg_file: $cfg_file"
echo "Round: $round"
set -e
cfg_name=$(basename $cfg_file .yaml)

if [ -d "$openpcdet_repo_path/data/ST-r$round" ]; then
    (
    cd "$openpcdet_repo_path/tools/"
    poetry run python train.py --cfg_file "cfgs/kitti_models/$cfg_name.yaml" --extra_tag ST-r$round \
    --set DATA_CONFIG.DATA_PATH "../data/ST-r$round"
    )
else
    if [ $round -eq 0 ]
    then
        # Run pcd-cluster + pcd-tracking
        ./dbscan-from-pcd-files.sh
    else
        # Run pcd-detect + pcd-tracking
        ckpt_path="$openpcdet_repo_path/output/kitti_models/$cfg_name/ST-r$(($round - 1))/ckpt/checkpoint_epoch_80.pth"
        python "$openpcdet_repo_path/tools/scripts/revise_json.py" revise_json ./config/modules/pcd-detect-lidar1.json5 ckpt "$ckpt_path"
        ./learning-based-detect-from-pcd-files-lidar1.sh
    fi

    # Get latest directory name
    tracking_data_path="$tracking_data_dir/$(ls -t $tracking_data_dir| head -n1)"

    # Run module refine-by-track to filter BBoxes by tracking data
    (
    if [ $round -eq 0 ]
    then
        python "$openpcdet_repo_path/tools/scripts/revise_json.py" revise_json config/modules/refine-by-track/dbscan-refiner-lidar1.json5 input_dir "$tracking_data_path"
        ./bin/refine-by-track -c config/modules/refine-by-track/dbscan-refiner-lidar1.json5
    else
        python "$openpcdet_repo_path/tools/scripts/revise_json.py" revise_json config/modules/refine-by-track/model-refiner-lidar1.json5 input_dir "$tracking_data_path"
        ./bin/refine-by-track -c config/modules/refine-by-track/model-refiner-lidar1.json5
    fi
    )

    refined_data_path="$tracking_data_path/refined-output/kitti-format"

    # Prepare KITTI training data
    (
    mkdir -p "$openpcdet_repo_path/data/ST-r$round"
    cd "$openpcdet_repo_path/data/ST-r$round" 
    ln -Tfs "$refined_data_path" training 
    mkdir -p ImageSets 
    echo Writing train.txt ... 
    python "$openpcdet_repo_path/tools/scripts/write_index_file.py" write_index_file ImageSets training/label_2 2
    cd "$openpcdet_repo_path"
    python -m pcdet.datasets.kitti.kitti_dataset create_kitti_infos tools/cfgs/dataset_configs/kitti_dataset.yaml "data/ST-r$round"
    )

    # PV-RCNN Training
    (
    cd "$openpcdet_repo_path/tools/"
    python train.py --cfg_file "cfgs/kitti_models/$cfg_name.yaml" --extra_tag ST-r$round \
    --set DATA_CONFIG.DATA_PATH "../data/ST-r$round"
    rm ../data/ST-r$round -r
    )
fi




