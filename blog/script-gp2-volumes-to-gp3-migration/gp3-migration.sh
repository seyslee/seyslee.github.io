#!/bin/bash

#==================================================
# [Last Modified Date]
# 2022-06-02
#
# [Author]
# Younsung Lee
#
# [Description]
# Change all gp2 volumes to gp3 in specific region
#==================================================

region='ap-northeast-2'
aws_cmd_path=$(which aws)

# Step 1. Find all gp2 volumes within the given region
echo "[i] Start finding all gp2 volumes in ${region}"
volume_ids=$(
  ${aws_cmd_path} ec2 describe-volumes \
  --region "${region}" \
  --filters Name=volume-type,Values=gp2 | \
  jq -r '.Volumes[].VolumeId'
)

echo "[i] List up all gp2 volume in ${region}"
echo $volume_ids
echo "[i] ============================="

# Step 2. Iterate all gp2 volumes and change its type to gp3
echo "[i] Migrating all gp2 volumes to gp3"
for volume_id in ${volume_ids};
do
    result=$(${aws_cmd_path} ec2 modify-volume \
    --region "${region}" \
    --volume-type=gp3 \
    --volume-id "${volume_id}" | \
    jq '.VolumeModification.ModificationState' | \
    sed 's/"//g')
    if [ $? -eq 0 ] && [ "${result}" == "modifying" ];then
        echo "[i] OK: volume ${volume_id} changed to state 'modifying'"
    else
        echo "[e] ERROR: couldn't change volume ${volume_id} type to gp3!"
    fi
done