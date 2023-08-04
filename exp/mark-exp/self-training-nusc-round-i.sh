#!/bin/bash -i

cfg_file=$1
round=$2
openpcdet_repo_path=$(realpath ../../repos/OpenPCDet-Mark-thesis)
tracking_data_dir=$(realpath ../../output/tracking-info)

echo "cfg_file: $cfg_file"
echo "Round: $round"
set -e
cfg_name=$(basename $cfg_file .yaml)

if [ -f "$openpcdet_repo_path/data/$cfg_name/ST-r$round/kitti_infos_train.pkl" ]; then
    (
    cd "$openpcdet_repo_path/tools/"
    poetry run python train.py --cfg_file "cfgs/kitti_models/$cfg_name.yaml" --extra_tag ST-r$round \
    --set DATA_CONFIG.DATA_PATH "../data/$cfg_name/ST-r$round"
    rm ../data/$cfg_name/ST-r$round/training/velodyne -r
    )
else
    if [ $round -eq 0 ]
    then
        # Run pcd-cluster + pcd-tracking
        ./dbscan-from-nuscenes.sh
    else
        # Run pcd-detect + pcd-tracking
        config_path=./config/modules/pcd-detect-pvrcnn-nuscenes.json5
        ckpt_path="$openpcdet_repo_path/output/kitti_models/$cfg_name/ST-r$(($round - 1))/ckpt/checkpoint_epoch_80.pth"
        poetry run python "$openpcdet_repo_path/tools/scripts/revise_json.py" revise_json "$config_path" ckpt "$ckpt_path"
        ./pvrcnn-detect-from-nuscenes-wayside.sh
    fi

    # Get latest directory name
    tracking_data_path="$tracking_data_dir/$(ls -t $tracking_data_dir| head -n1)"

    # Run module refine-by-track to filter BBoxes by tracking data
    (
    if [ $round -eq 0 ]; then
        config_path=./config/modules/refine-by-track/dbscan-refiner-nuscenes.json5
    elif [ $round -le 10 ]; then
        config_path=./config/modules/refine-by-track/model-refiner-nuscenes.json5
    else
        config_path=./config/modules/refine-by-track/model-refiner-nuscenes-r10.json5
    fi
    
    poetry run python "$openpcdet_repo_path/tools/scripts/revise_json.py" revise_json $config_path input_dir "$tracking_data_path"
    ./bin/refine-by-track -c $config_path
    )

    refined_data_path="$tracking_data_path/refined-output/kitti-format"

    # Prepare KITTI training data
    (
    mkdir -p "$openpcdet_repo_path/data/$cfg_name/ST-r$round"
    cd "$openpcdet_repo_path/data/$cfg_name/ST-r$round" 
    ln -Tfs "$refined_data_path" training 
    mkdir -p ImageSets 
    echo Writing train.txt ... 
    ln -s "$openpcdet_repo_path/nuscenes-preprocessing/params/train_val.txt" ImageSets/train.txt
    ln -s "$openpcdet_repo_path/nuscenes-preprocessing/params/val.txt" ImageSets/val.txt
    # poetry run python "$openpcdet_repo_path/tools/scripts/write_index_file.py" write_index_file ImageSets training/label_2 2
    cd "$openpcdet_repo_path"
    poetry run python -m pcdet.datasets.kitti.kitti_dataset create_kitti_infos tools/cfgs/dataset_configs/kitti_nuscenes.yaml "data/$cfg_name/ST-r$round"
    )

    # PV-RCNN Training
    (
    cd "$openpcdet_repo_path/tools/"
    poetry run python train.py --cfg_file "cfgs/kitti_models/$cfg_name.yaml" --extra_tag ST-r$round \
    --set DATA_CONFIG.DATA_PATH "../data/$cfg_name/ST-r$round"
    rm ../data/$cfg_name/ST-r$round/training/velodyne -r
    )
fi




