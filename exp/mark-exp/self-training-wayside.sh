#!/bin/bash -i

starting_round=$1
cfg_file=$2
wayside_repo_path="/home/yahoo55025502/wayside-portal"
openpcdet_repo_path="/home/yahoo55025502/OpenPCDet-Mark-thesis"
tracking_data_dir="/home/yahoo55025502/self-training-data/nuscenes-tracking-info"
device="lidar1"
exp_dir="$wayside_repo_path/exp/mark-exp"
pcd_detect_script="$exp_dir/learning-based-detect-from-nuscenes-wayside.sh"


SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

set -e

for ((i=starting_round; i<=40; i++)); do
$SCRIPT_DIR/self_training_nusc_round_i.sh $i $cfg_file \
$wayside_repo_path $openpcdet_repo_path $tracking_data_dir \
$device $exp_dir $pcd_detect_script
done
