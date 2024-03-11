#!/bin/bash -i

round=0
openpcdet_repo_path=$(realpath ../../repos/OpenPCDet-Mark-thesis)
tracking_data_dir=$(realpath ../../output/tracking-info)
echo "Round: $round"
set -e
# Run pcd-cluster + pcd-tracking
./dbscan-from-pcd-files.sh

# Get latest directory name
tracking_data_path="$tracking_data_dir/$(ls -t $tracking_data_dir| head -n1)"
mv $tracking_data_path "$tracking_data_dir/4300"
tracking_data_path="$tracking_data_dir/4300"

 (
    config_path=config/modules/refine-by-track/dbscan-refiner-lidar1_100.json5
     poetry run python "$openpcdet_repo_path/tools/scripts/revise_json.py" revise_json $config_path input_dir "$tracking_data_path"
    ./bin/refine-by-track -c $config_path | tee  "$tracking_data_path/log.txt" 
)






